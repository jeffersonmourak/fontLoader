//
//  Glyph.swift
//
//
//  Created by Jefferson Oliveira on 5/5/24.
//

import Foundation


public struct GlyphLayout {
    public let fontBoundaries: (CGPoint, CGPoint)
    public let horizontalMetrics: LongHorMetric
}

func getGlyphMagntude(_ glyph: SimpleGlyphTable) -> (Int16, Int16) {
    return (glyph.xMax - glyph.xMin, glyph.yMax - glyph.yMin)
}

func buildGlyphPoints(from glyphs: [SimpleGlyphTable], layout: GlyphLayout) -> (Area<Int16>, [[Point<Int>]], Int){
    guard glyphs.count > 0 else {
        return (.zero, [], 0)
    }

    var coords: [Point<Int>] = []
    var contoursList: [[Point<Int>]] = []
    var baseLineDistance = 0
    
    let (initialXMagnitude, initialYMagnitude) = getGlyphMagntude(glyphs[0])
    
    var totalGlyphArea = Area(
        begin: .init(x: glyphs[0].xMin, y: glyphs[0].yMin),
        end: .init(x: initialXMagnitude, y: initialYMagnitude)
    )
    
    for glyph in glyphs {
        let (xMagnitude, yMagnitude) = getGlyphMagntude(glyph)
        
        let currentGlyphArea = Area(
            begin: .init(x: glyph.xMin, y: glyph.yMin),
            end: .init(x: xMagnitude, y: yMagnitude)
        )
        
        totalGlyphArea = totalGlyphArea.reshape(with: currentGlyphArea)
    

        for i in 0..<glyph.xCoordinates.count {
            let x = glyph.xCoordinates[i]
            let y = glyph.yCoordinates[i]
            
            if (y < baseLineDistance) {
                baseLineDistance = y
            }
            
            coords.append(Point(x, y))
        }
        
        var nextSegmentIndex = 0
        var beginOfContour: Int = 0
        
        var contourPoints: [Point<Int>] = [coords[0]]
        
        
        for i in 1..<coords.count {
            let current = coords[i]
            let nextSegment = nextSegmentIndex < glyph.endPtsOfContours.count ? glyph.endPtsOfContours[nextSegmentIndex] : glyph.endPtsOfContours.last!
            
            contourPoints.append(current)
            
            if (i == nextSegment) {
                contourPoints.append(coords[beginOfContour])
                contoursList.append(contourPoints)
                contourPoints = []
                beginOfContour = nextSegment + 1
                nextSegmentIndex += 1
            }
        }
        
    }
    
    return (totalGlyphArea, contoursList, abs(baseLineDistance))
}

public struct GlyphContour {
    public let endPtsOfContours: [Int]
    public let points: [CGPoint]
    public let boundaries: (CGPoint, CGPoint)
}

public struct Glyph {
    private let bytes: Data
    private let locations: [Int]
    public let fontLayout: GlyphLayout
    
    public let glyphBox: Area<Int16>
    public let contours: [[Point<Int>]]
    public let baseLineDistance: Int
    
    init(_ glyph: GlyfTable, using bytes: Data, withLocation locations: [Int], layout: GlyphLayout) {
        self.bytes = bytes
        self.locations = locations
        self.fontLayout = layout
        
        switch glyph {
            case let .simple(glyph):
                (glyphBox, contours, baseLineDistance) = buildGlyphPoints(from: [glyph], layout: layout)
            
            
            case let .compound(glyph):
                var glyphs: [SimpleGlyphTable] = []
                
                for currentGlyph in glyph.glyphs {
                    let glyphIndex = Int(currentGlyph.glyphIndex)
                    let glyphLocationOffset = Int(locations[glyphIndex])
                    
                    let glyphBytes = bytes.advanced(by: glyphLocationOffset)
                    
                    do {
                        
                        let offset = CGPoint(x: Double(currentGlyph.offsetX), y: Double(currentGlyph.offsetY))
                        let simpleGlyphData = try SimpleGlyphTable(glyphBytes, withOffset: offset)
                        
                        glyphs.append(simpleGlyphData)
                    } catch {
                        glyphs.append(try! SimpleGlyphTable(bytes))
                    }
                }
            
            
                (glyphBox, contours, baseLineDistance) = buildGlyphPoints(from: glyphs, layout: layout)
        }
    }
    
    
    static public func getGlyphLayout() {}
}
