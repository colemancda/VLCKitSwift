//
//  EventManager.swift
//  VLCKitSwift
//
//  Created by Alsey Coleman Miller on 10/4/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

import VLC

public final class EventManager<Emitter: EventEmitter> {
    
    // MARK: - Properties
    
    @_versioned
    internal let rawPointer: OpaquePointer // Not MRC
    
    public let emitter: Emitter
    
    // MARK: - Initialization
    
    /// Create a new object wrapper that is does not retain / own the internal pointer,
    /// instead it retains the Swift wrapper of a the object that owns the event manager.
    internal init(rawPointer: OpaquePointer, emitter: Emitter) {
        
        self.rawPointer = rawPointer
        self.emitter = emitter
    }
    
    // MARK: - Methods
    
    
}

// MARK: - Supporting Types

public protocol EventEmitter: class {
    
    var eventManager: EventManager<Self> { get }
}

internal extension EventEmitter where Self: Handle {
    
    func getEventManager(_ function: (RawPointer!) -> EventManager<Self>.RawPointer!) -> EventManager<Self> {
        
        let eventManagerRawPointer = function(self.rawPointer)!
        
        let eventManager = EventManager(rawPointer: eventManagerRawPointer, emitter: self)
        
        return eventManager
    }
}

// MARK: - Internal

extension EventManager: Handle { }
