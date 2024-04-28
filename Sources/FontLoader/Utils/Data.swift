//
//  Data.swift
//
//
//  Created by Jefferson Oliveira on 4/20/24.
//

import Foundation

public func byteToString(_ data: UInt32, withSize size: Int) -> String {
    var string = data
    
    return NSString(bytes: &string, length: size, encoding: NSUTF8StringEncoding)! as String
}

public func maybeByteToArray<T: BinaryInteger>(_ bytes: Data, ofType: T.Type, length: Int) -> [T?] {
    let read: ReadHead = ReadHead(bytes, index: 0)
    
    return Array(repeating: 0, count: length).map { _ in
        return read.value(ofType: ofType)
    }
    
}

public func byteToArray<T: BinaryInteger>(_ bytes: Data, ofType: T.Type, length: Int) -> ([T], Int) {
    let read: ReadHead = ReadHead(bytes, index: 0)
    
    let arrayFromByte = Array(repeating: 0, count: length).map { _ in
        return read.value(ofType: ofType)!
    }
    
    return (arrayFromByte, read.index)
}

extension UInt8 {
    func isBitSet(at bitIndex: Int) -> Bool {
        return ((self >> bitIndex) & 1) == 1
    }
}


extension Data {
    subscript<T: BinaryInteger>(at offset: Int, convertEndian convertEndian: Bool = false) -> T? {
        value(ofType: T.self, at: offset, convertEndian: convertEndian)
    }
    
    func value<T: BinaryInteger>(ofType: T.Type, at offset: Int, convertEndian: Bool = false) -> T? {
        let right = offset &+ MemoryLayout<T>.size
        guard offset >= 0 && right > offset && right <= count else {
            return nil
        }
        let bytes = self[offset ..< right]
        if convertEndian {
            return bytes.reversed().reduce(0) { T($0) << 8 + T($1) }
        } else {
            return bytes.reduce(0) { T($0) << 8 + T($1) }
        }
    }
}
