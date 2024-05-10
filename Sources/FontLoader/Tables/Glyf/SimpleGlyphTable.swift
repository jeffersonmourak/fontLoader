//
//  SimpleGlyphTable.swift
//
//
//  Created by Jefferson Oliveira on 5/5/24.
//

import Foundation

struct SimpleGlyphValidationError : LocalizedError {
    let description: String
    
    init (_ description: String) {
        self.description = description
    }
    
    var errorDescription: String? {
        description
    }
}

enum FlagDirection {
    case X
    case Y
}

func readCoordinates(_ read: inout ReadHead, flags: [SimpleGlyphCoordinateFlag], axis: FlagDirection) throws -> [Int] {
    var coordinates: [Int] = Array(repeating: 0, count: flags.count)
    var coordCache = 0
    
    for i in 0..<coordinates.count {
        let flag = flags[i]
        let isShort = axis == FlagDirection.X ? flag.xShort : flag.yShort
        let instruction =  axis == FlagDirection.X ? flag.xInstruction : flag.yInstruction
        
        if isShort {
            let offset = try read.value(ofType: UInt8.self)
            coordCache += instruction ? Int(offset) : -Int(offset)
        } else if !instruction {
            let offset = Int(try read.value(ofType: Int16.self))
            coordCache += offset
        }
        coordinates[i] = coordCache
    }
    
    return coordinates
}

public struct SimpleGlyphCoordinateFlag {
    let rawValue: UInt8
    let onCurve: Bool
    let xShort: Bool
    let yShort: Bool
    let repeating: Bool
    let xInstruction: Bool
    let yInstruction: Bool
    
//    let _reserved6: Bool
//    let _reserved7: Bool
    
    init (_ byte: UInt8) {
        onCurve = byte.isBitSet(at: 0)
        xShort = byte.isBitSet(at: 1)
        yShort = byte.isBitSet(at: 2)
        repeating = byte.isBitSet(at: 3)
        xInstruction = byte.isBitSet(at: 4)
        yInstruction = byte.isBitSet(at: 5)
//        _reserved6 = byte.isBitSet(at: 6)
//        _reserved7 = byte.isBitSet(at: 7)
        self.rawValue = byte
    }
}

public struct SimpleGlyphTableComputed {
    public let expandedFlags: [SimpleGlyphCoordinateFlag]
}

public struct SimpleGlyphTable: Identifiable, Equatable {
    public let id: UUID = UUID()
    public let numberOfContours: Int16
    public let xMin: Int16
    public let yMin: Int16
    public let xMax: Int16
    public let yMax: Int16
    public let endPtsOfContours: [Int]
    public let instructionLength: Int16
    public let instructions: [UInt8]
    public let flags: [UInt8]
    public let xCoordinates: [Int]
    public let yCoordinates: [Int]
    
    let computed: SimpleGlyphTableComputed
    
    let tableLength: Int
    
    init(_ bytes: Data) throws {
        var read: ReadHead = ReadHead(bytes, index: 0)
        
        let contoursCount = try read.value(ofType: Int16.self)
        
        guard contoursCount >= 0 else {
            throw GlyphValidationError("Expected Simple Glyph Data but received a Compound Glyph insted")
        }
        
        xMin = try read.value(ofType: Int16.self)
        yMin = try read.value(ofType: Int16.self)
        xMax = try read.value(ofType: Int16.self)
        yMax = try read.value(ofType: Int16.self)
        
        var endPtsOfContours = Array(repeating: 0, count: Int(contoursCount))
        
        for i in 0..<Int(contoursCount) {
            let contourEndIndex = Int(try read.value(ofType: UInt16.self))
            endPtsOfContours[i] = contourEndIndex
        }
        
        
        guard let numOfPoints = endPtsOfContours.last else {
            throw SimpleGlyphValidationError("Empty Contours")
        }
        
        self.endPtsOfContours = endPtsOfContours
        
        instructionLength = try read.value(ofType: Int16.self)
        instructions = try read.values(ofType: UInt8.self, withSize: Int(instructionLength))
        
        var expandedFlags: [SimpleGlyphCoordinateFlag] = []
        var rawFlags: [UInt8] = []
        var i = 0
        
        repeat {
            let flagByte = try read.value(ofType: UInt8.self)
            let flag = SimpleGlyphCoordinateFlag(flagByte)
            
            rawFlags.append(flagByte)
            expandedFlags.append(flag)
            
            if flag.repeating {
                let repeatCount = try read.value(ofType: UInt8.self)
                rawFlags.append(repeatCount)
                i += 1
                
                for _ in 0..<repeatCount {
                    expandedFlags.append(flag)
                    i+=1
                }
                
                continue
            }
            
            i += 1
        } while(i <= numOfPoints)
        
        flags = rawFlags
        xCoordinates = try readCoordinates(&read, flags: expandedFlags, axis: .X)
        yCoordinates = try readCoordinates(&read, flags: expandedFlags, axis: .Y)
        
        numberOfContours = contoursCount
        
        computed = .init(expandedFlags: expandedFlags)
        tableLength = read.index
    }
    
    public static func == (lhs: SimpleGlyphTable, rhs: SimpleGlyphTable) -> Bool {
        return lhs.id == rhs.id
    }
}
