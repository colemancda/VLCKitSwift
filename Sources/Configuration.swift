//
//  Parameter.swift
//  VLCKitSwift
//
//  Created by Alsey Coleman Miller on 10/2/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

public extension Core {
    
    public struct Configuration {
        
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

public extension Core.Configuration {
    
    public enum Value {
        
        case string(Swift.String)
        case number(Int)
    }
}

extension Core.Configuration.Value: RawRepresentable {
    
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

public extension Core.Configuration.Value {
    
    public var isEmpty: Bool {
        
        switch self {
        case .none:
            return true
        case .string,
             .number:
            return false
        }
    }
}

public extension Core.Configuration {
    
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

extension Core.Configuration: RawRepresentable {
    
    public init?(rawValue: String) {
        
        // TODO: Implement parsing
        fatalError()
    }
    
    public var rawValue: String {
        
        return "--" + (isEnabled ? "" : "no-") + name.rawValue + (value == nil ? "" : "=\(value?.rawValue ?? "")")
    }
}

extension Core.Configuration {
    
    public static var `default`: Parameters {
        
        #if os(iOS)
            return iOS
        #endif
    }
    
    private static var iOS: Set<Configuration> {
        
        var parameters: Set<Configuration> = [
            .noColor,
            .noOsd,
            .noVideoTitleShow,
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
