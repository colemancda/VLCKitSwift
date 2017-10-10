//
//  VLCKitSwift.swift
//  ColemanCDA
//
//  Created by Alsey Coleman Miller on 10/1/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

import VLC

/// Object used for the core functionality of VLC.
public final class Core {
    
    public static let shared: Core = Core()!
    
    // MARK: - Properties
    
    @_versioned
    internal let managedPointer: ManagedPointer<UnmanagedPointer>
    
    // MARK: - Initialization
    
    deinit {
        
        // unregister and reset logging (in case Swift object is released before C instance)
        self.log = nil
    }
    
    internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
        
        self.managedPointer = managedPointer
    }
    
    public convenience init?(configuration: Configuration = .default) {
        
        let options = configuration.options.rawValues
        
        let count = options.count
        
        guard let rawPointer = options.withCString(body: { libvlc_new(Int32(count), $0) })
            else { return nil }
        
        self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
    }
    
    // MARK: - Accessors
    
    public static var version: String {
        
        get { return String(vlcCString: libvlc_get_version()) ?? "" }
    }
    
    public static var compiler: String {
        
        get { return String(vlcCString: libvlc_get_compiler()) ?? "" }
    }
    
    /// Retrieve VLC changeset.
    ///
    /// Example: "aa9bce0bc4"
    ///
    /// - Return: a string containing the libvlc changeset
    public static var changeset: String {
        
        get { return String(vlcCString: libvlc_get_changeset()) ?? "" }
    }
    
    public var log: Log.Callback? {
        
        didSet { updateLogging() }
    }
    
    private func updateLogging() {
        
        if log == nil {
            
            libvlc_log_unset(rawPointer)
            
        } else {
            
            let objectPointer = Swift.Unmanaged.passUnretained(self).toOpaque()
            
            libvlc_log_set(rawPointer, { (data, level, context, format, args) in
                
                guard let objectPointer = UnsafeRawPointer(data)
                    else { return }
                
                let message = Log.Message.from(callback: (level: level, context: context, format: format, arguments: args))
                                
                let core = Swift.Unmanaged<Core>.fromOpaque(objectPointer).takeUnretainedValue()
                
                core.log?(message)
                
            }, objectPointer)
        }
    }
    
    // MARK: - Methods
    
    /// Sets the application name. LibVLC passes this as the user agent string when a protocol requires it.
    public func setHumanReadableName(_ name: String, with userAgent: String) {
        
        libvlc_set_user_agent(rawPointer, name.vlcCString, userAgent.vlcCString)
    }
    
    /// Sets some meta-information about the application.
    public func setApplication(identifier: String, version: String, iconName: String) {
        
        libvlc_set_app_id(rawPointer, identifier.vlcCString, version.vlcCString, iconName.vlcCString)
    }
}

// MARK: - Internal

extension VLCKitSwift.Core: ManagedHandle {
    
    typealias RawPointer = UnmanagedPointer.RawPointer
    
    struct UnmanagedPointer: VLCKitSwift.UnmanagedPointer {
        
        typealias RawPointer = OpaquePointer
        
        let rawPointer: RawPointer
        
        @inline(__always)
        init(_ rawPointer: RawPointer) {
            self.rawPointer = rawPointer
        }
        
        @inline(__always)
        func retain() {
            libvlc_retain(rawPointer)
        }
        
        @inline(__always)
        func release() {
            libvlc_release(rawPointer)
        }
    }
}
