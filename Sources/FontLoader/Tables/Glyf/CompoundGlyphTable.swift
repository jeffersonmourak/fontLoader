//
//  CompoundGlyphTable.swift
//
//
//  Created by Jefferson Oliveira on 5/5/24.
//

import Foundation

public struct CompoundFlag {
    let byte: UInt16
    let argsAreWords: Bool
    let argsAreXYValues: Bool
    let roundXYToGrid: Bool
    let weHaveAScale: Bool
    let _obsolete: Bool
    let moreComponents: Bool
    let weHaveAnXAndYScale: Bool
    let weHaveATwoByTwo: Bool
    let weHaveAInstructions: Bool
    let useMyMetrics: Bool
    let overlapCompound: Bool
    
    init (_ byte: UInt16) {
        argsAreWords = byte.isBitSet(at: 0)
        argsAreXYValues = byte.isBitSet(at: 1)
        roundXYToGrid = byte.isBitSet(at: 2)
        weHaveAScale = byte.isBitSet(at: 3)
        _obsolete = byte.isBitSet(at: 4)
        moreComponents = byte.isBitSet(at: 5)
        weHaveAnXAndYScale = byte.isBitSet(at: 6)
        weHaveATwoByTwo = byte.isBitSet(at: 7)
        weHaveAInstructions = byte.isBitSet(at: 8)
        useMyMetrics = byte.isBitSet(at: 9)
        overlapCompound = byte.isBitSet(at: 10)

        self.byte = byte
    }
}

public struct CompoundGlyphItem {
    public let flag: CompoundFlag
    public let glyphIndex: UInt16
    public let offsetX: Int16
    public let offsetY: Int16
    public var scaleX: UInt16
    public var scaleY: UInt16
    
    let tableLength: Int
    
    init(_ bytes: Data) throws {
        let read: ReadHead = ReadHead(bytes, index: 0)
        let flags = read.value(ofType: UInt16.self)!
        glyphIndex = read.value(ofType: UInt16.self)!
        flag = CompoundFlag(flags)
        
        if !flag.argsAreXYValues {
            throw GlyphValidationError("OFFSET INDEX TO IMPLEMENT")
        }
        
        offsetX = flag.argsAreWords ? read.value(ofType: Int16.self)! : Int16(read.value(ofType: Int8.self)!)
        offsetY = flag.argsAreWords ? read.value(ofType: Int16.self)! : Int16(read.value(ofType: Int8.self)!)
        var scaleX: UInt16 = 1
        var scaleY: UInt16 = 1
        
        if flag.weHaveAScale {
            scaleX = read.value(ofType: UInt16.self)!
        } else if flag.weHaveAnXAndYScale {
            scaleX = read.value(ofType: UInt16.self)!
            scaleY = read.value(ofType: UInt16.self)!
        } else if flag.weHaveATwoByTwo {
            throw FontValidationError(" 2x2 fonts")
        }
        
        self.scaleX = scaleX
        self.scaleY = scaleY
        
        tableLength = read.index
    }
}

public struct CompoundGlyphTable: Identifiable, Equatable {
    public let id: UUID = UUID()
    public let numberOfContours: Int16
    public let xMin: UInt16
    public let yMin: UInt16
    public let xMax: UInt16
    public let yMax: UInt16
    public let glyphs: [CompoundGlyphItem]
    
    let tableLength: Int
    
    init(_ bytes: Data) throws {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        numberOfContours = read.value(ofType: Int16.self)!
        
        guard numberOfContours < 0 else {
            throw GlyphValidationError("Expected Compound Glyph Data but received a Simple Glyph insted")
        }
        
        xMin = read.value(ofType: UInt16.self)!
        yMin = read.value(ofType: UInt16.self)!
        xMax = read.value(ofType: UInt16.self)!
        yMax = read.value(ofType: UInt16.self)!
        do {
            var glyphList: [CompoundGlyphItem] = []
            var haveMoreFlags = true
            repeat {
                let currentGlyph = try CompoundGlyphItem(bytes.advanced(by: read.index))
                read.advance(by: currentGlyph.tableLength)
                
                glyphList.append(currentGlyph)
                
                haveMoreFlags = currentGlyph.flag.moreComponents
            } while (haveMoreFlags)
            
            glyphs = glyphList
        } catch {
            throw error
        }
        
        tableLength = read.index
    }
    
    public static func == (lhs: CompoundGlyphTable, rhs: CompoundGlyphTable) -> Bool {
        return lhs.id == rhs.id
    }
}
