//
//  HheaTable.swift
//
//
//  Created by Jefferson Oliveira on 5/5/24.
//

import Foundation


public struct HheaTable {
    public let version: Fixed;
    public let ascent: FWord;
    public let descent: FWord;
    public let lineGap: FWord;
    public let advanceWidthMax: uFWord;
    public let minLeftSideBearing: FWord;
    public let minRightSideBearing: FWord;
    public let xMaxExtent: FWord;
    public let caretSlopeRise: Int16;
    public let caretSlopeRun: Int16;
    public let caretOffset: FWord;
    public let _reserved0: Int16;
    public let _reserved1: Int16;
    public let _reserved2: Int16;
    public let _reserved3: Int16;
    public let metricDataFormat: Int16;
    public let numOfLongHorMetrics: UInt16;
    
    let tableLength: Int
    
    init(bytes: Data) {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        version = read.value(ofType: Fixed.self)!
        ascent = read.value(ofType: FWord.self)!
        descent = read.value(ofType: FWord.self)!
        lineGap = read.value(ofType: FWord.self)!
        advanceWidthMax = read.value(ofType: uFWord.self)!
        minLeftSideBearing = read.value(ofType: FWord.self)!
        minRightSideBearing = read.value(ofType: FWord.self)!
        xMaxExtent = read.value(ofType: FWord.self)!
        caretSlopeRise = read.value(ofType: Int16.self)!
        caretSlopeRun = read.value(ofType: Int16.self)!
        caretOffset = read.value(ofType: FWord.self)!
        _reserved0 = read.value(ofType: Int16.self)!
        _reserved1 = read.value(ofType: Int16.self)!
        _reserved2 = read.value(ofType: Int16.self)!
        _reserved3 = read.value(ofType: Int16.self)!
        metricDataFormat = read.value(ofType: Int16.self)!
        numOfLongHorMetrics = read.value(ofType: UInt16.self)!
    
        tableLength = read.index
    }
}

