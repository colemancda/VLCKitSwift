//
//  Parameter.swift
//  VLCKitSwift
//
//  Created by Alsey Coleman Miller on 10/2/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

public typealias 🛠 = Configuration

/// VLC settings
public struct Configuration {
    
    public var options: Set<Option>
    
    public init(options: Set<Option> = []) {
        
        self.options = options
    }
}


extension Configuration: Equatable {
    
    public static func == (lhs: Configuration, rhs: Configuration) -> Bool {
        
        return lhs.options == rhs.options
    }
}

extension Configuration: Hashable {
    
    public var hashValue: Int {
        
        return options.hashValue
    }
}

extension Configuration: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Option...) {
        
        self.init(options: Set(elements))
    }
}

// MARK: - Collection
/*
extension Configuration: Collection {
    
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
*/
// MARK: - Supporting Types

public typealias 🔧 = Configuration.Option

public extension Configuration {
    
    public struct Option {
        
        public var name: Name
        
        public var isEnabled: Bool
        
        public var value: Value?
        
        public init(name: Name, isEnabled: Bool = true, value: Value? = nil) {
            
            self.name = name
            self.isEnabled = isEnabled
            self.value = value
        }
    }
}

public extension Configuration.Option {
    
    public enum Value {
        
        case string(Swift.String)
        case number(Int)
    }
}

extension Configuration.Option.Value: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: Self.StringLiteralType) {
        
        self = .string(value)
    }
}

extension Configuration.Option.Value: RawRepresentable {
    
    public init(rawValue: String) {
        
        if let number = Int(rawValue) {
            
            self = .number(number)
            
        } else {
            
            self = .string(rawValue)
        }
    }
    
    public var rawValue: String {
        
        switch self {
            case let .number(value): return "\(value)"
            case let .string(value): return value
        }
    }
}

extension Configuration.Option: Hashable {
    
    public var hashValue: Int {
        
        return rawValue.hashValue
    }
}

public extension Configuration.Option {
    
    public enum Name: String {
        
        case color
        case osd
        case videoTitleShow = "video-title-show"
        case stats
        case snapshotPreview = "snapshot-preview"
        case avcodecFast = "avcodec-fast"
        case textRenderer = "text-renderer"
        case aviIndex = "avi-index"
        case playAndPause = "play-and-pause"
        case verbose
        case soundOutputKeep = "sout-keep"
        case videoOutput = "vout"
        case extraintf
    }
}

extension Configuration.Option: RawRepresentable {
    
    public init?(rawValue: String) {
        
        // TODO: Implement parsing
        fatalError()
    }
    
    public var rawValue: String {
        
        return "--" + (isEnabled ? "" : "no-") + name.rawValue + (value == nil ? "" : "=\(value?.rawValue ?? "")")
    }
}

extension Configuration {
    
    public static var `default`: Configuration {
        
        #if os(iOS)
            return iOS
        #endif
    }
    
    private static var iOS: Configuration {
        
        var configuration: Configuration = [
            🔧(name: .color, isEnabled: false),
            🔧(name: .osd, isEnabled: false),
            🔧(name: .videoTitleShow, isEnabled: false),
            🔧(name: .stats, isEnabled: false),
            🔧(name: .snapshotPreview, isEnabled: false),
            🔧(name: .avcodecFast),
            🔧(name: .textRenderer, value: "freetype"),
            🔧(name: .aviIndex, value: 3)
        ]
        
        #if arch(i386) || arch(x86_64)
        //parameters.append
        #endif
        
        return configuration
    }
}
