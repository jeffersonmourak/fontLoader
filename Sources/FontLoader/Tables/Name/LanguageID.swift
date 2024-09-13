//
//  LanguageID.swift
//
//
//  Created by Jefferson Oliveira on 9/13/24.
//

import Foundation

struct LanguageIDValidation: LocalizedError {
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
        throw LanguageIDValidation(message)
    }
}

fileprivate func computeLanguageId(_ name: UInt16, from platform: FontPlatforms) throws ->  LanguageID {
    switch platform {
    case .Macintosh:
        let id = MacintoshLanguageID(rawValue: name)
        try assertExists(id, message: "Unknown ID \(name)")
        
        return .Macintosh(id!)
    case .Unicode:
        if name != 0 {
            throw LanguageIDValidation("Invlid Unicde language ID (\(name))")
        }
        
        return .Unicode(.Unused)
    case .RESERVED:
        throw PlatformSpecificIDValidation("Reserved is not a valid namespace")
    case .Microsoft:
        return .Microsoft(.Uninplemented(name))
    }
}

public enum MacintoshLanguageID: UInt16 {
    case English = 0
    case French = 1
    case German = 2
    case Italian = 3
    case Dutch = 4
    case Swedish = 5
    case Spanish = 6
    case Danish = 7
    case Portuguese = 8
    case Norwegian = 9
    case Hebrew = 10
    case Japanese = 11
    case Arabic = 12
    case Finnish = 13
    case Greek = 14
    case Icelandic = 15
    case Maltese = 16
    case Turkish = 17
    case Croatian = 18
    case ChineseTraditional = 19
    case Urdu = 20
    case Hindi = 21
    case Thai = 22
    case Korean = 23
    case Lithuanian = 24
    case Polish = 25
    case Hungarian = 26
    case Estonian = 27
    case Latvian = 28
    case Sami = 29
    case Faroese = 30
    case FarsiPersian = 31
    case Russian = 32
    case ChineseSimplified = 33
    case Flemish = 34
    case IrishGaelic = 35
    case Albanian = 36
    case Romanian = 37
    case Czech = 38
    case Slovak = 39
    case Slovenian = 40
    case Yiddish = 41
    case Serbian = 42
    case Macedonian = 43
    case Bulgarian = 44
    case Ukrainian = 45
    case Byelorussian = 46
    case Uzbek = 47
    case Kazakh = 48
    case AzerbaijaniCyrillic = 49
    case AzerbaijaniArabic = 50
    case Armenian = 51
    case Georgian = 52
    case Moldavian = 53
    case Kirghiz = 54
    case Tajiki = 55
    case Turkmen = 56
    case MongolianMongolian = 57
    case MongolianCyrillic = 58
    case Pashto = 59
    case Kurdish = 60
    case Kashmiri = 61
    case Sindhi = 62
    case Tibetan = 63
    case Nepali = 64
    case Sanskrit = 65
    case Marathi = 66
    case Bengali = 67
    case Assamese = 68
    case Gujarati = 69
    case Punjabi = 70
    case Oriya = 71
    case Malayalam = 72
    case Kannada = 73
    case Tamil = 74
    case Telugu = 75
    case Sinhalese = 76
    case Burmese = 77
    case Khmer = 78
    case Lao = 79
    case Vietnamese = 80
    case Indonesian = 81
    case Tagalog = 82
    case MalayRoman = 83
    case MalayArabic = 84
    case Amharic = 85
    case Tigrinya = 86
    case Galla = 87
    case Somali = 88
    case Swahili = 89
    case KinyarwandaRuanda = 90
    case Rundi = 91
    case NyanjaChewa = 92
    case Malagasy = 93
    case Esperanto = 94
    case Welsh = 128
    case Basque = 129
    case Catalan = 130
    case Latin = 131
    case Quechua = 132
    case Guarani = 133
    case Aymara = 134
    case Tatar = 135
    case Uighur = 136
    case Dzongkha = 137
    case JavaneseRoman = 138
    case SundaneseRoman = 139
    case Galician = 140
    case Afrikaans = 141
    case Breton = 142
    case Inuktitut = 143
    case ScottishGaelic = 144
    case ManxGaelic = 145
    case IrishGaelicWithDot = 146
    case Tongan = 147
    case GreekPolytonic = 148
    case Greenlandic = 149
    case AzerbaijaniRoman = 150

