//
//  MaxpTable.swift
//
//
//  Created by Jefferson Oliveira on 4/27/24.
//

import Foundation


public struct MaxpTable {
    public let version: UInt32
    public let numGlyphs: UInt16
    public let maxPoints: UInt16
    public let maxContours: UInt16
    public let maxComponentPoints: UInt16
    public let maxComponentContours: UInt16
    public let maxZones: UInt16
    public let maxTwilightPoints: UInt16
    public let maxStorage: UInt16
    public let maxFunctionDefs: UInt16
    public let maxInstructionDefs: UInt16
    public let maxStackElements: UInt16
    public let maxSizeOfInstructions: UInt16
    public let maxComponentElements: UInt16
    public let maxComponentDepth: UInt16
    
    let tableLength: Int
    
    init(bytes: Data) throws {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        version = try read.value(ofType: UInt32.self)
        numGlyphs = try read.value(ofType: UInt16.self)
        maxPoints = try read.value(ofType: UInt16.self)
        maxContours = try read.value(ofType: UInt16.self)
        maxComponentPoints = try read.value(ofType: UInt16.self)
        maxComponentContours = try read.value(ofType: UInt16.self)
        maxZones = try read.value(ofType: UInt16.self)
        maxTwilightPoints = try read.value(ofType: UInt16.self)
        maxStorage = try read.value(ofType: UInt16.self)
        maxFunctionDefs = try read.value(ofType: UInt16.self)
        maxInstructionDefs = try read.value(ofType: UInt16.self)
        maxStackElements = try read.value(ofType: UInt16.self)
        maxSizeOfInstructions = try read.value(ofType: UInt16.self)
        maxComponentElements = try read.value(ofType: UInt16.self)
        maxComponentDepth = try read.value(ofType: UInt16.self)
    
        tableLength = read.index
    }
}

