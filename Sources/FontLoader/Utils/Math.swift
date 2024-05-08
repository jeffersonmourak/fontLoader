//
//  Math.swift
//
//
//  Created by Jefferson Oliveira on 5/8/24.
//

import Foundation

public typealias FontMathNumericType = Numeric & Comparable & BinaryInteger

public struct Vector2<T: FontMathNumericType> {
    public let a: T
    public let b: T
    
    init(a: T, b: T) {
        self.a = a
        self.b = b
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
    
    public var x: T {
        get {
            return a
        }
    }
    
    public var y: T {
        get {
            return b
        }
    }
    
    public var w: T {
        get {
            return a
        }
    }
    
    public var h: T {
        get {
            return b
        }
    }
    
    public var width: T {
        get {
            return a
        }
    }
    
    public var height: T {
        get {
            return b
        }
    }
    
    public static var zero: Self {
        return .init(.zero, .zero)
    }
    
    public func toCGPoint() -> CGPoint {
        return .init(x: Double(a), y: Double(b))
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
