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

fileprivate func loadTableDir(fromData data: Data, usingSubtable subTable: Subtable) throws -> [TableDirectory] {
    let dirOffset = ReadOffset(startAt: 12, withBlockSize: 16)
    var tableDirectories: [TableDirectory] = []
    var dataWindow = data.advanced(by: dirOffset.offset)
    
    var missingRequiredTables = Set(RequiredTables)
    
    for _ in 0..<subTable.numTables {
        dirOffset.next()
        
        let table = TableDirectory(bytes: dataWindow)
        
        if missingRequiredTables.contains(table.tag) {
            missingRequiredTables.remove(table.tag)
        }
        
        tableDirectories.append(table)
        
        dataWindow = data.advanced(by: dirOffset.offset)
    }
    
    guard missingRequiredTables.count == 0 else {
        throw FontValidationError("Missing required tables \(missingRequiredTables.joined(separator: ", "))")
    }
    
    return tableDirectories
}

fileprivate func handleInvalid(reason: String) {
    // TODO: Implement validation handleing
    print("Invalid font. Reason: \(reason)")
}

public class FontLoader: FontWithRequiredTables {
    private let data: Data
    
    public var characters: [Character : CharacterMapItem] = [:]
    
    public init(withData data: Data) throws {
        self.data = data
        let subTable = Subtable(bytes: data)
        
        var directory: [TableDirectory] = []
        
        do {
            directory = try loadTableDir(fromData:data, usingSubtable: subTable)
        } catch {
            throw error
        }
        
        
        super.init(subTable: subTable, directory: directory)
        
        
        characters = cmapLookup()
        
    }
    
    public var horizontalHeader: HheaTable {
        get {
            let hhea = HheaTable(bytes: data.advanced(by: Int(hhea.offset) + 2))
            
            return hhea;
        }
    }
    
    public var horizontalMetrics: HmtxTable {
        get {
            let hmtx = HmtxTable(bytes: data.advanced(by: Int(hmtx.offset)), numOfLongHorMetrics: Int(horizontalHeader.numOfLongHorMetrics), numOfGlyphs: Int(memoryInfo.numGlyphs))
            
            return hmtx;
        }
    }
    
    public var fontInfo: HeadTable {
        get {
            return HeadTable(bytes: data.advanced(by: Int(head.offset)))
        }
    }
    
    public var memoryInfo: MaxpTable {
        get {
            return MaxpTable(bytes: data.advanced(by: Int(maxp.offset)));
        }
    }
    
    public var glyphLocations: [Int] {
        get {
            if (fontInfo.indexToLocFormat == 1) {
                return LocaTable<UInt32>(bytes: data.advanced(by: Int(loca.offset)), withSize: Int(memoryInfo.numGlyphs)).indexes.map { Int($0) }
            } else {
               return LocaTable<UInt16>(bytes: data.advanced(by: Int(loca.offset)), withSize: Int(memoryInfo.numGlyphs)).indexes.map { Int($0) * 2 }
            }
        }
    }
    
    public func getGlyphTableOrMissing(at index: Int) -> (Int, GlyfTable) {
        let targetIndex = Int(glyf.offset) + Int(glyphLocations[index])
        let bytes = data.advanced(by: Int(glyf.offset))
        
        guard let glyphData = try? GlyfTable(data.advanced(by: targetIndex)) else {
            return (0, try! GlyfTable(bytes))
        }
        
        return (index, glyphData)
    }
    
    public func getGlyphContours(at index: Int) -> Glyph {
        let bytes = data.advanced(by: Int(glyf.offset))
        let fontBoundaries = (CGPoint(x: Double(fontInfo.xMin), y: Double(fontInfo.yMin)), (CGPoint(x: Double(fontInfo.xMax), y: Double(fontInfo.yMax))))
        
        let (resolvedIndex, glyphData) = getGlyphTableOrMissing(at: index)
        
        let glyphLayout: GlyphLayout = .init(fontBoundaries: fontBoundaries, horizontalMetrics: horizontalMetrics.hMetrics[resolvedIndex])

        return Glyph(glyphData, using: bytes, withLocation: glyphLocations, layout: glyphLayout)
    }
    
    func cmapLookup () -> [Character : CharacterMapItem] {
        let initialOffset = Int(self.cmap.offset)
        let bytes = data.advanced(by: initialOffset)
        let subTables = CmapTable(bytes: bytes).subTables
        
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
        
        let format = bytes.value(ofType: UInt16.self, at: cmapSubtableOffset)!
                
        if format == 4 {
            return CmapTableFormat4(bytes: data, cmapStartOffset: initialOffset + cmapSubtableOffset).toCharacterMap()
        }
        
        if format == 12 {
            return CmapTableFormat12(bytes: bytes.advanced(by: cmapSubtableOffset)).toCharacterMap()
        }
        
        return [:]
    }
}
