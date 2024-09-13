//
//  MaxpTable.swift
//
//
//  Created by Jefferson Oliveira on 4/27/24.
//

import Foundation



public struct CmapPlatformTable {
    let platformId: FontPlatforms
    let platformSpecificID: UInt16
    let offset: UInt32
    
    init(platformId: UInt16, platformSpecificID: UInt16, offset: UInt32) {
        self.platformId = FontPlatforms.from(platformId)
        self.platformSpecificID = platformSpecificID
        self.offset = offset
    }
}

public struct CmapTable {
    let version: UInt16
    let numSubtables: UInt16
    let subTables: [CmapPlatformTable]
    
    
    let tableLength: Int
    
    init(bytes: Data) throws {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        version = try read.value(ofType: UInt16.self)
        numSubtables = try read.value(ofType: UInt16.self)
        
        var tables: [CmapPlatformTable] = []
        
        for i in 0..<numSubtables {
            let platformId = try read.value(ofType: UInt16.self)
            let platformSpecificID = try read.value(ofType: UInt16.self)
            let offset = try read.value(ofType: UInt32.self)
            
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
    
    init(bytes: Data, cmapStartOffset startOffset: Int) throws {
        let read: ReadHead = ReadHead(bytes, index: startOffset)
        
        format = try read.value(ofType: UInt16.self)
        length = try read.value(ofType: UInt16.self)
        language = try read.value(ofType: UInt16.self)
        segCountX2 = try read.value(ofType: UInt16.self)
        searchRange = try read.value(ofType: UInt16.self)
        entrySelector = try read.value(ofType: UInt16.self)
        rangeShift = try read.value(ofType: UInt16.self)
        
        let segCount = Int(segCountX2) / 2
        
        var endCodes: [Int] = []
        for _ in 0..<segCount
        {
            let endCode = try read.value(ofType: UInt16.self)
            endCodes.append(Int(endCode))
        }
        
        reservedPad = try read.value(ofType: UInt16.self)
        
        var startCodes: [Int] = []
        for _ in 0..<segCount
        {
            let startCode = try read.value(ofType: UInt16.self)
            startCodes.append(Int(startCode))
        }
        
        var deltaIds: [Int] = []
        for _ in 0..<segCount
        {
            let deltaId = try read.value(ofType: UInt16.self)
            deltaIds.append(Int(deltaId))
        }
        
        var idRangeOffsets: [(Int, Int)] = []
        for _ in 0..<segCount
        {
            let offset = try read.value(ofType: UInt16.self)
            idRangeOffsets.append((Int(offset), Int(read.index)))
        }
        
        var groups : [CmapTableGroup] = []
        
        for i in 0..<startCodes.count {
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
                    
                    glyphIndex = Int(try glyphBytes.value(ofType: UInt16.self, at: 0))
                    
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
        
        for group in groups {
            let char = Character(UnicodeScalar(group.charCode)!)
            
             mappedGroups[char] = CharacterMapItem(char:char, charCode: Int(group.charCode), glyphIndex: Int(group.glyphIndex))
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
    
    init(bytes: Data) throws {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        format = try read.value(ofType: UInt16.self)
        RESERVED = try read.value(ofType: UInt16.self)
        length = try read.value(ofType: UInt32.self)
        language = try read.value(ofType: UInt32.self)
        groupsCount = try read.value(ofType: UInt32.self)
        
        var groups: [CmapTableGroup] = []
        var includeMissingCharGlyph = false
        
        for _ in 0..<groupsCount {
            let startCharCode = try read.value(ofType: UInt32.self)
            let endCharCode = try read.value(ofType: UInt32.self)
            let startGlyphIndex = try read.value(ofType: UInt32.self)
            
            let charCount = endCharCode - startCharCode + 1
            
            for charCodeOffset in 0..<charCount {
                let glyphIndex = startGlyphIndex + charCodeOffset
                let charCode = startCharCode + charCodeOffset
                
                if UnicodeScalar(charCode) != nil {
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
        
        for group in groups {
            let char = Character(UnicodeScalar(group.charCode)!)
            mappedGroups[char] = CharacterMapItem(char:char, charCode: Int(group.charCode), glyphIndex: Int(group.glyphIndex))
        }
        
        return mappedGroups
    }
}
