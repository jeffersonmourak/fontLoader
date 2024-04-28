//
//  GlyphDescriptionTable.swift
//
//
//  Created by Jefferson Oliveira on 4/27/24.
//

import Foundation

struct GlyphValidationError : LocalizedError {
    let description: String
    
    init (_ description: String) {
        self.description = description
    }
    
    var errorDescription: String? {
        description
    }
}

public struct GlyphDescriptionTable {
    let numberOfContours: UInt16
    let xMin: UInt16
    let yMin: UInt16
    let xMax: UInt16
    let yMax: UInt16
    
    let tableLength: Int
    
    init(bytes: Data) {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        numberOfContours = read.value(ofType: UInt16.self)!
        xMin = read.value(ofType: UInt16.self)!
        yMin = read.value(ofType: UInt16.self)!
        xMax = read.value(ofType: UInt16.self)!
        yMax = read.value(ofType: UInt16.self)!
        tableLength = read.index
    }
    
}

public struct OutlineFlag {
    let byte: UInt8
    let onCurve: Bool
    let xShort: Bool
    let yShort: Bool
    let repeating: Bool
    let xSkipOrSign: Bool
    let ySkipOrSign: Bool
    
//    let _reserved6: Bool
//    let _reserved7: Bool
    
    init (_ byte: UInt8) {
        onCurve = byte.isBitSet(at: 0)
        xShort = byte.isBitSet(at: 1)
        yShort = byte.isBitSet(at: 2)
        repeating = byte.isBitSet(at: 3)
        xSkipOrSign = byte.isBitSet(at: 4)
        ySkipOrSign = byte.isBitSet(at: 5)
//        _reserved6 = byte.isBitSet(at: 6)
//        _reserved7 = byte.isBitSet(at: 7)
        self.byte = byte
    }
    
    func isBitSet(at: Int) -> Bool {
        return byte.isBitSet(at: at)
    }
    
    static func parse(_ value: UInt8) -> Self {
        return .init(value)
    }
    
    static func parse(_ values: [UInt8]) -> [Self] {
        var flagsList: [OutlineFlag] = Array(repeating: OutlineFlag(0), count: values.count)
        
        for var i in 0..<values.count {
            let flag = OutlineFlag(values[i])
            flagsList[i] = flag
            
            if (flag.repeating && i < values.count - 1) {
                let repeatCount = values[i+1]
                
                for _ in 0..<repeatCount {
                    i += 1
                    if (i >= values.count) {
                        break
                    }
                    
                    flagsList[i] = flag;
                }
            }
        }
        
        return flagsList
    }
}

protocol AxisOutlineFlag {
    var outlineFlag: OutlineFlag { get }
    var sign: Int { get }
    var skip: Bool { get }
    var is16Bit: Bool { get }
}

struct XOutlineFlag: AxisOutlineFlag {
    let outlineFlag: OutlineFlag
    
    init(_ outlineFlag: OutlineFlag) {
        self.outlineFlag = outlineFlag
    }
    
    var sign: Int {
        get {
            return outlineFlag.xShort ? outlineFlag.xSkipOrSign ? 1 : -1 : 0
        }
    }
    
    var skip: Bool {
        get {
            return outlineFlag.xSkipOrSign && !outlineFlag.xShort
        }
    }
    
    var is16Bit: Bool {
        get {
            !outlineFlag.xSkipOrSign && !outlineFlag.xShort
        }
    }
}

struct YOutlineFlag: AxisOutlineFlag {
    let outlineFlag: OutlineFlag
    
    init(_ outlineFlag: OutlineFlag) {
        self.outlineFlag = outlineFlag
    }
    
    var sign: Int {
        get {
            return outlineFlag.yShort ? outlineFlag.ySkipOrSign ? 1 : -1 : 0
        }
    }
    
    var skip: Bool {
        get {
            return outlineFlag.ySkipOrSign && !outlineFlag.yShort
        }
    }
    
    var is16Bit: Bool {
        get {
            !outlineFlag.ySkipOrSign && !outlineFlag.yShort
        }
    }
}

enum FlagDirection {
    case X
    case Y
}

func readCoordinates(_ read: inout ReadHead, flags rawFlags: [UInt8], axis: FlagDirection) -> [Int] {
    var coordinates: [Int] = Array(repeating: 0, count: rawFlags.count)
    let flags = OutlineFlag.parse(rawFlags)

    var i = 0
    while (i < coordinates.count) {
        coordinates[i] = coordinates[max(0, i - 1)]
        let flag: AxisOutlineFlag = axis == FlagDirection.X ? XOutlineFlag(flags[i]) : YOutlineFlag(flags[i])
    
        
        if (flag.skip) {
            i += 1
            continue
        }
        
        if (flag.is16Bit) {
            coordinates[i] += Int(read.value(ofType: Int16.self)!)
            i += 1
            continue
        }
        
        let sign : Int = flag.sign
        coordinates[i] += Int(read.value(ofType: UInt8.self)!) * sign
        i += 1
        continue
        
    }
    
    return coordinates
}

public struct SimpleGlyphTable: Identifiable, Equatable {
    public let id: UUID = UUID()
    public let numberOfContours: Int16
    public let xMin: UInt16
    public let yMin: UInt16
    public let xMax: UInt16
    public let yMax: UInt16
    public let endPtsOfContours: [Int]
    public let instructionLength: Int16
    public let instructions: [UInt8]
    public let flags: [UInt8]
    public let xCoordinates: [Int]
    public let yCoordinates: [Int]
    
    let tableLength: Int
    
    init(_ bytes: Data) throws {
        var read: ReadHead = ReadHead(bytes, index: 0)
        
        numberOfContours = read.value(ofType: Int16.self)!
        
        guard numberOfContours >= 0 else {
            throw GlyphValidationError("Expected Simple Glyph Data but received a Complex Glyph insted")
        }
        
        xMin = read.value(ofType: UInt16.self)!
        yMin = read.value(ofType: UInt16.self)!
        xMax = read.value(ofType: UInt16.self)!
        yMax = read.value(ofType: UInt16.self)!
        
        var numOfPoints = 0
        var endPtsOfContours = Array(repeating: 0, count: Int(numberOfContours))
        
        for i in 0..<Int(numberOfContours) {
            let contourEndIndex = Int(read.value(ofType: UInt16.self)!)
            numOfPoints = max(numOfPoints, contourEndIndex + 1);
            endPtsOfContours[i] = contourEndIndex
        }
        
        self.endPtsOfContours = endPtsOfContours
        
        instructionLength = read.value(ofType: Int16.self)!
        instructions = read.values(ofType: UInt8.self, withSize: Int(instructionLength))
        
        flags = read.values(ofType: UInt8.self, withSize: numOfPoints)
    
        xCoordinates = readCoordinates(&read, flags: flags, axis: .X)
        yCoordinates = readCoordinates(&read, flags: flags, axis: .Y)
        
        tableLength = read.index
    }
    
    public static func == (lhs: SimpleGlyphTable, rhs: SimpleGlyphTable) -> Bool {
        return lhs.id == rhs.id
    }
}
