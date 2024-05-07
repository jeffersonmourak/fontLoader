//
//  LocaTable.swift
//
//
//  Created by Jefferson Oliveira on 4/27/24.
//

import Foundation

public struct LocaTable<T: BinaryInteger> {
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

extension LocaTable where T == UInt16 {
    init(bytes: Data, withSize length: Int) {
        let read: ReadHead = ReadHead(bytes, index: 0)
        indexes = read.values(ofType: T.self, withSize: length).map { $0 }
        
        tableLength = read.index
    }
}

extension LocaTable where T == UInt32 {
    init(from origin: LocaTable<UInt16>) {
        self.indexes = origin.indexes.map { UInt32($0) * 2 }
        self.tableLength = origin.tableLength * 2
    }
}

public typealias LocaTableLong = LocaTable<UInt32>
public typealias LocaTableShort = LocaTable<UInt16>
