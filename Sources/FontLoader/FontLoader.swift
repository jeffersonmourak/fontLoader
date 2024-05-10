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
        
        let table = try TableDirectory(bytes: dataWindow)
        
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

public class FontLoader: FontWithRequiredTables {
    private let data: Data
    
    public var characters: [Character : CharacterMapItem] = [:]
    
    public var horizontalHeader: HheaTable
    public var horizontalMetrics: HmtxTable
    public var fontInfo: HeadTable
    public var memoryInfo: MaxpTable
    
    public init(withData data: Data) throws {
        self.data = data
        let subTable = try Subtable(bytes: data)
        
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
        } catch {
            throw error
        }
        
        super.init(subTable: subTable, directory: directory)
        
        characters = try cmapLookup()
        
    }

    public var glyphLocations: [Int] {
        get {
            do {
                if (fontInfo.indexToLocFormat == 1) {
                    return try LocaTable<UInt32>(bytes: data.advanced(by: Int(loca.offset)), withSize: Int(memoryInfo.numGlyphs)).indexes.map { Int($0) }
                } else {
                   return try LocaTable<UInt16>(bytes: data.advanced(by: Int(loca.offset)), withSize: Int(memoryInfo.numGlyphs)).indexes.map { Int($0) * 2 }
                }
            } catch {
                return []
            }
        }
    }
    
    public func getGlyphTableOrMissing(at index: Int) throws -> (Int, GlyfTable) {
        let targetIndex = Int(glyf.offset) + Int(glyphLocations[index])
        let bytes = data.advanced(by: Int(glyf.offset))
        
        guard let glyphData = try? GlyfTable(data.advanced(by: targetIndex)) else {
            return (0, try! GlyfTable(bytes))
        }
        
        return (index, glyphData)
    }
    
    public func getGlyphContours(at index: Int) throws -> Glyph {
        let bytes = data.advanced(by: Int(glyf.offset))
        let fontBoundaries = (CGPoint(x: Double(fontInfo.xMin), y: Double(fontInfo.yMin)), (CGPoint(x: Double(fontInfo.xMax), y: Double(fontInfo.yMax))))
        
        let (resolvedIndex, glyphData) = try getGlyphTableOrMissing(at: index)
        
        let glyphLayout: GlyphLayout = .init(fontBoundaries: fontBoundaries, horizontalMetrics: horizontalMetrics.hMetrics[resolvedIndex])

        return Glyph(glyphData, using: bytes, withLocation: glyphLocations, layout: glyphLayout)
    }
    
    func cmapLookup () throws -> [Character : CharacterMapItem] {
        let initialOffset = Int(self.cmap.offset)
        let bytes = data.advanced(by: initialOffset)
        let subTables = try CmapTable(bytes: bytes).subTables
        
        var cmapSubtableOffset = 0
        var selectedUnicode = -1
        
        for subTable in subTables {
            if subTable.platformId == .Unicode {
                let platformSpecificId = Int(subTable.platformSpecificID)
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
        
        let format = try bytes.value(ofType: UInt16.self, at: cmapSubtableOffset)
                
        if format == 4 {
            return try CmapTableFormat4(bytes: data, cmapStartOffset: initialOffset + cmapSubtableOffset).toCharacterMap()
        }
        
        if format == 12 {
            return try CmapTableFormat12(bytes: bytes.advanced(by: cmapSubtableOffset)).toCharacterMap()
        }
        
        return [:]
    }
}
