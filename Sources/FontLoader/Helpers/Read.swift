//
//  Read.swift
//
//
//  Created by Jefferson Oliveira on 4/27/24.
//

import Foundation

protocol ReadHeadProtocol {
    var index: Int { get set }
    
    mutating func advance(by sumOffset: Int) -> Void
    mutating func recue(by decreaseOffset: Int) -> Void
}

enum ReadHeadError: Error {
    case ReadFail
}

class ReadHead: ReadHeadProtocol {
    let bytes: Data
    var index: Int
    
    init(_ bytes: Data, index: Int) {
        self.bytes = bytes
        self.index = index
    }
    
    func value<T: BinaryInteger>(ofType: T.Type, at offset: Int, convertEndian: Bool = false, advanceWhenRead: Bool = true) throws -> T {
        let byteValue: T = try bytes.value(ofType: ofType, at: offset, convertEndian: convertEndian)
        
        if (advanceWhenRead) {
            self.advance(by: MemoryLayout<T>.size)
        }
        
        return byteValue
    }
    
    func value(ofType: Int8.Type, at offset: Int, convertEndian: Bool = false, advanceWhenRead: Bool = true) throws -> Int8 {
        let byteValue: Int8 = try bytes.value(ofType: ofType, at: offset, convertEndian: convertEndian)
        
        if (advanceWhenRead) {
            self.advance(by: MemoryLayout<Int8>.size)
        }
        
        return byteValue
    }
    
    func valueF2Dot14(at offset: Int, convertEndian: Bool = false, advanceWhenRead: Bool = true) throws -> Double {
        let byteValue = try bytes.valueF2Dot14(at: offset, convertEndian: convertEndian)
        
        if (advanceWhenRead) {
            self.advance(by: MemoryLayout<UInt16>.size)
        }
        
        return byteValue
    }
    
    func valueF2Dot14(convertEndian: Bool = false, advanceWhenRead: Bool = true) throws -> Double {
        return try self.valueF2Dot14(at: self.index, convertEndian: convertEndian, advanceWhenRead: advanceWhenRead)
    }
    
    func value<T: BinaryInteger>(ofType: T.Type, convertEndian: Bool = false, advanceWhenRead: Bool = true) throws -> T {
        return try self.value(ofType: ofType, at: self.index, convertEndian: convertEndian, advanceWhenRead: advanceWhenRead)
    }
    
    func value(ofType: Int8.Type, convertEndian: Bool = false, advanceWhenRead: Bool = true) throws -> Int8 {
        return try self.value(ofType: ofType, at: self.index, convertEndian: convertEndian, advanceWhenRead: advanceWhenRead)
    }
    
    func values<T: BinaryInteger>(ofType: T.Type, at offset: Int, withSize length: Int, convertEndian: Bool = false, advanceWhenRead: Bool = true) throws -> [T] {
        let (valuesArray, arrayOffset) = try byteToArray(bytes.advanced(by: offset), ofType: ofType, length: length)
        advance(by: arrayOffset)
        
        return valuesArray
    }
    
    func values<T: BinaryInteger>(ofType: T.Type, withSize length: Int, convertEndian: Bool = false, advanceWhenRead: Bool = true) throws -> [T] {
        return try values(ofType: ofType, at: index, withSize: length, convertEndian: convertEndian, advanceWhenRead: advanceWhenRead)
    }

    func string(length: Int) throws -> String {
        let string = try bytes.string(at: index, length: length)
        
        self.advance(by: length)
        
        return string
    }

    func pascalString() throws -> String {
        let length: Int = Int(try self.value(ofType: UInt8.self))
        let string: String = try self.string(length: length)
        
        return string
    }
    
    func advance(by sumOffset: Int) {
        self.index += sumOffset;
    }
    
    func recue(by decreaseOffset: Int) {
        self.advance(by: decreaseOffset * -1)
    }
}

struct ReadOffset {
    private let readHead: ReadHead
    
    let blockSize: Int
    
    var offset: Int {
        get {
            return readHead.index
        }
        
        set(value) {
            readHead.index = value
        }
    }
    
    init(startAt value: Int, withBlockSize blockSize: Int) {
        self.readHead = ReadHead(.init(), index: value)
        self.blockSize = blockSize
    }
    
    func next() {
        self.readHead.advance(by: blockSize)
    }
    
    func previous() {
        self.readHead.recue(by: blockSize)
    }
}

extension Data {
    public func string(at offset: Int, length: Int) throws -> String {
        return String(bytes: self[offset ..< offset + length], encoding: .utf8) ?? ""
    }
}