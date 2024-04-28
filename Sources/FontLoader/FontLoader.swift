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

public struct Glyphs<T: BinaryInteger> {
    private let locations: LocaTable<T>
    private let bytes: Data
    
    init(_ bytes: Data,_ locations: LocaTable<T>) {
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
    
    public init(withData data: Data) {
        self.data = data
        let subTable = Subtable(bytes: data)
        
        var directory: [TableDirectory] = []
        
        do {
            directory = try loadTableDir(fromData:data, usingSubtable: subTable)
        } catch {
            handleInvalid(reason: error.localizedDescription)
        }
    
        super.init(subTable: subTable, directory: directory)
        
//        cmapLookup()
    }
    
    public var glyphs: Glyphs<UInt32> {
        get {
            let maxp = MaxpTable(bytes: data.advanced(by: Int(maxp.offset)))
            let locations = LocaTable<UInt32>(bytes: data.advanced(by: Int(loca.offset)), withSize: Int(maxp.numGlyphs))
            
            let bytes = data.advanced(by: Int(glyf.offset))
            let glyphs = Glyphs(bytes, locations)
            
            return glyphs
        }
    }
    
    /**
        Check out https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6glyf.html
     */
    public func getGlyph() {
        let maxp = MaxpTable(bytes: data.advanced(by: Int(maxp.offset)))
        let locations = LocaTableLong(bytes: data.advanced(by: Int(loca.offset)), withSize: Int(maxp.numGlyphs))
        
        for offset in locations.indexes {
            let totalOffset = Int(glyf.offset) + Int(offset)
            let bytes = data.advanced(by: Int(glyf.offset) + Int(offset))
//            print("\(glyf.offset) | \(offset) | \(totalOffset) > 0x\(String(totalOffset, radix: 16).uppercased())")
            
            do {
                let simpleGlyph = try SimpleGlyphTable(bytes)
                
                if (simpleGlyph == nil) {
//                    print("Compound Glyph at:")
    //                print(Int(glyf.offset))
    //                print(Int(offset))
    //                print("\(glyf.offset) | \(offset) | \(totalOffset) > 0x\(String(totalOffset, radix: 16).uppercased())")
                    
                    continue
                }
//                print(simpleGlyph)
            } catch {
//                print(error)
            }
            
            
        }
        
//        let offset = locations.indexes[0]

        
        
        

        
//        var glyphData = GlyphData(bytes: bytes)
//        bytes = bytes.advanced(by: glyphData.tableLength)
//        
//        let length = Int(glyphData.numberOfContours)
//        
//        let contoursEndIndices = Array(repeating: 0, count: length).map { index in
//            let countourData = bytes.value(ofType: UInt16.self, at: 0)
//            bytes = bytes.advanced(by: 2)
//            
//            return Int(countourData!)
//        }
//        let numOfPoints = contoursEndIndices.last! + 1

//        print(contoursEndIndices)
        
//        let allFlags: [UInt8] = Array(repeating: 0x0, count: length)
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
