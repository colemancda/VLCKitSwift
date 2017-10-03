//
//  Log.swift
//  VLCKitSwift
//
//  Created by Alsey Coleman Miller on 10/2/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

import CVLC
import class Foundation.NSString

public struct Log { }

public extension Log {
    
    public typealias Callback = (Message) -> ()
}

public extension Log {
    
    /// A log entry.
    public struct Message {
        
        public let level: Level
        
        public let context: Context
        
        public let debug: Context.Debug
        
        public let message: String
    }
}

internal extension Log.Message {
    
    static func from(callback: (level: Int32, context: OpaquePointer?, format: UnsafePointer<Int8>?, arguments: CVaListPointer?)) -> Log.Message {
        
        let format = String(vlcCString: callback.format) ?? ""
        
        // FIXME: Swift compiler error
        let arguments: CVaListPointer? = callback.arguments
        
        let message: String
        
        if let arguments = arguments {
            
            message = NSString(format: format, arguments: arguments) as String
            
        } else {
            
            message = format
        }
        
        guard let level = Log.Level(rawValue: Int(callback.level))
            else { fatalError("Invalid log level \(callback.level)") }
        
        guard let contextRawPointer = callback.context
            else { fatalError("Missing context pointer") }
        
        let context = Log.Context.from(context: contextRawPointer)
        
        let debug = Log.Context.Debug.from(context: contextRawPointer)
        
        return Log.Message(level: level, context: context, debug: debug, message: message)
    }
}

public extension Log {
    
    public enum Level: Int {
        
        /// Debug message
        case debug
        
        /// Important informational message
        case notice
        
        /// Warning (potential error) message
        case warning
        
        /// Error message
        case error
    }
}

public extension Log {
    
    /// Meta-information about a log message.
    ///
    /// This information is mainly meant for **manual** troubleshooting.
    public struct Context {
        
        /// The type name of the VLC object emitting the message.
        public var name: String?
        
        /// The object header.
        public var header: String?
        
        /// A temporaly-unique object identifier.
        public var identifier: UInt
    }
}

internal extension Log.Context {
    
    /// Gets log message info.
    static func from(context rawPointer: OpaquePointer) -> Log.Context {
        
        var nameCString: UnsafePointer<CChar>?
        
        var headerCString: UnsafePointer<CChar>?
        
        var line: uintptr_t = 0
        
        libvlc_log_get_object(rawPointer, &nameCString, &headerCString, &line)
        
        return Log.Context(name: String(vlcCString: nameCString), header: String(vlcCString: headerCString), identifier: UInt(line))
    }
}

public extension Log.Context {
    
    /// Self-debug information about a log message.
    public struct Debug {
        
        /// The name of the VLC module emitting the message.
        public var module: String?
        
        /// The name of the source code module (i.e. file).
        public var file: String?
        
        /// The line number within the source code module.
        public var line: UInt
    }
}

internal extension Log.Context.Debug {
    
    /// Gets log message debug infos.
    static func from(context rawPointer: OpaquePointer) -> Log.Context.Debug {
        
        var moduleCString: UnsafePointer<CChar>?
        
        var fileCString: UnsafePointer<CChar>?
        
        var line: CUnsignedInt = 0
        
        libvlc_log_get_context(rawPointer, &moduleCString, &fileCString, &line)
        
        return Log.Context.Debug(module: String(vlcCString: moduleCString), file: String(vlcCString: fileCString), line: UInt(line))
    }
}
