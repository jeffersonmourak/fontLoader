//
//  Debug.swift
//
//
//  Created by Jefferson Oliveira on 9/13/24.
//

import Foundation

public func DEBUG__prettyPrintNameRecord(_ record: NameRecord) {
    print(">>>>>>>>>>>")
    print("platformID:", record.platformID)
    print("platformSpecificID:", record.platformSpecificID)
    print("languageID:", record.languageID)
    print("nameID:", record.nameID)
    print("message:", record.message)
    print("offset:", record.offset)
    print("length:", record.length)
    print("<<<<<<<<<<<")
    print("")
}
