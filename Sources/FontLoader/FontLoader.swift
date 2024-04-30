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

public struct Glyphs {
    private let locations: [Int]
    private let bytes: Data
    
    init(_ bytes: Data,_ locations: [Int]) {
        self.locations = locations
        self.bytes = bytes
    }
    
    public subscript(index: Int) -> SimpleGlyphTable? {
        get {
            return try? SimpleGlyphTable(
                bytes.advanced(
                    by: Int(locations[index])
                )
            )
        }
    }
    
    public var count: Int {
        get {
            return locations.count
        }
    }
}

public class FontLoader: FontWithRequiredTables {
    private let data: Data
    
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
        
//        cmapLookup()
    }
    
    public var glyphs: Glyphs {
        get {
            let head = HeadTable(bytes: data.advanced(by: Int(head.offset)))
            let maxp = MaxpTable(bytes: data.advanced(by: Int(maxp.offset)))
            
            if (head.indexToLocFormat == 1) {
                let locations = LocaTable<UInt32>(bytes: data.advanced(by: Int(loca.offset)), withSize: Int(maxp.numGlyphs)).indexes.map { Int($0) }
                
                let bytes = data.advanced(by: Int(glyf.offset))
                let glyphs = Glyphs(bytes, locations)
                
                return glyphs
            } else {
                let locations = LocaTable<UInt16>(bytes: data.advanced(by: Int(loca.offset)), withSize: Int(maxp.numGlyphs)).indexes.map { Int($0) }
                let bytes = data.advanced(by: Int(glyf.offset))
                let glyphs = Glyphs(bytes, locations)
                
                return glyphs
            }
        }
    }
    
    func cmapLookup () {
        let initialOffset = Int(self.cmap.offset)
        
        var bytes = data.advanced(by: initialOffset)
        
        var version = bytes.value(ofType: Int16.self, at: 0)
        var numOfTables = bytes.value(ofType: Int16.self, at: 2)
        
//        print(version, numOfTables)
        
//        let version =
        
        
        
//        var cmapReadOffset = ReadOffset(startAt: <#T##Int#>, withBlockSize: <#T##Int#>)
    }
}
