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

public struct GlyphContours {
    public let points: [CGPoint]
    public let boundaries: (CGPoint, CGPoint)
    public let glyphBox: (CGPoint, CGPoint)
}

func getBoxPointsData(glyph: SimpleGlyphTable, layout: GlyphLayout) -> GlyphContours{
    var coords: [CGPoint] = []
    
    let xMagnitude = abs(Double(glyph.xMin)) + Double(glyph.xMax)
    let yMagnitude = abs(Double(glyph.yMin)) + Double(glyph.yMax)
    
    let advanceWidth = Double(layout.horizontalMetrics.advanceWidth)
    
    let glyphBoxMin = CGPoint(x: Double(glyph.xMin), y: Double(glyph.yMin))
    let glyphBoxMax = CGPoint(x: advanceWidth, y: yMagnitude)

    for i in 0..<glyph.xCoordinates.count {
        let x = Double(glyph.xCoordinates[i])
        let y = yMagnitude - Double(glyph.yCoordinates[i])
        
        coords.append(CGPoint(x: x, y: y))
    }
    
    var nextSegmentIndex = 0
    var beginOfContour: Int = 0
    
    var contourPoints: [CGPoint] = [coords[0]]
    
    var contoursList: [[CGPoint]] = []
    
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
    
  
    
    return .init(points: coords, boundaries: layout.fontBoundaries, glyphBox: (glyphBoxMin, glyphBoxMax))
}

public struct Glyph {
    private let bytes: Data
    private let locations: [Int]
    public let fontLayout: GlyphLayout
    public let contours: GlyphContours
    public let simpleGlyph: SimpleGlyphTable
    
    init(_ glyph: GlyfTable, using bytes: Data, withLocation locations: [Int], layout: GlyphLayout) {
        self.bytes = bytes
        self.locations = locations
        self.fontLayout = layout
        
        switch glyph {
            case let .simple(glyph):
                contours = getBoxPointsData(glyph: glyph, layout: layout)
                simpleGlyph = glyph
            case let .compound(glyph):
            let firstGlyph = glyph.glyphs[0]
           
            
            let glyphBytes = bytes.advanced(by: Int(locations[Int(firstGlyph.glyphIndex)]))
            do {
                let glyph = try SimpleGlyphTable(glyphBytes)
                simpleGlyph = glyph
                contours = getBoxPointsData(glyph: glyph, layout: layout)
            } catch {
                contours = .init(points: [], boundaries: layout.fontBoundaries, glyphBox: (CGPoint(x: .zero, y: .zero), CGPoint(x: .zero, y: .zero)))
                let glyphBytes = bytes.advanced(by: 0)
                let glyph = try! SimpleGlyphTable(glyphBytes)
                simpleGlyph = glyph
                
                print(error)
            }
        }
    }
    
    
    static public func getGlyphLayout() {}
}
