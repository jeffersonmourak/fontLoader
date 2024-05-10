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
    
    init(bytes: Data) throws {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        version = try read.value(ofType: Fixed.self)
        ascent = try read.value(ofType: FWord.self)
        descent = try read.value(ofType: FWord.self)
        lineGap = try read.value(ofType: FWord.self)
        advanceWidthMax = try read.value(ofType: uFWord.self)
        minLeftSideBearing = try read.value(ofType: FWord.self)
        minRightSideBearing = try read.value(ofType: FWord.self)
        xMaxExtent = try read.value(ofType: FWord.self)
        caretSlopeRise = try read.value(ofType: Int16.self)
        caretSlopeRun = try read.value(ofType: Int16.self)
        caretOffset = try read.value(ofType: FWord.self)
        _reserved0 = try read.value(ofType: Int16.self)
        _reserved1 = try read.value(ofType: Int16.self)
        _reserved2 = try read.value(ofType: Int16.self)
        _reserved3 = try read.value(ofType: Int16.self)
        metricDataFormat = try read.value(ofType: Int16.self)
        numOfLongHorMetrics = try read.value(ofType: UInt16.self)
    
        tableLength = read.index
    }
}

