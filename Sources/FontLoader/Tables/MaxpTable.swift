//
//  MaxpTable.swift
//
//
//  Created by Jefferson Oliveira on 4/27/24.
//

import Foundation


public struct MaxpTable {
    let version: UInt32
    let numGlyphs: UInt16
    let maxPoints: UInt16
    let maxContours: UInt16
    let maxComponentPoints: UInt16
    let maxComponentContours: UInt16
    let maxZones: UInt16
    let maxTwilightPoints: UInt16
    let maxStorage: UInt16
    let maxFunctionDefs: UInt16
    let maxInstructionDefs: UInt16
    let maxStackElements: UInt16
    let maxSizeOfInstructions: UInt16
    let maxComponentElements: UInt16
    let maxComponentDepth: UInt16
    
    let tableLength: Int
    
    init(bytes: Data) {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        version = read.value(ofType: UInt32.self)!
        numGlyphs = read.value(ofType: UInt16.self)!
        maxPoints = read.value(ofType: UInt16.self)!
        maxContours = read.value(ofType: UInt16.self)!
        maxComponentPoints = read.value(ofType: UInt16.self)!
        maxComponentContours = read.value(ofType: UInt16.self)!
        maxZones = read.value(ofType: UInt16.self)!
        maxTwilightPoints = read.value(ofType: UInt16.self)!
        maxStorage = read.value(ofType: UInt16.self)!
        maxFunctionDefs = read.value(ofType: UInt16.self)!
        maxInstructionDefs = read.value(ofType: UInt16.self)!
        maxStackElements = read.value(ofType: UInt16.self)!
        maxSizeOfInstructions = read.value(ofType: UInt16.self)!
        maxComponentElements = read.value(ofType: UInt16.self)!
        maxComponentDepth = read.value(ofType: UInt16.self)!
    
        tableLength = read.index
    }
}

