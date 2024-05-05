//
//  MaxpTable.swift
//
//
//  Created by Jefferson Oliveira on 4/27/24.
//

import Foundation

enum CmapPlatforms: UInt16 {
    case Unicode = 0
    case Macintosh = 1
    case RESERVED = 2
    case Microsoft = 3
    
    static func from<T: BinaryInteger>(_ value: T) -> CmapPlatforms {
        let int16value = UInt16(value)
        
        switch (int16value) {
        case 0: return .Unicode
        case 1: return .Macintosh
        case 2: return .RESERVED
        case 3: return .Microsoft
        default: return .Unicode
        }
    }
}

public struct CmapPlatformTable {
    let platformId: CmapPlatforms
    let platformSpecificID: UInt16
    let offset: UInt32
    
    init(platformId: UInt16, platformSpecificID: UInt16, offset: UInt32) {
        self.platformId = CmapPlatforms.from(platformId)
        self.platformSpecificID = platformSpecificID
        self.offset = offset
    }
}

public struct CmapTable {
    let version: UInt16
    let numSubtables: UInt16
    let subTables: [CmapPlatformTable]
    
    
    let tableLength: Int
    
    init(bytes: Data) {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        version = read.value(ofType: UInt16.self)!
        numSubtables = read.value(ofType: UInt16.self)!
        
        var tables: [CmapPlatformTable] = []
        
        for i in 0..<numSubtables {
            let platformId = read.value(ofType: UInt16.self)!
            let platformSpecificID = read.value(ofType: UInt16.self)!
            let offset = read.value(ofType: UInt32.self)!
            
            tables.append(.init(platformId: platformId, platformSpecificID: platformSpecificID, offset: offset))
        }
        subTables = tables
        
        
        tableLength = read.index
    }
}

public struct CmapTableGroup {
    let charCode: Int
    let glyphIndex: Int
}

public struct CharacterMapItem: Identifiable {
    public let id: UUID = UUID()
    
    public let char: Character
    public let charCode: Int
    public let glyphIndex: Int
}

public struct CmapTableFormat4 {
    let format: UInt16
    let length: UInt16
    let language: UInt16
    let segCountX2: UInt16
    let searchRange: UInt16
    let entrySelector: UInt16
    let rangeShift: UInt16
    let groups: [CmapTableGroup]
    
    let reservedPad: UInt16
    
    let tableLength: Int
    
    init(bytes: Data, cmapStartOffset startOffset: Int) {
        let read: ReadHead = ReadHead(bytes, index: startOffset)
        
        format = read.value(ofType: UInt16.self)!
        length = read.value(ofType: UInt16.self)!
        language = read.value(ofType: UInt16.self)!
        segCountX2 = read.value(ofType: UInt16.self)!
        searchRange = read.value(ofType: UInt16.self)!
        entrySelector = read.value(ofType: UInt16.self)!
        rangeShift = read.value(ofType: UInt16.self)!
        
        let segCount = Int(segCountX2) / 2
        
        var endCodes: [Int] = []
        for _ in 0..<segCount
        {
            let endCode = read.value(ofType: UInt16.self)!
            endCodes.append(Int(endCode))
        }
        
        reservedPad = read.value(ofType: UInt16.self)!
        
        var startCodes: [Int] = []
        for _ in 0..<segCount
        {
            let startCode = read.value(ofType: UInt16.self)!
            startCodes.append(Int(startCode))
        }
        
        var deltaIds: [Int] = []
        for _ in 0..<segCount
        {
            let deltaId = read.value(ofType: UInt16.self)!
            deltaIds.append(Int(deltaId))
        }
        
        var idRangeOffsets: [(Int, Int)] = []
        for _ in 0..<segCount
        {
            let offset = read.value(ofType: UInt16.self)!
            idRangeOffsets.append((Int(offset), Int(read.index)))
        }
        
        var groups : [CmapTableGroup] = []
        
        for var i in 0..<startCodes.count {
            let endCode = endCodes[i]
            var currCode = startCodes[i]
            
            while currCode <= endCode {
                var glyphIndex: Int
                let (offset, loc) = idRangeOffsets[i]
                
                if offset == 0 {
                    glyphIndex = currCode + deltaIds[i]
                } else {
                    let rangeOffsetLocation = loc + offset;
                    let glyphIndexArrayLocation = 2 * (currCode - startCodes[i]) + rangeOffsetLocation;
                    
                    let glyphBytes = bytes.advanced(by: glyphIndexArrayLocation)
                    
                    glyphIndex = Int(glyphBytes.value(ofType: UInt16.self, at: 0)!)
                    
                    if glyphIndex != 0 {
                        glyphIndex = (glyphIndex + deltaIds[i]) % 65536;
                    }
                }
                
                
                groups.append(.init(charCode: currCode, glyphIndex: glyphIndex))
                
                currCode += 1
            }
        }
        
        self.groups = groups
        
        tableLength = read.index
    }
    
    func toCharacterMap() -> [Character: CharacterMapItem] {
        var mappedGroups: [Character: CharacterMapItem] = [:]
        
         groups.map {
            let char = Character(UnicodeScalar($0.charCode)!)
            
             mappedGroups[char] = CharacterMapItem(char:char, charCode: Int($0.charCode), glyphIndex: Int($0.glyphIndex))
            
            return
        }
        
        return mappedGroups
    }
}


public struct CmapTableFormat12 {
    let format: UInt16
    let RESERVED: UInt16
    let length: UInt32
    let language: UInt32
    let groupsCount: UInt32
    let groups: [CmapTableGroup]
    
    let tableLength: Int
    
    init(bytes: Data) {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        format = read.value(ofType: UInt16.self)!
        RESERVED = read.value(ofType: UInt16.self)!
        length = read.value(ofType: UInt32.self)!
        language = read.value(ofType: UInt32.self)!
        groupsCount = read.value(ofType: UInt32.self)!
        
        var groups: [CmapTableGroup] = []
        var includeMissingCharGlyph = false
        
        for _ in 0..<groupsCount {
            let startCharCode = read.value(ofType: UInt32.self)!
            let endCharCode = read.value(ofType: UInt32.self)!
            let startGlyphIndex = read.value(ofType: UInt32.self)!
            
            let charCount = endCharCode - startCharCode + 1
            
            for charCodeOffset in 0..<charCount {
                let glyphIndex = startGlyphIndex + charCodeOffset
                let charCode = startCharCode + charCodeOffset
                
                if let scalar = UnicodeScalar(charCode) {
                    groups.append(.init(charCode: Int(charCode), glyphIndex: Int(glyphIndex)))
                }
                
                
                includeMissingCharGlyph = includeMissingCharGlyph || glyphIndex == 0
            }
        }
        
        self.groups = groups
        
        tableLength = read.index
    }
    
    func toCharacterMap() -> [Character: CharacterMapItem] {
        
        var mappedGroups: [Character: CharacterMapItem] = [:]
        
         groups.map {
            let char = Character(UnicodeScalar($0.charCode)!)
            
             mappedGroups[char] = CharacterMapItem(char:char, charCode: Int($0.charCode), glyphIndex: Int($0.glyphIndex))
            
            return
        }
        
        return mappedGroups
    }
}
