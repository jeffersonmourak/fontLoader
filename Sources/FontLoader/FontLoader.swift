import Foundation

//let SUB_TABLE_OFFSET = ReadOffset(startAt: 0, withBlockSize: 12)
//let TABLE_DIR = ReadOffset(startAt: 12, withBlockSize: 16)

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
    var dirOffset = ReadOffset(startAt: 12, withBlockSize: 16)
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
    }
}
