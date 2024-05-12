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

typealias TransformedGlyph = (SimpleGlyphTable, LinearTransform)

func getGlyphMagntude(_ glyph: SimpleGlyphTable) -> (Int16, Int16) {
    return (glyph.xMax - glyph.xMin, glyph.yMax - glyph.yMin)
}

public struct GlyphArea {
    public let xMin: Double
    public let xMax: Double
    public let yMin: Double
    public let yMax: Double
    
    static var zero: Self {
        get {
            return .init(xMin: 0, xMax: 0, yMin: 0, yMax: 0)
        }
    }
}

func buildGlyphPoints(from glyphs: [TransformedGlyph]) -> (GlyphArea, [[CGPoint]], Int){
    guard glyphs.count > 0 else {
        return (.zero, [], 0)
    }

    var contoursList: [[CGPoint]] = []
    var baseLineDistance = 0
    
    let (firstGlyph, _) = glyphs[0]
    
    let (initialXMagnitude, initialYMagnitude) = getGlyphMagntude(firstGlyph)
    
  
    
    var xMin: Double = Double.infinity
    var xMax: Double = -Double.infinity
    var yMin: Double = Double.infinity
    var yMax: Double = -Double.infinity
    
    for (glyph, transform) in glyphs {
        let (xMagnitude, yMagnitude) = getGlyphMagntude(glyph)
        
        var coords: [CGPoint] = []
        for i in 0..<glyph.xCoordinates.count {
            let x = glyph.xCoordinates[i]
            let y = glyph.yCoordinates[i]
            
            if (y < baseLineDistance) {
                baseLineDistance = y
            }
            
            var point = transform.transform(point: Point(x, y).toCGPoint())
            
            if point.x < xMin {
                xMin = point.x
            }
            if point.x > xMax {
                xMax = point.x
            }
            
            if point.y < yMin {
                yMin = point.y
            }
            if point.y > yMax {
                yMax = point.y
            }
            
            coords.append(point)
        }
        
        
        var nextSegmentIndex = 0
        var beginOfContour: Int = 0
        
        var contourPoints: [CGPoint] = [coords[0]]
        
        
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
        
        contourPoints = []
    }
    
    return (.init(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax), contoursList, abs(baseLineDistance))
}

public struct GlyphContour {
    public let endPtsOfContours: [Int]
    public let points: [CGPoint]
    public let boundaries: (CGPoint, CGPoint)
}

public struct Glyph: Identifiable {
    public let id: UUID = UUID()
    private let bytes: Data
    private let locations: [Int]
    public let maxPoints: CGPoint
    
    public let glyphBox: GlyphArea
    public let contours: [[CGPoint]]
    public let baseLineDistance: Int
    
    init(from glyph: GlyfTable, at index: Int, 
         maxPoints: CGPoint,
         glyfTable bytes: Data, glyphsLocations locations: [Int], usingCache cache: inout [Int : SimpleGlyphTable]) {
        self.bytes = bytes
        self.locations = locations
        self.maxPoints = maxPoints
        
        switch glyph {
            case let .simple(glyph):
            cache[index] = glyph
            (glyphBox, contours, baseLineDistance) = buildGlyphPoints(from: [(glyph, .zero)])
            
            
            case let .compound(glyph):
                var glyphs: [TransformedGlyph] = []
                
                for currentGlyph in glyph.glyphs {
                    let glyphIndex = Int(currentGlyph.glyphIndex)
                    let glyphLocationOffset = Int(locations[glyphIndex])
                    
                    let glyphBytes = bytes.advanced(by: glyphLocationOffset)
                    
                    do {
                        let simpleGlyphData = try SimpleGlyphTable(glyphBytes)
                        
                        cache[glyphIndex] = simpleGlyphData
                        
                        glyphs.append((simpleGlyphData, currentGlyph.transformMatrix))
                    } catch {
                        let unknownGlyph = try! SimpleGlyphTable(bytes)
                        
                        cache[glyphIndex] = unknownGlyph
                        glyphs.append((unknownGlyph, .zero))
                    }
                }
            
            
                (glyphBox, contours, baseLineDistance) = buildGlyphPoints(from: glyphs)
        }
    }
    
    
    static public func getGlyphLayout() {}
}
