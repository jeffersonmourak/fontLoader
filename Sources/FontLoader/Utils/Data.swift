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

struct ReadOffset {
    var offset: Int
    let blockSize: Int
    
    init(startAt value: Int, withBlockSize blockSize: Int) {
        self.offset = value
        self.blockSize = blockSize
    }
    
    mutating func advance(by sumOffset: Int) {
        self.offset += sumOffset;
    }
    
    mutating func recue(by decreaseOffset: Int) {
        self.advance(by: decreaseOffset * -1)
    }
    
    mutating func next() {
        self.advance(by: blockSize)
    }
    
    mutating func previous() {
        self.recue(by: blockSize)
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
