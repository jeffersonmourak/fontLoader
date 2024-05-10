//
//  GlyfTable.swift
//
//
//  Created by Jefferson Oliveira on 5/5/24.
//

import Foundation


public enum GlyfTable {
    init(_ bytes: Data) throws {
        do {
            let contoursCount = try bytes.value(ofType: Int16.self, at: 0)
            
            if contoursCount < 0 {
                self = .compound(try CompoundGlyphTable(bytes))
            } else {
                self = .simple(try SimpleGlyphTable(bytes))
            }
        } catch {
            throw error
        }
    }
    case simple(SimpleGlyphTable)
    case compound(CompoundGlyphTable)
}
