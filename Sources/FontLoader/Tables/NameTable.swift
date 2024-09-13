//
//  NameTable.swift
//
//
//  Created by Jefferson Oliveira on 9/13/24.
//

import Foundation

fileprivate func getCharUIntOrFallback(_ messageRead: inout ReadHead) -> UInt8 {
    do {
        return try messageRead.value(ofType: UInt8.self)
    } catch {
        return 0
    }
}

fileprivate func computeMessage(_ bytes: Data, startAt offset: Int, withSize length: Int, hideUnknownChars: Bool = true) -> String {
    var messageRead: ReadHead = ReadHead(bytes.advanced(by: offset), index: 0)
    
    var messageBytes: [UInt8] = []
    
    for _ in 0..<length {
        let character = getCharUIntOrFallback(&messageRead)
        
        if !hideUnknownChars || character != 0 {
            messageBytes.append(character)
        }
        
    }
    
    return String(decoding: messageBytes, as: UTF8.self)
}

public struct NameTable {
    public let format: UInt16
    public let count: UInt16
    public let stringOffset: UInt16
    
    public var records: [NameRecord] = []
    
    let tableLength: Int
    
    init(bytes: Data) throws {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        format = try read.value(ofType: UInt16.self)
        count = try read.value(ofType: UInt16.self)
        stringOffset = try read.value(ofType: UInt16.self)
        
        for _ in 0..<Int(count) {
            let record = try NameRecord(
                bytes: bytes.advanced(by: read.index),
                stringBytes: bytes.advanced(by: Int(stringOffset))
            )
            
            records.append(record)
            
            read.advance(by: record.tableLength)
        }
        
        tableLength = read.index
    }
}

public struct NameRecord: Identifiable {
    public var id: String
    
    public let platformID: FontPlatforms
    public let platformSpecificID: PlatformSpecificNameID
    public let languageID: LanguageID
    public let nameID: NameID
    public let length: UInt16
    public let offset: UInt16
    public let message: String
    
    let tableLength: Int
    
    init(bytes: Data, stringBytes: Data) throws {
        let read: ReadHead = ReadHead(bytes, index: 0)
        
        let platformIdRawValue = try read.value(ofType: UInt16.self)
        platformID = FontPlatforms.from(platformIdRawValue)
        
        let platformSpecificIdRawValue = try read.value(ofType: UInt16.self)
        platformSpecificID = try PlatformSpecificNameID.from(platformSpecificIdRawValue, platform: platformID)
    
        let languageIdRawValue = try read.value(ofType: UInt16.self)
        languageID = try LanguageID.from(languageIdRawValue, platform: platformID)
        
        let nameIDRawValue = try read.value(ofType: UInt16.self)
        nameID = NameID.from(nameIDRawValue)
        
        length = try read.value(ofType: UInt16.self)
        offset = try read.value(ofType: UInt16.self)
        message = computeMessage(stringBytes, startAt: Int(offset), withSize: Int(length))
        
        id = "\(platformIdRawValue)-\(platformSpecificIdRawValue)-\(languageIdRawValue)-\(nameIDRawValue)"
        
        tableLength = read.index
    }
}
