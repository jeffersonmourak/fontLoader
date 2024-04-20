//
//  FontTables.swift
//
//
//  Created by Jefferson Oliveira on 4/20/24.
//

import Foundation

public struct Subtable {
    let scalerType: UInt32
    let numTables: UInt16
    let searchRange: UInt16
    let entrySelector: UInt16
    let rangeShift: UInt16
    
    
    init(bytes: Data) {
        scalerType = bytes.value(ofType: UInt32.self, at: 0)!
        numTables = bytes.value(ofType: UInt16.self, at: 4)!
        searchRange = bytes.value(ofType: UInt16.self, at: 8)!
        entrySelector = bytes.value(ofType: UInt16.self, at: 12)!
        rangeShift = bytes.value(ofType: UInt16.self, at: 16)!
    }
}

public struct TableDirectory {
    let tag: String
    let checkSum: UInt32
    let offset: UInt32
    let length: UInt32
    
    init(bytes: Data) {
        tag = byteToString(bytes.value(ofType: UInt32.self, at: 0, convertEndian: true)!, withSize: 4)
        checkSum = bytes.value(ofType: UInt32.self, at: 4)!
        offset = bytes.value(ofType: UInt32.self, at: 8)!
        length = bytes.value(ofType: UInt32.self, at: 12)!
    }
}

public class FontWithRequiredTables {
    internal let subTable: Subtable
    internal let directory: [TableDirectory]
    
    private var dirMap: [String: TableDirectory] = [:]
    
    init(subTable: Subtable, directory: [TableDirectory]) {
        self.subTable = subTable
        self.directory = directory
        
        self.mapDirectories()
    }
    
    private func mapDirectories() {
        for table in directory {
            dirMap[table.tag] = table
        }
    }
    
    /** 
     Character to glyph mapping
     https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6cmap.html
     */
    public var cmap: TableDirectory {
        return dirMap["cmap"]!
    }
    
    /**
     Glyph data
     https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6glyf.html
     */
    public var glyf: TableDirectory {
        return dirMap["glyf"]!
    }
    
    /**
     Font header
     https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6head.html
     */
    public var head: TableDirectory {
        return dirMap["head"]!
    }
    
    /**
     Horizontal header
     https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6hhea.html
     */
    public var hhea: TableDirectory {
        return dirMap["hhea"]!
    }
    
    /**
     Horizontal metrics
     https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6hmtx.html
     */
    public var hmtx: TableDirectory {
        return dirMap["hmtx"]!
    }
    
    /**
     Index to location
     https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6loca.html
     */
    public var loca: TableDirectory {
        return dirMap["loca"]!
    }
    
    /**
     Maximum profile
     https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6maxp.html
     */
    public var maxp: TableDirectory {
        return dirMap["maxp"]!
    }
    
    /**
     Naming
     https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6name.html
     */
    public var name: TableDirectory {
        return dirMap["name"]!
    }
    
    /**
     PostScript
     https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6post.html
     */
    public var post: TableDirectory {
        return dirMap["post"]!
    }
    
}
