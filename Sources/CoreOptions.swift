//
//  Parameter.swift
//  VLCKitSwift
//
//  Created by Alsey Coleman Miller on 10/2/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

public extension Core {
    
    public struct Parameters: RawRepresentable {
        
        public typealias Element = String
        
        public typealias RawValue = [Element]
        
        public var rawValue: RawValue
        
        public init(rawValue: RawValue) {
            
            self.init(rawValue: rawValue)
        }
    }
}

extension Core.Parameters: Equatable {
    
    public static func ==(lhs: Core.Parameters, rhs: Core.Parameters) -> Bool {
        
        return lhs.rawValue == rhs.rawValue
    }
}

extension Core.Parameters: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Element...) {
        
        self.init(rawValue: elements)
    }
}

// MARK: - Collection

extension Core.Parameters: RandomAccessCollection {
    
    public subscript(bounds: Range<Int>) -> RandomAccessSlice<NamedColorList> {
        
        return RandomAccessSlice<NamedColorList>(base: self, bounds: bounds)
    }
    
    /// The start `Index`.
    public var startIndex: Int {
        
        return 0
    }
    
    /// The end `Index`.
    ///
    /// This is the "one-past-the-end" position, and will always be equal to the `count`.
    public var endIndex: Int {
        
        return count
    }
    
    public func index(before i: Int) -> Int {
        return i - 1
    }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
    
    public func makeIterator() -> IndexingIterator<NamedColorList> {
        
        return IndexingIterator(_elements: self)
    }
}

extension Core.Parameters {
    
    public static var `default`: Parameters {
        
        
    }
    
    private static var iOS: Parameters {
        
        var parameters: Parameters = [
            "--no-color",
            "--no-osd",
            "--no-video-title-show",
            "--no-stats",
            "--no-snapshot-preview",
            "--avcodec-fast",
            "--text-renderer=freetype",
            "--avi-index=3"
        ]
        
        #if arch(i386)
            parameters.append
        #endif
        
        return parameters
    }
}
