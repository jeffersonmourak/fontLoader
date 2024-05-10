//
//  HheaTable.swift
//
//
//  Created by Jefferson Oliveira on 5/5/24.
//

import Foundation


public struct LongHorMetric {
    public let advanceWidth: UInt16
    public let leftSideBearing: Int16
};


public struct HmtxTable {
    public let hMetrics: [LongHorMetric]
    public let leftSideBearing: [FWord]
    
    let tableLength: Int
    
    init(bytes: Data, numOfLongHorMetrics: Int, numOfGlyphs: Int) throws {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        do {
            var hMetrics: [LongHorMetric] = []
            
            for _ in 0..<numOfLongHorMetrics {
                hMetrics.append(.init(advanceWidth: try read.value(ofType: UInt16.self), leftSideBearing: try read.value(ofType: Int16.self)))
            }
            
            self.hMetrics = hMetrics
            
            
            var leftSideBearings: [FWord] = []
            
            for _ in 0..<(numOfGlyphs - numOfLongHorMetrics) {
                leftSideBearings.append(try read.value(ofType: FWord.self))
            }
            
            self.leftSideBearing = leftSideBearings
        } catch {
            throw error
        }
        
        
        tableLength = read.index
    }
}

