//
//  VLCKitSwift.swift
//  ColemanCDA
//
//  Created by Alsey Coleman Miller on 10/1/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

import CVLC
import Foundation

/// Object used for the core functionality of VLC.
public final class Core {
    
    public static let shared = Core()
    
    // MARK: - Properties
    
    @_versioned
    internal let managedPointer: ManagedPointer<UnmanagedPointer>
    
    // MARK: - Initialization

    internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
        
        self.managedPointer = managedPointer
    }
    
    internal convenience init(options: [String] = []) {
        
        let count = options.count
        
        
        
        guard let rawPointer = libvlc_new(count, $0)
            else { fatalError("Could not initialize new instance") }
        
        self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
    }
    
    // MARK: - Accessors
    
    
    
    // MARK: - Methods
    
    
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
