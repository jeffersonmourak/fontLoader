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
    
    let tableLength: Int
    
    init(bytes: Data) {
        let read = ReadHead(bytes, index: 0)
        
        scalerType = read.value(ofType: UInt32.self)!
        numTables = read.value(ofType: UInt16.self)!
        searchRange = read.value(ofType: UInt16.self)!
        entrySelector = read.value(ofType: UInt16.self)!
        rangeShift = read.value(ofType: UInt16.self)!
        tableLength = read.index
    }
}

public struct TableDirectory {
    let tag: String
    let checkSum: UInt32
    let offset: UInt32
    let length: UInt32
    let tableLength: Int
    
    init(bytes: Data) {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        tag = byteToString(read.value(ofType: UInt32.self, convertEndian: true)!, withSize: 4)
        checkSum = read.value(ofType: UInt32.self)!
        offset = read.value(ofType: UInt32.self)!
        length = read.value(ofType: UInt32.self)!
        tableLength = read.index
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
