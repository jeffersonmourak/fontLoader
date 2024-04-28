//
//  HeadTable.swift
//
//
//  Created by Jefferson Oliveira on 4/27/24.
//

import Foundation

public struct HeadTable {
    let version: UInt32
    let fontRevision: UInt32
    let checkSumAdjustment: UInt32
    let magicNumber: UInt32
    let flags: UInt16
    let unitsPerEm: UInt16
    let created: UInt64
    let modified: UInt64
    let xMin: UInt16
    let yMin: UInt16
    let xMax: UInt16
    let yMax: UInt16
    let macStyle: UInt16
    let lowestRecPPEM: UInt16
    let fontDirectionHint: Int16
    let indexToLocFormat: Int16
    let glyphDataFormat: Int16
    
    let tableLength: Int
    
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
        xMin = read.value(ofType: UInt16.self)!
        yMin = read.value(ofType: UInt16.self)!
        xMax = read.value(ofType: UInt16.self)!
        yMax = read.value(ofType: UInt16.self)!
        macStyle = read.value(ofType: UInt16.self)!
        lowestRecPPEM = read.value(ofType: UInt16.self)!
        fontDirectionHint = read.value(ofType: Int16.self)!
        indexToLocFormat = read.value(ofType: Int16.self)!
        glyphDataFormat = read.value(ofType: Int16.self)!
        
        tableLength = read.index
    }
}
