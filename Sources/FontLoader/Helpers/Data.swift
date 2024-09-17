//
//  Data.swift
//
//
//  Created by Jefferson Oliveira on 4/20/24.
//

import Foundation

public typealias shortFrac = Int16
public typealias Fixed = Int16
public typealias FWord = Int16
public typealias uFWord = UInt16
public typealias F2Dot14 = UInt16
public typealias longDateTime = Int64

public enum DataError: Error {
    case ParseError

    var localizedDescription: String {
        switch self {
        case .ParseError:
            return "Error parsing data"
        }
    }
}

public func byteToString(_ data: UInt32, withSize size: Int) -> String {
    var string: UInt32 = data

    let bytes: [UInt8] = withUnsafePointer(to: &string) {
        $0.withMemoryRebound(to: UInt8.self, capacity: size) {
            Array(UnsafeBufferPointer(start: $0, count: size))
        }
    }
    
    return String(bytes: bytes, encoding: .utf8) ?? ""
}

public func byteToArray<T: BinaryInteger>(_ bytes: Data, ofType: T.Type, length: Int) throws -> ([T], Int) {
    let read: ReadHead = ReadHead(bytes, index: 0)
    
    let arrayFromByte = try Array(repeating: 0, count: length).map { _ in
        return try read.value(ofType: ofType)
    }
    
    return (arrayFromByte, read.index)
}

extension UInt8 {
    func isBitSet(at bitIndex: Int) -> Bool {
        return ((self >> bitIndex) & 1) == 1
    }
}

extension UInt16 {
    func isBitSet(at bitIndex: Int) -> Bool {
        return ((self >> bitIndex) & 1) == 1
    }
}

enum FontBinaryType {
    case F2Dot14
}

extension Data {
    subscript<T: BinaryInteger>(at offset: Int, convertEndian convertEndian: Bool = false) -> T? {
        try? value(ofType: T.self, at: offset, convertEndian: convertEndian)
    }
    
    func value<T: BinaryInteger>(ofType: T.Type, at offset: Int, convertEndian: Bool = false) throws -> T {
        do {
            let right = offset &+ MemoryLayout<T>.size
            guard offset >= 0 && right > offset && right <= count else {
                throw DataError.ParseError
            }
            let bytes = self[offset ..< right]
            
            if convertEndian {
                return bytes.reversed().reduce(0) { T($0) << 8 + T($1) }
            } else {
                return bytes.reduce(0) { T($0) << 8 + T($1) }
            }
        } catch {
            throw error
        }
    }
    
    func value(ofType: Int8.Type, at offset: Int, convertEndian: Bool = false) throws -> Int8 {
        do {
            let right = offset &+ MemoryLayout<Int8>.size
            guard offset >= 0 && right > offset && right <= count else {
                throw DataError.ParseError
            }
            let bytes = self[offset ..< right]
            return try bytes.withUnsafeBytes<Int8>() { Int8(bitPattern: Data($0)[0]) }
        } catch {
            throw error
        }
    }
    
    func valueF2Dot14(at offset: Int, convertEndia: Bool = false, convertEndian: Bool = false) throws -> Double {
        let usignedValue = try self.value(ofType: UInt16.self, at: offset)
        
        let dividend = Double((1<<14))
        
        return Double(usignedValue) / dividend
    }
}