    public func toString() -> String {
      switch self {
        case .English: return "English"
        case .French: return "French"
        case .German: return "German"
        case .Italian: return "Italian"
        case .Dutch: return "Dutch"
        case .Swedish: return "Swedish"
        case .Spanish: return "Spanish"
        case .Danish: return "Danish"
        case .Portuguese: return "Portuguese"
        case .Norwegian: return "Norwegian"
        case .Hebrew: return "Hebrew"
        case .Japanese: return "Japanese"
        case .Arabic: return "Arabic"
        case .Finnish: return "Finnish"
        case .Greek: return "Greek"
        case .Icelandic: return "Icelandic"
        case .Maltese: return "Maltese"
        case .Turkish: return "Turkish"
        case .Croatian: return "Croatian"
        case .ChineseTraditional: return "Chinese (Traditional)"
        case .Urdu: return "Urdu"
        case .Hindi: return "Hindi"
        case .Thai: return "Thai"
        case .Korean: return "Korean"
        case .Lithuanian: return "Lithuanian"
        case .Polish: return "Polish"
        case .Hungarian: return "Hungarian"
        case .Estonian: return "Estonian"
        case .Latvian: return "Latvian"
        case .Sami: return "Sami"
        case .Faroese: return "Faroese"
        case .FarsiPersian: return "Farsi (Persian)"
        case .Russian: return "Russian"
        case .ChineseSimplified: return "Chinese (Simplified)"
        case .Flemish: return "Flemish"
        case .IrishGaelic: return "Irish Gaelic"
        case .Albanian: return "Albanian"
        case .Romanian: return "Romanian"
        case .Czech: return "Czech"
        case .Slovak: return "Slovak"
        case .Slovenian: return "Slovenian"
        case .Yiddish: return "Yiddish"
        case .Serbian: return "Serbian"
        case .Macedonian: return "Macedonian"
        case .Bulgarian: return "Bulgarian"
        case .Ukrainian: return "Ukrainian"
        case .Byelorussian: return "Byelorussian"
        case .Uzbek: return "Uzbek"
        case .Kazakh: return "Kazakh"
        case .AzerbaijaniCyrillic: return "Azerbaijani (Cyrillic)"
        case .AzerbaijaniArabic: return "Azerbaijani (Arabic)"
        case .Armenian: return "Armenian"
        case .Georgian: return "Georgian"
        case .Moldavian: return "Moldavian"
        case .Kirghiz: return "Kirghiz"
        case .Tajiki: return "Tajiki"
        case .Turkmen: return "Turkmen"
        case .MongolianMongolian: return "Mongolian (Mongolian)"
        case .MongolianCyrillic: return "Mongolian (Cyrillic)"
        case .Pashto: return "Pashto"
        case .Kurdish: return "Kurdish"
        case .Kashmiri: return "Kashmiri"
        case .Sindhi: return "Sindhi"
        case .Tibetan: return "Tibetan"
        case .Nepali: return "Nepali"
        case .Sanskrit: return "Sanskrit"
        case .Marathi: return "Marathi"
        case .Bengali: return "Bengali"
        case .Assamese: return "Assamese"
        case .Gujarati: return "Gujarati"
        case .Punjabi: return "Punjabi"
        case .Oriya: return "Oriya"
        case .Malayalam: return "Malayalam"
        case .Kannada: return "Kannada"
        case .Tamil: return "Tamil"
        case .Telugu: return "Telugu"
        case .Sinhalese: return "Sinhalese"
        case .Burmese: return "Burmese"
        case .Khmer: return "Khmer"
        case .Lao: return "Lao"
        case .Vietnamese: return "Vietnamese"
        case .Indonesian: return "Indonesian"
        case .Tagalog: return "Tagalog"
        case .MalayRoman: return "Malay (Roman)"
        case .MalayArabic: return "Malay (Arabic)"
        case .Amharic: return "Amharic"
        case .Tigrinya: return "Tigrinya"
        case .Galla: return "Galla"
        case .Somali: return "Somali"
        case .Swahili: return "Swahili"
        case .KinyarwandaRuanda: return "Kinyarwanda (Ruanda)"
        case .Rundi: return "Rundi"
        case .NyanjaChewa: return "Nyanja (Chewa)"
        case .Malagasy: return "Malagasy"
        case .Esperanto: return "Esperanto"
        case .Welsh: return "Welsh"
        case .Basque: return "Basque"
        case .Catalan: return "Catalan"
        case .Latin: return "Latin"
        case .Quechua: return "Quechua"
        case .Guarani: return "Guarani"
        case .Aymara: return "Aymara"
        case .Tatar: return "Tatar"
        case .Uighur: return "Uighur"
        case .Dzongkha: return "Dzongkha"
        case .JavaneseRoman: return "Javanese (Roman)"
        case .SundaneseRoman: return "Sundanese (Roman)"
        case .Galician: return "Galician"
        case .Afrikaans: return "Afrikaans"
        case .Breton: return "Breton"
        case .Inuktitut: return "Inuktitut"
        case .ScottishGaelic: return "Scottish Gaelic"
        case .ManxGaelic: return "Manx Gaelic"
        case .IrishGaelicWithDot: return "Irish Gaelic with dot"
        case .Tongan: return "Tongan"
        case .GreekPolytonic: return "Greek (Polytonic)"
        case .Greenlandic: return "Greenlandic"
        case .AzerbaijaniRoman: return "Azerbaijani (Roman)"
      }
    }
}

public enum UnicodeLanguageID: UInt16 {
    case Unused = 0
    
    public func toString() -> String {
        return "Unused"
    }
}

public enum MicrosoftLanguageID {
    case Uninplemented(UInt16)
    
    public func toString() -> String {
        return "UNINPLEMENTED"
    }
}

public enum LanguageID {
    case Unicode(UnicodeLanguageID)
    case Macintosh(MacintoshLanguageID)
    case Microsoft(MicrosoftLanguageID)
    
    public static func from(_ name: UInt16, platform: FontPlatforms) throws -> Self {
        return try computeLanguageId(name, from: platform)
    }

    public func toString() -> String {
        switch self {
        case let .Unicode(id):
            return "(Unicode) [\(id.toString())]"
        case .Macintosh(let id):
            return "(Macintosh) [\(id.toString())]"
        case .Microsoft(let id):
            return "(Microsoft) [\(id.toString())]"
        }
    }
}
