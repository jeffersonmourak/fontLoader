//
//  GlyphDescriptionTable.swift
//
//
//  Created by Jefferson Oliveira on 4/27/24.
//

import Foundation

struct GlyphValidationError : LocalizedError {
    let description: String
    
    init (_ description: String) {
        self.description = description
    }
    
    var errorDescription: String? {
        description
    }
}

public struct GlyphDescriptionTable {
    let numberOfContours: UInt16
    let xMin: Int16
    let yMin: Int16
    let xMax: Int16
    let yMax: Int16
    
    let tableLength: Int
    
    init(bytes: Data) {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        numberOfContours = read.value(ofType: UInt16.self)!
        xMin = read.value(ofType: Int16.self)!
        yMin = read.value(ofType: Int16.self)!
        xMax = read.value(ofType: Int16.self)!
        yMax = read.value(ofType: Int16.self)!
        tableLength = read.index
    }
}
