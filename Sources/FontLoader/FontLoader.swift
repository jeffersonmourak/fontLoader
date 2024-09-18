import Foundation

struct FontValidationError : LocalizedError {
    let description: String
    
    init (_ description: String) {
        self.description = description
    }
    
    var errorDescription: String? {
        description
    }
}

fileprivate func loadTableDir(fromData data: Data, usingSubtable subTable: Subtable) throws -> FontTableDirectoryMap {
    let dirOffset = ReadOffset(startAt: 12, withBlockSize: 16)
    var tableDirMap: FontTableDirectoryMap = [:]
    var dataWindow = data.advanced(by: dirOffset.offset)
    
    var missingRequiredTables = Set(RequiredTables)
    
    for _ in 0..<subTable.numTables {
        dirOffset.next()
        
        let table: TableDirectory = try TableDirectory(bytes: dataWindow)
        
        if missingRequiredTables.contains(table.tag) {
            missingRequiredTables.remove(table.tag)
        }
        
        tableDirMap[table.tag] = table
        
        dataWindow = data.advanced(by: dirOffset.offset)
    }
    
    guard missingRequiredTables.count == 0 else {
        throw FontValidationError("Missing required tables \(missingRequiredTables.joined(separator: ", "))")
    }
    
    return tableDirMap
}

fileprivate func handleInvalid(reason: String) {
    // TODO: Implement validation handleing
    print("Invalid font. Reason: \(reason)")
}

 fileprivate func computeGlyphLocations(bytes: Data, fontInfo: HeadTable, memoryInfo: MaxpTable) throws -> [Int] {
    if (fontInfo.indexToLocFormat == 1) {
        return try LocaTable<UInt32>(bytes: bytes, withSize: Int(memoryInfo.numGlyphs)).indexes.map { Int($0) }
    } else {
        return try LocaTable<UInt16>(bytes: bytes, withSize: Int(memoryInfo.numGlyphs)).indexes.map { Int($0) * 2 }
    }
}
    

public class FontLoader: FontWithRequiredTables {
    private let data: Data
    
    public var characters: [Character : CharacterMapItem] = [:]
    
    public var horizontalHeader: HheaTable
    public var horizontalMetrics: HmtxTable
    public var fontInfo: HeadTable
    public var memoryInfo: MaxpTable
    public let fontLayout: FontLayout
    public let postScriptInfo: PostTable
    public let glyphLocations: [Int]
    
//  TODO: Turn this private
    public var cachedGlyphs: [Int: SimpleGlyphTable] = [:]
    
    public init(withData data: Data) throws {
        self.data = data
        let subTable: Subtable = try Subtable(bytes: data)
        
        var directory: FontTableDirectoryMap = [:]
        
        do {
            directory = try loadTableDir(fromData:data, usingSubtable: subTable)
        } catch {
            throw error
        }
        
        do {
            memoryInfo = try MaxpTable(bytes: data.advanced(by: Int(directory["maxp"]!.offset)));
            horizontalHeader = try HheaTable(bytes: data.advanced(by: Int(directory["hhea"]!.offset) + 2))
            horizontalMetrics =  try HmtxTable(bytes: data.advanced(by: Int(directory["hmtx"]!.offset)), numOfLongHorMetrics: Int(horizontalHeader.numOfLongHorMetrics), numOfGlyphs: Int(memoryInfo.numGlyphs))
            fontInfo = try HeadTable(bytes: data.advanced(by: Int(directory["head"]!.offset)))
            fontLayout = FontLayout(usingHeader: horizontalHeader, usingInfo: fontInfo)
            postScriptInfo = try PostTable(bytes: data.advanced(by: Int(directory["post"]!.offset)))
            glyphLocations = try computeGlyphLocations(bytes: data.advanced(by: Int(directory["loca"]!.offset)), fontInfo: fontInfo, memoryInfo: memoryInfo)
        } catch {
            throw error
        }
        
        super.init(subTable: subTable, directory: directory)
        
        characters = try cmapLookup()
    }

   
    private func getGlyphTableOrMissing(at index: Int) throws -> (Int, GlyfTable) {
        let targetIndex: Int = Int(glyf.offset) + Int(glyphLocations[index])
        let bytes: Data = data.advanced(by: Int(glyf.offset))
        
        if cachedGlyphs[index] != nil {
            return (index, .simple(cachedGlyphs[index]!))
        }
        
        guard let resolvedTable: GlyfTable = try? GlyfTable(data.advanced(by: targetIndex)) else {
            return (0, try! GlyfTable(bytes))
        }
        
        return (index, resolvedTable)
    }

    public func getSpaceGlyphIndex() -> Int { postScriptInfo.names.firstIndex { $0 == "SPC"} ?? 0 }
    
    public func getGlyphContours(at index: Int) throws -> Glyph {
        let bytes: Data = data.advanced(by: Int(glyf.offset))
        
        let (resolvedGlyphIndex, table) = try getGlyphTableOrMissing(at: index)
        
        let hMetrics: LongHorMetric = horizontalMetrics.hMetrics[resolvedGlyphIndex]

        return Glyph(
            from: table,
            at: index,
            name: postScriptInfo.names[index],
            withLayout: fontLayout,
            applyingMetrics: hMetrics,
            maxPoints: CGPoint(x: Double(fontInfo.xMax), y: Double(fontInfo.yMax)),
            glyfTable: bytes,
            glyphsLocations: glyphLocations,
            usingCache: &cachedGlyphs
        )
    }
    
    private func cmapLookup () throws -> [Character : CharacterMapItem] {
        let initialOffset: Int = Int(self.cmap.offset)
        let bytes: Data = data.advanced(by: initialOffset)
        let subTables: [CmapPlatformTable] = try CmapTable(bytes: bytes).subTables
        
        var cmapSubtableOffset: Int = 0
        var selectedUnicode: Int = -1
        
        for subTable: CmapPlatformTable in subTables {
            if subTable.platformId == .Unicode {
                let platformSpecificId: Int = Int(subTable.platformSpecificID)
                if platformSpecificId != 2 && platformSpecificId <= 4 && platformSpecificId > selectedUnicode {
                    cmapSubtableOffset = Int(subTable.offset)
                    selectedUnicode = platformSpecificId
                }
            } else if subTable.platformId == .Microsoft && selectedUnicode == -1 {
                if subTable.platformSpecificID == 1 || subTable.platformSpecificID == 10 {
                    cmapSubtableOffset = Int(subTable.offset)
                }
            }
        }
        
        let format: UInt16 = try bytes.value(ofType: UInt16.self, at: cmapSubtableOffset)
                
        if format == 4 {
            return try CmapTableFormat4(bytes: data, cmapStartOffset: initialOffset + cmapSubtableOffset).toCharacterMap()
        }
        
        if format == 12 {
            return try CmapTableFormat12(bytes: bytes.advanced(by: cmapSubtableOffset)).toCharacterMap()
        }
        
        return [:]
    }
    
    public func getFontNameTable() throws -> NameTable {
        return try NameTable(bytes: data.advanced(by: Int(name.offset)))
    }
}
