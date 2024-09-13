//
//  NameID.swift
//
//
//  Created by Jefferson Oliveira on 9/13/24.
//

import Foundation

fileprivate func computeNameId(_ name: UInt16) -> NameID {
    switch NameIDRanges(rawValue: name) {
    case .none:
        if (NameIDRanges.ReservedForExpansion.contains(name)) {
            return .DefinedByOpentype(Int(name))
        }
        
        if (NameIDRanges.ReservedForExpansion.contains(name)) {
            return .ReservedForExpansion(Int(name))
        }
        
        if (NameIDRanges.FontSpecificNames.contains(name)) {
            return .FontSpecificName(Int(name))
        }
    case .some(.Copyright):
        return .Copyright(Int(name))
    case .some(.FontFamily):
        return .FontFamily(Int(name))
    case .some(.FontSubfamily):
        return .FontSubfamily(Int(name))
    case .some(.UniqueSubfamilyID):
        return .UniqueSubfamily(Int(name))
    case .some(.FullName):
        return .FullName(Int(name))
    case .some(.Version):
        return .Version(Int(name))
    case .some(.PostScriptName):
        return .PostScriptName(Int(name))
    case .some(.Trademark):
        return .Trademark(Int(name))
    case .some(.Manufacturer):
        return .Manufacturer(Int(name))
    case .some(.Designer):
        return .Designer(Int(name))
    case .some(.Description):
        return .Description(Int(name))
    case .some(.VendorURL):
        return .VendorURL(Int(name))
    case .some(.DesignerURL):
        return .DesignerURL(Int(name))
    case .some(.LicenseDescription):
        return .LicenseDescription(Int(name))
    case .some(.LicenseInfoURL):
        return .LicenseInfoURL(Int(name))
    case .some(.Reserved):
        return .Reserved(Int(name))
    case .some(.PreferredFamily):
        return .PreferredFamily(Int(name))
    case .some(.PreferredSubfamily):
        return .PreferredSubfamily(Int(name))
    case .some(.CompatibleFullName):
        return .CompatibleFullName(Int(name))
    case .some(.SampleText):
        return .SampleText(Int(name))
    case .some(.VariationsPostScriptNamePrefix):
        return .VariationsPostScriptNamePrefix(Int(name))
    }
    
    return .Unknown(Int(name))
}

public enum NameIDRanges: UInt16 {
    case Copyright = 0
    case FontFamily = 1
    case FontSubfamily = 2
    case UniqueSubfamilyID = 3
    case FullName = 4
    case Version = 5
    case PostScriptName = 6
    case Trademark = 7
    case Manufacturer = 8
    case Designer = 9
    case Description = 10
    case VendorURL = 11
    case DesignerURL = 12
    case LicenseDescription = 13
    case LicenseInfoURL = 14
    case Reserved = 15
    case PreferredFamily = 16
    case PreferredSubfamily = 17
    case CompatibleFullName = 18
    case SampleText = 19
    static let DefinedByOpentype: ClosedRange<UInt16> = 20...24
    case VariationsPostScriptNamePrefix = 25
    static let ReservedForExpansion: ClosedRange<UInt16> = 26...255
    static let FontSpecificNames: ClosedRange<UInt16> = 256...32767
}

public enum NameID {
    case Copyright(Int)
    case FontFamily(Int)
    case FontSubfamily(Int)
    case UniqueSubfamily(Int)
    case FullName(Int)
    case Version(Int)
    case PostScriptName(Int)
    case Trademark(Int)
    case Manufacturer(Int)
    case Designer(Int)
    case Description(Int)
    case VendorURL(Int)
    case DesignerURL(Int)
    case LicenseDescription(Int)
    case LicenseInfoURL(Int)
    case Reserved(Int)
    case PreferredFamily(Int)
    case PreferredSubfamily(Int)
    case CompatibleFullName(Int)
    case SampleText(Int)
    case DefinedByOpentype(Int)
    case VariationsPostScriptNamePrefix(Int)
    case ReservedForExpansion(Int)
    case FontSpecificName(Int)
    case Unknown(Int)
    
    public func toString() -> String {
            switch self {
            case let .CompatibleFullName(value):
                return "CompatibleFullName(\(value))"
            case let .Copyright(value):
                return "Copyright(\(value))"
            case let .FontFamily(value):
                return "FontFamily(\(value))"
            case let .FontSubfamily(value):
                return "FontSubfamily(\(value))"
            case let .UniqueSubfamily(value):
                return "UniqueSubfamily(\(value))"
            case let .FullName(value):
                return "FullName(\(value))"
            case let .Version(value):
                return "Version(\(value))"
            case let .PostScriptName(value):
                return "PostScriptName(\(value))"
            case let .Trademark(value):
                return "Trademark(\(value))"
            case let .Manufacturer(value):
                return "Manufacturer(\(value))"
            case let .Designer(value):
                return "Designer(\(value))"
            case let .Description(value):
                return "Description(\(value))"
            case let .VendorURL(value):
                return "VendorURL(\(value))"
            case let .DesignerURL(value):
                return "DesignerURL(\(value))"
            case let .LicenseDescription(value):
                return "LicenseDescription(\(value))"
            case let .LicenseInfoURL(value):
                return "LicenseInfoURL(\(value))"
            case let .Reserved(value):
                return "Reserved(\(value))"
            case let .PreferredFamily(value):
                return "PreferredFamily(\(value))"
            case let .PreferredSubfamily(value):
                return "PreferredSubfamily(\(value))"
            case let .SampleText(value):
                return "SampleText(\(value))"
            case let .DefinedByOpentype(value):
                return "DefinedByOpentype(\(value))"
            case let .VariationsPostScriptNamePrefix(value):
                return "VariationsPostScriptNamePrefix(\(value))"
            case let .ReservedForExpansion(value):
                return "ReservedForExpansion(\(value))"
            case let .FontSpecificName(value):
                return "FontSpecificName(\(value))"
            case let .Unknown(value):
                return "Unknown(\(value))"
            }
        }
    
    public static func from(_ name: UInt16) -> Self {
        return computeNameId(name)
    }
}
