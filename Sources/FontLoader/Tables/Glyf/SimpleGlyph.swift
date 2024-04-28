//
//  SimpleGlyph.swift
//
//
//  Created by Jefferson Oliveira on 4/22/24.
//

import Foundation



class SimpleGlyph {
    let bytes: Data
    let data: SimpleGlyphTable
    
    init(_ bytes: Data) throws {
        self.bytes = bytes
        self.data = try SimpleGlyphTable(bytes)
    }
    
    func getEndPoints(_ bytes: Data) -> [UInt16] {
        
        return []
    }
}
