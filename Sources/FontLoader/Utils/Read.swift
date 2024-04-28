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

class ReadHead: ReadHeadProtocol {
    let bytes: Data
    var index: Int
    
    init(_ bytes: Data, index: Int) {
        self.bytes = bytes
        self.index = index
    }
    
    func value<T: BinaryInteger>(ofType: T.Type, at offset: Int, convertEndian: Bool = false, advanceWhenRead: Bool = true) -> T? {
        let byteValue: T? = bytes.value(ofType: ofType, at: offset, convertEndian: convertEndian)
        
        if (advanceWhenRead) {
            self.advance(by: MemoryLayout<T>.size)
        }
        
        return byteValue
    }
    
    func value<T: BinaryInteger>(ofType: T.Type, convertEndian: Bool = false, advanceWhenRead: Bool = true) -> T? {
        return self.value(ofType: ofType, at: self.index, convertEndian: convertEndian, advanceWhenRead: advanceWhenRead)
    }
    
    func values<T: BinaryInteger>(ofType: T.Type, at offset: Int, withSize length: Int, convertEndian: Bool = false, advanceWhenRead: Bool = true) -> [T] {
        let (valuesArray, arrayOffset) = byteToArray(bytes.advanced(by: offset), ofType: ofType, length: length)
        advance(by: arrayOffset)
        
        return valuesArray
    }
    
    func values<T: BinaryInteger>(ofType: T.Type, withSize length: Int, convertEndian: Bool = false, advanceWhenRead: Bool = true) -> [T] {
        return values(ofType: ofType, at: index, withSize: length, convertEndian: convertEndian, advanceWhenRead: advanceWhenRead)
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
