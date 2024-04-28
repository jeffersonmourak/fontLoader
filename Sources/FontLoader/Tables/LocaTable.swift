//
//  HeadTable.swift
//
//
//  Created by Jefferson Oliveira on 4/27/24.
//

import Foundation

//public protocol LocaTable {
//    associatedtype T: BinaryInteger
//}

public struct LocaTable<T: BinaryInteger> {
    public typealias T = UInt16
    let indexes: [T]
    
    let tableLength: Int
    
    init(bytes: Data, withSize length: Int) {
        let read: ReadHead = ReadHead(bytes, index: 0)
        indexes = read.values(ofType: T.self, withSize: length)
        
        tableLength = read.index
    }
    
    subscript(index: Int) -> T {
        get {
            return self.indexes[index]
        }
    }
    
    public var count: Int {
        get {
            return self.indexes.count
        }
    }
    
}

public typealias LocaTableLong = LocaTable<UInt32>
public typealias LocaTableShort = LocaTable<UInt16>
