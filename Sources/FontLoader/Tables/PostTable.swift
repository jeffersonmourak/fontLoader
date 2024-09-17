//
//  PostTable.swift
//
//
//  Created by Jefferson Oliveira on 9/13/24.
//

import Foundation

struct PostTableFormatInvalid : LocalizedError {
    let description: String
    
    init (_ description: String) {
        self.description = description
    }
    
    var errorDescription: String? {
        description
    }
}


fileprivate func getCharUIntOrFallback(_ messageRead: inout ReadHead) -> UInt8 {
    do {
        return try messageRead.value(ofType: UInt8.self)
    } catch {
        return 0
    }
}

fileprivate func computeFormat2Names(_ bytes: Data) throws -> [String] {
    let read: ReadHead = ReadHead(bytes, index: 0)
    let size: UInt16 = try read.value(ofType: UInt16.self)

        var glyphNameIndex: [UInt16] = []

        for _ in 0..<Int(size) {
            let index: UInt16 = try read.value(ofType: UInt16.self)
            glyphNameIndex.append(index)
        }


        var glyphNames: [String] = []

        for _ in 0..<Int(size) {
            let name: String = try read.pascalString()

            if name == "" {
                break
            }

            glyphNames.append(name)
        }

        var computedGlyphNames: [String] = []

        for stringIndex: UInt16 in glyphNameIndex {
            if stringIndex < 258 {
                computedGlyphNames.append(StandardMacOSFontNames[Int(stringIndex)])
            } else {
                computedGlyphNames.append(glyphNames[Int(stringIndex - 258)])
            }
        }

        return computedGlyphNames
}

fileprivate func computeMessage(_ bytes: Data, startAt offset: Int, withSize length: Int, hideUnknownChars: Bool = true) -> String {
    var messageRead: ReadHead = ReadHead(bytes.advanced(by: offset), index: 0)
    
    var messageBytes: [UInt8] = []
    
    for _ in 0..<length {
        let character = getCharUIntOrFallback(&messageRead)
        
        if !hideUnknownChars || character != 0 {
            messageBytes.append(character)
        }
        
    }
    
    return String(decoding: messageBytes, as: UTF8.self)
}

fileprivate func computeFormat(_ formatInt: UInt32) -> Int {
    return Int(withUnsafeBytes(of: formatInt) { Data($0) }[2])
}

public struct PostTable {
    public let format: Int
    public let italicAngles: UInt32
    public let underlinePosition: Int16
    public let underlineThickness: Int16
    public let isFixedPitch: UInt32
    public let minMemType42: UInt32
    public let maxMemType42: UInt32
    public let minMemType1: UInt32
    public let maxMemType1: UInt32
    public let names: [String]

    let tableLength: Int
    
    init(bytes: Data) throws {
        let read: ReadHead = ReadHead(bytes, index: 0)
        let formatRawValue: UInt32 = try read.value(ofType: UInt32.self)

        format = computeFormat(formatRawValue)
        italicAngles = try read.value(ofType: UInt32.self)
        underlinePosition = try read.value(ofType: Int16.self)
        underlineThickness = try read.value(ofType: Int16.self)
        isFixedPitch = try read.value(ofType: UInt32.self)
        minMemType42 = try read.value(ofType: UInt32.self)
        maxMemType42 = try read.value(ofType: UInt32.self)
        minMemType1 = try read.value(ofType: UInt32.self)
        maxMemType1 = try read.value(ofType: UInt32.self)

        switch format {
            case 1:
                names = StandardMacOSFontNames
            case 2:
                names = try computeFormat2Names(bytes.advanced(by: Int(read.index)))
            default:
                throw PostTableFormatInvalid("Format \(format) is not supported")
        }

        tableLength = read.index
    }
}
