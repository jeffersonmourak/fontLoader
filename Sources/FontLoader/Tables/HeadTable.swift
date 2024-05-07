//
//  HeadTable.swift
//
//
//  Created by Jefferson Oliveira on 4/27/24.
//

import Foundation

public struct HeadTable {
    public let version: UInt32
    public let fontRevision: UInt32
    public let checkSumAdjustment: UInt32
    public let magicNumber: UInt32
    public let flags: UInt16
    public let unitsPerEm: UInt16
    public let created: UInt64
    public let modified: UInt64
    public let xMin: Int16
    public let yMin: Int16
    public let xMax: Int16
    public let yMax: Int16
    public let macStyle: UInt16
    public let lowestRecPPEM: UInt16
    public let fontDirectionHint: Int16
    public let indexToLocFormat: Int16
    public let glyphDataFormat: Int16
    
    public let tableLength: Int
    
    init(bytes: Data) {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        version = read.value(ofType: UInt32.self)!
        fontRevision = read.value(ofType: UInt32.self)!
        checkSumAdjustment = read.value(ofType: UInt32.self)!
        magicNumber = read.value(ofType: UInt32.self)!
        flags = read.value(ofType: UInt16.self)!
        unitsPerEm = read.value(ofType: UInt16.self)!
        created = read.value(ofType: UInt64.self)!
        modified = read.value(ofType: UInt64.self)!
        xMin = read.value(ofType: Int16.self)!
        yMin = read.value(ofType: Int16.self)!
        xMax = read.value(ofType: Int16.self)!
        yMax = read.value(ofType: Int16.self)!
        macStyle = read.value(ofType: UInt16.self)!
        lowestRecPPEM = read.value(ofType: UInt16.self)!
        fontDirectionHint = read.value(ofType: Int16.self)!
        indexToLocFormat = read.value(ofType: Int16.self)!
        glyphDataFormat = read.value(ofType: Int16.self)!
        
        tableLength = read.index
    }
}
