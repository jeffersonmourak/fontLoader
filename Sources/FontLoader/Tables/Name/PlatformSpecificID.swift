//
//  PlatformSpecificID.swift
//
//
//  Created by Jefferson Oliveira on 9/13/24.
//

import Foundation

struct PlatformSpecificIDValidation: LocalizedError {
    let description: String
    
    init (_ description: String) {
        self.description = description
    }
    
    var errorDescription: String? {
        description
    }
}

fileprivate func assertExists<K>(_ a: K?, message: String) throws {
    if a == nil {
        throw PlatformSpecificIDValidation(message)
    }
}

fileprivate func computePlatformSpecificId(_ name: UInt16, from platform: FontPlatforms) throws ->  PlatformSpecificNameID {
    switch platform {
    case .Macintosh:
        let id = MacOSSpecificNameId(rawValue: name)
        try assertExists(id, message: "Unknown ID \(name)")
        
        return .Macintosh(id!)
    case .Unicode:
        let id = UnicodeSpecificNameId(rawValue: name)
        try assertExists(id, message: "Unknown ID \(name)")
        
        return .Unicode(id!)
    case .RESERVED:
        throw PlatformSpecificIDValidation("Reserved is not a valid namespace")
    case .Microsoft:
        let id = MicrosoftSpecificNameId(rawValue: name)
        try assertExists(id, message: "Unknown ID \(name)")
        
        return .Microsoft(id!)
    }
}

public enum UnicodeSpecificNameId: UInt16 {
    case V1_0 = 0
    case V1_1 = 1
    case ISO10646 = 2
    case V2_0 = 3
    case V2_0_nonBMP = 4
    
    func toString() -> String {
        switch self {
        case .ISO10646:
            return "ISO 10646 1993 semantics (deprecated)"
        case .V1_0:
            return "Version 1.0"
        case .V1_1:
            return "Version 1.1"
        case .V2_0:
            return "Unicode 2.0 or later semantics (BMP only)"
        case .V2_0_nonBMP:
            return "Unicode 2.0 or later semantics (non-BMP characters allowed)"
        }
    }
}

public enum MacOSSpecificNameId: UInt16 {
    case Roman = 0
    case Japanese = 1
    case TraditionalChinese = 2
    case Korean = 3
    case Arabic = 4
    case Hebrew = 5
    case Greek = 6
    case Russian = 7
    case RSymbol = 8
    case Devanagari = 9
    case Gurmukhi = 10
    case Gujarati = 11
    case Oriya = 12
    case Bengali = 13
    case Tamil = 14
    case Telugu = 15
    case Kannada = 16
    case Malayalam = 17
    case Sinhalese = 18
    case Burmese = 19
    case Khmer = 20
    case Thai = 21
    case Laotian = 22
    case Georgian = 23
    case Armenian = 24
    case SimplifiedChinese = 25
    case Tibetan = 26
    case Mongolian = 27
    case Geez = 28
    case Slavic = 29
    case Vietnamese = 30
    case Sindhi = 31
    case Uninterpreted = 32
    
    public func toString() -> String {
      switch self {
        case .Roman: return "Roman"
        case .Japanese: return "Japanese"
        case .TraditionalChinese: return "Traditional Chinese"
        case .Korean: return "Korean"
        case .Arabic: return "Arabic"
        case .Hebrew: return "Hebrew"
        case .Greek: return "Greek"
        case .Russian: return "Russian"
        case .RSymbol: return "R Symbol"
        case .Devanagari: return "Devanagari"
        case .Gurmukhi: return "Gurmukhi"
        case .Gujarati: return "Gujarati"
        case .Oriya: return "Oriya"
        case .Bengali: return "Bengali"
        case .Tamil: return "Tamil"
        case .Telugu: return "Telugu"
        case .Kannada: return "Kannada"
        case .Malayalam: return "Malayalam"
        case .Sinhalese: return "Sinhalese"
        case .Burmese: return "Burmese"
        case .Khmer: return "Khmer"
        case .Thai: return "Thai"
        case .Laotian: return "Laotian"
        case .Georgian: return "Georgian"
        case .Armenian: return "Armenian"
        case .SimplifiedChinese: return "Simplified Chinese"
        case .Tibetan: return "Tibetan"
        case .Mongolian: return "Mongolian"
        case .Geez: return "Geez"
        case .Slavic: return "Slavic"
        case .Vietnamese: return "Vietnamese"
        case .Sindhi: return "Sindhi"
        case .Uninterpreted: return "Uninterpreted"
      }
    }
}

public enum MicrosoftSpecificNameId: UInt16 {
    case Symbol = 0
    case UnicodeBMP = 1
    case ShiftJIS = 2
    case PRC = 3
    case Big5 = 4
    case Wansung = 5
    case Johab = 6
    case Reserved1 = 7
    case Reserved2 = 8
    case Reserved3 = 9
    case UnicodeFullRepertoire = 10

    public func toString() -> String {
      switch self {
        case .Symbol: return "Symbol"
        case .UnicodeBMP: return "Unicode BMP"
        case .ShiftJIS: return "ShiftJIS"
        case .PRC: return "PRC"
        case .Big5: return "Big5"
        case .Wansung: return "Wansung"
        case .Johab: return "Johab"
        case .Reserved1: return "Reserved1"
        case .Reserved2: return "Reserved2"
        case .Reserved3: return "Reserved3"
        case .UnicodeFullRepertoire: return "Unicode Full Repertoire"
      }
    }
}
    

public enum PlatformSpecificNameID {
    case Unicode(UnicodeSpecificNameId)
    case Macintosh(MacOSSpecificNameId)
    case Microsoft(MicrosoftSpecificNameId)
    
    public static func from(_ name: UInt16, platform: FontPlatforms) throws -> Self {
        return try computePlatformSpecificId(name, from: platform)
    }
    
    public func toString() -> String {
      switch self {
      case let .Unicode(name): return "(Unicode) [\(name.toString())]"
      case let .Macintosh(name): return "(Unicode) [\(name.toString())]"
      case let .Microsoft(name): return "(Unicode) [\(name.toString())]"
      }
    }
}
