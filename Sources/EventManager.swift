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
    
    /// Weak reference to the emitter.
    public private(set) weak var emitter: Emitter?
    
    /// Internal callbacks.
    fileprivate var callbacks = [(event: EventType, callback: InternalCallback)]()
    
    // MARK: - Initialization
    
    /// Create a new object that does not retain / own the internal pointer,
    /// instead it retains the Swift wrapper of a the object that owns the event manager.
    internal init(rawPointer: OpaquePointer, emitter: Emitter) {
        
        self.rawPointer = rawPointer
        self.emitter = emitter
    }
    
    deinit {
        
        unregisterAll()
    }
    
    // MARK: - Accessors
    
    /// All the events being observed.
    public var events: Set<EventType> {
        
        return Set(callbacks.map { $0.event })
    }
    
    // MARK: - Methods
    
    @discardableResult
    private func safeRawPointer <Result> (_ body: (RawPointer) throws -> Result) rethrows -> Result? {
        
        // retain
        let strongSelf = self
        let emitter = strongSelf.emitter
        
        // strongly retain emitter for duration of call,
        // or return if weak reference was released
        guard emitter != nil else { return nil }
        
        // get result
        let result = try body(strongSelf.rawPointer)
        
        return result
    }
    
    @discardableResult
    public func register(event: EventType, callback: @escaping Callback) -> Bool {
        
        return safeRawPointer({ [unowned self] (rawPointer) in
            
            let unmanaged = Unmanaged.passUnretained(self)
            
            let objectPointer = unmanaged.toOpaque()
            
            let internalCallback = InternalCallback(userData: objectPointer, eventType: libvlc_event_type_t(event), callbackFunction: EventManagerCallback, callback: callback)
            
            guard libvlc_event_attach(rawPointer, internalCallback)
                else { return false }
            
            // store callback
            callbacks.append((event, internalCallback))
            
            return true
            
        }) ?? false
    }
    
    public func unregister(for event: EventType) {
        
        safeRawPointer { [unowned self] (rawPointer) in
            
            let oldCallbacks = self.callbacks
            
            // detach all callbacks registered for event.
            for (index, internalCallback) in oldCallbacks.enumerated() {
                
                guard event == internalCallback.event else { continue }
                
                // detach from event manager
                libvlc_event_detach(rawPointer, internalCallback.callback)
                
                // release callback
                self.callbacks.remove(at: index)
            }
        }
    }
    
    public func unregisterAll() {
        
        self.events.forEach { [weak self] in self?.unregister(for: $0) }
    }
}

// MARK: - Supporting Types

public extension EventManager {
    
    public typealias Callback = () -> ()
}

public protocol EventEmitter: class {
    
    var eventManager: EventManager<Self> { get }
}

// MARK: - Internal

extension EventManager: Handle { }

fileprivate extension EventManager {
    
    typealias InternalCallback = EventManagerInternalCallback
}

struct EventManagerInternalCallback {
    
    let userData: UnsafeMutableRawPointer
    let eventType: libvlc_event_type_t
    let callbackFunction: libvlc_callback_t
    let callback: () -> ()
}

internal extension EventEmitter where Self: Handle {
    
    func getEventManager(_ function: (RawPointer!) -> EventManager<Self>.RawPointer!) -> EventManager<Self> {
        
        guard let eventManagerRawPointer = function(self.rawPointer)
            else { fatalError("Missing event manager instance") }
        
        let eventManager = EventManager(rawPointer: eventManagerRawPointer, emitter: self)
        
        return eventManager
    }
}

@inline(__always)
private func libvlc_event_attach(_ rawPointer: OpaquePointer, _ internalCallback: EventManagerInternalCallback) -> Bool {
    
    return libvlc_event_attach(rawPointer, internalCallback.eventType, internalCallback.callbackFunction, internalCallback.userData) == .success
}

@inline(__always)
private func libvlc_event_detach(_ rawPointer: OpaquePointer, _ internalCallback: EventManagerInternalCallback) {
    
    return libvlc_event_detach(rawPointer, internalCallback.eventType, internalCallback.callbackFunction, internalCallback.userData)
}

private func EventManagerCallback(event: UnsafePointer<libvlc_event_t>?, data: UnsafeMutableRawPointer?) {
    
    guard let event = event, let data = data else { return }
    
    final class DummyEmitter: EventEmitter {
        
        var eventManager: EventManager<DummyEmitter> { fatalError() }
    }
    
    let eventManager = Unmanaged<EventManager<DummyEmitter>>.fromOpaque(data).takeUnretainedValue()
    
    let eventType = event.pointee.type
    
    // execute callbacks
    eventManager.callbacks
        .filter({ $0.callback.eventType == eventType })
        .forEach({ $0.callback.callback() })
}
