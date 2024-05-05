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
            self = .simple(try SimpleGlyphTable(bytes))
        } catch {
            do {
                self = .compound(try CompoundGlyphTable(bytes))
            } catch {
                throw error
            }
        }
    }
    case simple(SimpleGlyphTable)
    case compound(CompoundGlyphTable)
}
