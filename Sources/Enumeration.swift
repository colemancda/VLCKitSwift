//
//  Enumeration.swift
//  VLCKitSwift
//
//  Created by Alsey Coleman Miller on 10/2/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

public protocol VLCEnumeration: RawRepresentable {
    
    associatedtype VLCType: RawRepresentable
    
    init(_ vlcType: VLCType)
    
    var vlcType: VLCType { get }
}

public extension VLCEnumeration where Self.RawValue == VLCType.RawValue {
    
    @inline(__always)
    init(_ vlcType: VLCType) {
        
        self.init(rawValue: vlcType.rawValue)!
    }
    
    var vlcType: VLCType {
        
        @inline(__always)
        get { return VLCType(rawValue: self.rawValue)! }
    }
}
