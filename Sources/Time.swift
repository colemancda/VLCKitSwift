//
//  Time.swift
//  VLCKitSwift
//
//  Created by Alsey Coleman Miller on 10/9/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

import typealias VLC.libvlc_time_t

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
        get { return rawValue.hashValue }
    }
}

// MARK: - Equatable

extension Time: Equatable {
    
    @inline(__always)
    public static func == (lhs: Time, rhs: Time) -> Bool {
        
        return lhs.rawValue == rhs.rawValue
    }
}

// MARK: - Math Operators

public extension Time {
    
    public static func - (lhs: Time, rhs: Time) -> Time {
        
        return Time(rawValue: lhs.rawValue - rhs.rawValue)
    }
    
    public static func + (lhs: Time, rhs: Time) -> Time {
        
        return Time(rawValue: lhs.rawValue + rhs.rawValue)
    }
}

// MARK: - CustomStringConvertible

extension Time: CustomStringConvertible {
    
    fileprivate static var emptyDescription: String { return "--:--" }
    
    public var description: String {
        
        guard rawValue != .max, rawValue != .min
            else { return Time.emptyDescription }
        
        let duration = seconds
        
        let positiveDuration = abs(seconds)
        
        let sign = duration < 0 ? "-" : ""
        
        if positiveDuration > 3600 {
            
            return String(format: "%@%01ld:%02ld:%02ld",
                          sign,
                          Int(positiveDuration / 3600.0),
                          Int(positiveDuration.truncatingRemainder(dividingBy: 60.0)))
            
        } else {
            
            return String(format: "%@%02ld:%02ld",
                          sign,
                          Int((positiveDuration / 60.0).truncatingRemainder(dividingBy: 60.0)),
                          Int(positiveDuration.truncatingRemainder(dividingBy: 60.0)))
        }
    }
}

public extension Optional where Wrapped == Time {
    
    public var description: String {
        
        return self?.description ?? Time.emptyDescription
    }
}

// MARK: - Computed Properties

public extension Time {
    
    public var miliseconds: Double {
        
        @inline(__always)
        get { return Double(rawValue) }
    }
    
    public var seconds: Double {
        
        @inline(__always)
        get { return miliseconds / 1000 }
    }
}

// MARK: - Internal

internal extension libvlc_time_t {
    
    var nonErrorTime: Time? {
        
        guard self != .error
            else { return nil }
        
        return Time(rawValue: self)
    }
}

internal extension Optional where Wrapped == Time {
    
    var timeValue: libvlc_time_t {
        
        return self?.rawValue ?? 0
    }
}
