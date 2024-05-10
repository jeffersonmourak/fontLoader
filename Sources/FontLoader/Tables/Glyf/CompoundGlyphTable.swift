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
    public let transformMatrix: LinearTransform
    
    let tableLength: Int
    
    init(_ bytes: Data) throws {
        let read: ReadHead = ReadHead(bytes, index: 0)
        let flags = try read.value(ofType: UInt16.self)
        glyphIndex = try read.value(ofType: UInt16.self)
        flag = CompoundFlag(flags)
        
        if !flag.argsAreXYValues {
            throw GlyphValidationError("OFFSET INDEX TO IMPLEMENT")
        }
        
        offsetX = flag.argsAreWords ? try read.value(ofType: Int16.self) : Int16(try read.value(ofType: Int8.self))
        offsetY = flag.argsAreWords ? try read.value(ofType: Int16.self) : Int16(try read.value(ofType: Int8.self))
        
        var transformIHat: CGPoint = LinearTransform.defaultIHat
        var transformJHat: CGPoint = LinearTransform.defaultJHat
        
        if flag.weHaveAScale {
            let scale = try read.valueF2Dot14()
            
            transformIHat = .init(x: scale, y: transformIHat.y)
            transformJHat = .init(x: transformJHat.x, y: scale)
            
        } else if flag.weHaveAnXAndYScale {
            let ixScale = try read.valueF2Dot14()
            let jyScale = try read.valueF2Dot14()
            
            transformIHat = .init(x: ixScale, y: transformIHat.y)
            transformJHat = .init(x: transformJHat.x, y: jyScale)
            
        } else if flag.weHaveATwoByTwo {
            let ixHat = try read.valueF2Dot14()
            let iyHat = try  read.valueF2Dot14()
            let jxHat = try read.valueF2Dot14()
            let jyHat = try  read.valueF2Dot14()
            
            transformIHat = .init(x: ixHat, y: iyHat)
            transformJHat = .init(x: jxHat, y: jyHat)
        }
        
        transformMatrix = .init(transformIHat, transformJHat, withOffset: .init(x: Double(offsetX), y: Double(offsetY)))
        
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
        
        numberOfContours = try read.value(ofType: Int16.self)
        
        guard numberOfContours < 0 else {
            throw GlyphValidationError("Expected Compound Glyph Data but received a Simple Glyph insted")
        }
        
        xMin = try read.value(ofType: UInt16.self)
        yMin = try read.value(ofType: UInt16.self)
        xMax = try read.value(ofType: UInt16.self)
        yMax = try read.value(ofType: UInt16.self)
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
