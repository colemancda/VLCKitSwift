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
    
    /// The configuration's options.
    public var options: Set<Option>
    
    public init(options: Set<Option> = []) {
        
        self.options = options
    }
}

public extension Configuration {
    
    public var isEmpty: Bool {
        
        return options.isEmpty
    }
}

// MARK: - Equatable

extension Configuration: Equatable {
    
    public static func == (lhs: Configuration, rhs: Configuration) -> Bool {
        
        return lhs.options == rhs.options
    }
}

// MARK: - Hashable

extension Configuration: Hashable {
    
    public var hashValue: Int {
        
        return options.hashValue
    }
}

// MARK: - ExpressibleByArrayLiteral

extension Configuration: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Option...) {
        
        self.init(options: Set(elements))
    }
}

// MARK: - Static Instances

extension Configuration {
    
    /// An empty configuration.
    public static var empty: Configuration { return [] }
    
    /// Create a configuration based on the running program's command line parameters.
    public static var commandLine: Configuration {
        
        let options = CommandLine.arguments.flatMap { Option(rawValue: $0) }
        
        return Configuration(options: Set(options))
    }
    
    /// The default configuration for the current platform and hardware.
    public static var `default`: Configuration {
        
        #if os(iOS) || os(tvOS)
            return .iOS
        #elseif os(macOS)
            return .macOS
        #else
            return []
        #endif
    }
    
    /// Configuration for iOS devices.
    private static var iOS: Configuration {
        
        var configuration: 🛠 = [
            🚫(.color),
            🚫(.osd),
            🚫(.videoTitleShow),
            🚫(.stats),
            🚫(.snapshotPreview),
            🔧(.textRenderer, "freetype"),
            🔧(.aviIndex, 3)
        ]
        
        #if !__LP64__ && !NOSCARYCODECS
            configuration.options.insert(🔧(.avcodecFast))
        #endif
        
        return configuration
    }
    
    /// Configuration for macOS computers.
    private static var macOS: Configuration {
        
        return [
            🔧(.playAndPause),
            🚫(.color),
            🚫(.videoTitleShow),
            🔧(.verbose, 4),
            🚫(.soundOutputKeep),
            🔧(.videoOutput, "macosx"),
            🔧(.textRenderer, "freetype"),
            🔧(.extraintf, "macosx_dialog_provider")
        ]
    }
}

// MARK: - Supporting Types

// MARK: - Option

public typealias 🔧 = Configuration.Option

public extension Configuration {
    
    public struct Option {
        
        public var name: Name
        
        public var argument: Argument
        
        public init(name: Name, argument: Argument = .none) {
            
            self.name = name
            self.argument = argument
        }
    }
}

public extension Configuration.Option {
    
    public var isEnabled: Bool {
        
        switch argument {
        case .disabled: return true
        case .none, .value: return false
        }
    }
    
    public var value: String {
        
        switch argument {
        case .disabled, .none: return ""
        case let .value(value): return value
        }
    }
}

extension Configuration.Option: RawRepresentable {
    
    public init?(rawValue: String) {
        
        // TODO: Implement parsing
        fatalError()
    }
    
    public var rawValue: String {
        
        return "--" + (isEnabled ? "" : "no-") + name.rawValue + (value.isEmpty ? "" : "=" + value)
    }
}

extension Configuration.Option: Equatable {
    
    public static func == (lhs: Configuration.Option, rhs: Configuration.Option) -> Bool {
        
        return lhs.rawValue == rhs.rawValue
    }
}

extension Configuration.Option: Hashable {
    
    public var hashValue: Int {
        
        return rawValue.hashValue
    }
}

public extension Configuration.Option {
    
    public init(_ name: Name) {
        
        self.name = name
        self.argument = .none
    }
    
    public init(_ name: Name, _ value: String) {
        
        self.name = name
        self.argument = .value(value)
    }
    
    public init(_ name: Name, _ value: Int) {
        
        self.name = name
        self.argument = .value("\(value)")
    }
    
    public static func no(_ name: Name) -> Configuration.Option {
        
        return Configuration.Option(name: name, argument: .disabled)
    }
}

public func 🚫(_ name: Configuration.Option.Name) -> Configuration.Option {
    
    return .no(name)
}

// MARK: Option.Name

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

// MARK: Option.Argument

public extension Configuration.Option {
    
    public enum Argument {
        
        case none
        case disabled
        case value(String)
    }
}
