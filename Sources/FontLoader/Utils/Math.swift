//
//  Math.swift
//
//
//  Created by Jefferson Oliveira on 5/8/24.
//

import Foundation

public typealias FontMathNumericType = Numeric & Comparable & BinaryInteger

public struct Vector2<T: FontMathNumericType>: CustomStringConvertible {
    
    public let x: T
    public let y: T
    
    init(a: T, b: T) {
        self.x = a
        self.y = b
    }
    
    init(_ a: T, _ b: T) {
        self.init(a: a, b: b)
    }
    
    init(x: T, y: T) {
        self.init(a: x, b: y)
    }
    
    init(w: T, h: T) {
        self.init(a: w, b: h)
    }
    
    init(width: T, height: T) {
        self.init(a: width, b: height)
    }
    
    public var description: String {
        get {
            return "(x: \(self.x), y: \(self.y))"
        }
    }
    
    public var a: T {
        get {
            return x
        }
    }
    
    public var b: T {
        get {
            return y
        }
    }
    
    public var w: T {
        get {
            return x
        }
    }
    
    public var h: T {
        get {
            return y
        }
    }
    
    public var width: T {
        get {
            return x
        }
    }
    
    public var height: T {
        get {
            return y
        }
    }
    
    public static var zero: Self {
        return .init(.zero, .zero)
    }
    
    public func toCGPoint() -> CGPoint {
        return .init(x: Double(x), y: Double(y))
    }
}

public typealias Point = Vector2

public struct Area<T: FontMathNumericType> {
    public let min: Vector2<T>
    public let max: Vector2<T>
    
    init(min: Vector2<T>, max: Vector2<T>) {
        self.min = min
        self.max = max
    }
    
    init(_ a: Vector2<T>, _ b: Vector2<T>) {
        self.init(min: a, max: b)
    }

    init(begin: Vector2<T>, end: Vector2<T>) {
        self.init(min: begin, max: end)
    }
    
    static var zero: Self {
        return .init(.zero, .zero)
    }
    
    public func reshape(with newArea: Area<T>) -> Area<T> {
        var minX = min.x
        var minY = min.y
        var maxX = max.x
        var maxY = max.y
        
        if (newArea.min.x < min.x) {
            minX = newArea.min.x
        }
        
        if (newArea.max.x > max.x) {
            maxX = newArea.max.x
        }
        
        if (newArea.min.y < min.y) {
            minY = newArea.min.y
        }
        
        if (newArea.max.y > max.y) {
            maxY = newArea.max.y
        }
        
        return .init(
            min: .init(x: minX, y: minY),
            max: .init(x: maxX, y: maxY)
        )
    }
}


public struct LinearTransform {
    let iHat: CGPoint
    let jHat: CGPoint
    let offset: CGPoint
    
    init(_ iHat: CGPoint, _ jHat: CGPoint, withOffset offset: CGPoint = .init(x: 0, y: 0)) {
        self.iHat = iHat
        self.jHat = jHat
        self.offset = offset
    }
    
    public func transform(point: CGPoint) -> CGPoint {
        let x = iHat.x * point.x + jHat.x * point.y + offset.x
        let y = iHat.y * point.x + jHat.y * point.y + offset.y
        
        return .init(x: x, y: y)
    }
    
    public static var defaultIHat: CGPoint {
        return .init(x: 1, y: 0)
    }
    
    public static var defaultJHat: CGPoint {
        return .init(x: 0, y: 1)
    }
    
    public static var zero: Self  {
        get {
            return .init(defaultIHat, defaultJHat)
        }
    }
}
