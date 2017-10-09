//
//  Time.swift
//  VLCKitSwift
//
//  Created by Alsey Coleman Miller on 10/9/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

import VLC

/// VLC Movie time. 
public struct Time: RawRepresentable {
    
    public var rawValue: Int64
    
    public init(rawValue: Int64) {
        
        self.rawValue = rawValue
    }
}

// MARK: - Hashable

extension Time: Hashable {
    
    public var hashValue: Int {
        
        @inline(__always)
        get { return Int(rawValue) }
    }
}

// MARK: - Equatable

extension Time: Equatable {
    
    public static func == (lhs: Time, rhs: Time) -> Bool {
        
        return lhs.rawValue == rhs.rawValue
    }
}

