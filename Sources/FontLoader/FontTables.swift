//
//  FontTables.swift
//
//
//  Created by Jefferson Oliveira on 4/20/24.
//

import Foundation

public typealias FontTableDirectoryMap = [String: TableDirectory]

public enum FontPlatforms: UInt16 {
    case Unicode = 0
    case Macintosh = 1
    case RESERVED = 2
    case Microsoft = 3
    
    static func from<T: BinaryInteger>(_ value: T) -> FontPlatforms {
        let int16value = UInt16(value)
        
        switch (int16value) {
        case 0: return .Unicode
        case 1: return .Macintosh
        case 2: return .RESERVED
        case 3: return .Microsoft
        default: return .Unicode
        }
    }
    
    public func toString() -> String {
        switch self {
        case .Unicode:
            return "Unicode"
        case .Macintosh:
            return "Macintosh"
        case .Microsoft:
            return "Microsoft"
        case .RESERVED:
            return "RESERVED"
        }
    }
}

public struct Subtable {
    let scalerType: UInt32
    let numTables: UInt16
    let searchRange: UInt16
    let entrySelector: UInt16
    let rangeShift: UInt16
    
    let tableLength: Int
    
    init(bytes: Data) throws {
        let read = ReadHead(bytes, index: 0)
        
        scalerType = try read.value(ofType: UInt32.self)
        numTables = try read.value(ofType: UInt16.self)
        searchRange = try read.value(ofType: UInt16.self)
        entrySelector = try read.value(ofType: UInt16.self)
        rangeShift = try read.value(ofType: UInt16.self)
        tableLength = read.index
    }
}

public struct TableDirectory {
    let tag: String
    let checkSum: UInt32
    let offset: UInt32
    let length: UInt32
    let tableLength: Int
    
    init(bytes: Data) throws {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        tag = byteToString(try read.value(ofType: UInt32.self, convertEndian: true), withSize: 4)
        checkSum = try read.value(ofType: UInt32.self)
        offset = try read.value(ofType: UInt32.self)
        length = try read.value(ofType: UInt32.self)
        tableLength = read.index
    }
}

public class FontWithRequiredTables {
    public let subTable: Subtable
    private let dirMap: FontTableDirectoryMap
    
    init(subTable: Subtable, directory: FontTableDirectoryMap) {
        self.subTable = subTable
        self.dirMap = directory
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
