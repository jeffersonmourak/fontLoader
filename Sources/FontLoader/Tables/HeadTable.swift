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
    
    init(bytes: Data) throws {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        version = try read.value(ofType: UInt32.self)
        fontRevision = try read.value(ofType: UInt32.self)
        checkSumAdjustment = try read.value(ofType: UInt32.self)
        magicNumber = try read.value(ofType: UInt32.self)
        flags = try read.value(ofType: UInt16.self)
        unitsPerEm = try read.value(ofType: UInt16.self)
        created = try read.value(ofType: UInt64.self)
        modified = try read.value(ofType: UInt64.self)
        xMin = try read.value(ofType: Int16.self)
        yMin = try read.value(ofType: Int16.self)
        xMax = try read.value(ofType: Int16.self)
        yMax = try read.value(ofType: Int16.self)
        macStyle = try read.value(ofType: UInt16.self)
        lowestRecPPEM = try read.value(ofType: UInt16.self)
        fontDirectionHint = try read.value(ofType: Int16.self)
        indexToLocFormat = try read.value(ofType: Int16.self)
        glyphDataFormat = try read.value(ofType: Int16.self)

        
        tableLength = read.index
    }
}
