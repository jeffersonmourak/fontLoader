//
//  Glyph.swift
//
//
//  Created by Jefferson Oliveira on 5/5/24.
//

import Foundation

public struct GlyphLayout {
    public let baseline: CGFloat
}

public struct GlyphPoint {
    public let x: CGFloat
    public let y: CGFloat
    public let flag: SimpleGlyphCoordinateFlag
    public let isImplied: Bool

    public init(x: CGFloat, y: CGFloat, flag: SimpleGlyphCoordinateFlag, isImplied: Bool = false) {
        self.x = x
        self.y = y
        self.flag = flag
        self.isImplied = isImplied
    }

    public init(_ cGPoint: CGPoint, flag: SimpleGlyphCoordinateFlag) {
        self = cGPoint.toGlyphPoint(withFlag: flag)
    }

    public func cGPoint() -> CGPoint {
        .init(x: x, y: y)
    }

    public func cGFloatTuple() -> (CGFloat, CGFloat) {
        (x, y)
    }
}

typealias TransformedGlyph = (SimpleGlyphTable, LinearTransform)

func getGlyphMagntude(_ glyph: SimpleGlyphTable) -> (Int16, Int16) {
    (glyph.xMax - glyph.xMin, glyph.yMax - glyph.yMin)
}

func buildGlyphPoints(
    from glyphs: [TransformedGlyph], usingLayout layout: FontLayout,
    applyingMetrics metrics: LongHorMetric
) -> [[GlyphPoint]] {
    guard glyphs.count > 0 else {
        return []
    }

    var contoursList: [[GlyphPoint]] = []

    for (glyph, transform) in glyphs {
        var coords: [CGPoint] = []
        for i in 0..<glyph.xCoordinates.count {
            let x = glyph.xCoordinates[i]
            let y = glyph.yCoordinates[i]

            let point = transform.transform(point: Point(x, y).toCGPoint())

            coords.append(layout.normalizePoint(point))
        }

        var nextSegmentIndex = 0
        var beginOfContour: Int = 0

        var contourPoints: [GlyphPoint] = [
            .init(coords[0], flag: SimpleGlyphCoordinateFlag(glyph.flags[0]))
        ]

        for i in 1..<coords.count {
            let flag = glyph.computed.expandedFlags[i]
            let current = coords[i]
            let nextSegment =
                nextSegmentIndex < glyph.endPtsOfContours.count
                ? glyph.endPtsOfContours[nextSegmentIndex] : glyph.endPtsOfContours.last!

            contourPoints.append(.init(current, flag: flag))

            if i == nextSegment {
                contourPoints.append(.init(coords[beginOfContour], flag: flag))
                contoursList.append(contourPoints)
                contourPoints = []
                beginOfContour = nextSegment + 1
                nextSegmentIndex += 1
            }
        }

        contourPoints = []
    }

    var normalizedContoursList: [[GlyphPoint]] = []

    for contour in contoursList {
        var normalizedContour: [GlyphPoint] = []

        for i in 0..<contour.count {
            let curr = contour[(contour.count + i + 0) % contour.count]
            let next = contour[(contour.count + i + 1) % contour.count]

            let newY = layout.baseline - curr.y
            let newX = curr.x
            normalizedContour.append(.init(x: newX, y: newY, flag: curr.flag))

            let isConsecutiveOffCurvePoints: Bool = !curr.flag.onCurve && !next.flag.onCurve
            let isStraightLine: Bool = curr.flag.onCurve && next.flag.onCurve
            // TODO: Figure out exactly why skip the second last solves this!
            if i != contour.count - 2 && (isConsecutiveOffCurvePoints || isStraightLine) {
                let onCurve = isConsecutiveOffCurvePoints

                let newY = layout.baseline - ((curr.y + next.y) / 2)
                let newX = ((curr.x + next.x) / 2)
                normalizedContour.append(
                    .init(
                        x: newX, y: newY,
                        flag: curr.flag.cloneAndReplaceOnCurve(isOnCurve: onCurve),
                        isImplied: true))
            }
        }

        normalizedContoursList.append(normalizedContour)
    }

    return normalizedContoursList
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
    public let layout: FontLayout
    public let index: Int
    public let name: String
    public let horizontalMetrics: LongHorMetric

    public let contours: [[GlyphPoint]]
    init(
        from glyph: GlyfTable,
        at index: Int,
        name: String,
        withLayout layout: FontLayout,
        applyingMetrics metrics: LongHorMetric,
        maxPoints: CGPoint,
        glyfTable bytes: Data,
        glyphsLocations locations: [Int],
        usingCache cache: inout [Int: SimpleGlyphTable]
    ) {
        self.bytes = bytes
        self.locations = locations
        self.maxPoints = maxPoints
        self.layout = layout
        self.name = name
        self.horizontalMetrics = metrics

        self.index = index

        switch glyph {
        case let .simple(glyph):
            cache[index] = glyph
            contours = buildGlyphPoints(
                from: [(glyph, .zero)], usingLayout: layout, applyingMetrics: metrics)

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

            contours = buildGlyphPoints(
                from: glyphs, usingLayout: layout, applyingMetrics: metrics)
        }
    }

    static public func getGlyphLayout() {}
}

extension CGPoint {
    public func toGlyphPoint(withFlag flag: SimpleGlyphCoordinateFlag) -> GlyphPoint {
        return .init(x: self.x, y: self.y, flag: flag)
    }
}
