//
//  Player.swift
//  VLCKitSwift
//
//  Created by Alsey Coleman Miller on 10/2/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

import CVLC

public final class Player {
    
    // MARK: - Properties
    
    @_versioned
    internal let managedPointer: ManagedPointer<UnmanagedPointer>
    
    // MARK: - Initialization
    
    internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
        
        self.managedPointer = managedPointer
    }
    
    // MARK: - Accessors
    
    #if os(iOS) || os(tvOS) || os(macOS)
    
    /// The `NSView` / `UIView` handler where the media player should render its video output.
    public var drawable: Drawable? {
        
        didSet {
            
            let pointer: UnsafeMutableRawPointer?
            
            if let object = drawable?.rawValue {
                
               pointer = Swift.Unmanaged.passUnretained(object).toOpaque()
                
            } else {
                
                pointer = nil
            }
            
            libvlc_media_player_set_nsobject(rawPointer, pointer)
        }
    }
    
    #endif
    
    public var isPlaying: Bool {
        
        get { return libvlc_media_player_is_playing(rawPointer).boolValue }
    }
    
    public var willPlay: Bool {
        
        get { return libvlc_media_player_will_play(rawPointer).boolValue }
    }
    
    /// Get the number of distinct frequency bands for an equalizer.
    public var bandCount: UInt {
        
        get { return UInt(libvlc_audio_equalizer_get_band_count()) }
    }
    
    
    public var audioChannel: Int {
        
        get { return Int(libvlc_audio_get_channel(rawPointer)) }
        
        set { libvlc_audio_set_channel(rawPointer, Int32(newValue)) }
    }
    
    /// The number of available audio tracks.
    public var trackCount: Int? {
        
        // -1 if unavailable.
        let count = libvlc_audio_get_track_count(rawPointer)
        
        guard count != .error else { return nil }
        
        return Int(count)
    }
    
    // MARK: - Methods
    
    @discardableResult
    public func play() -> Bool {
        
        return libvlc_media_player_play(rawPointer) == .success
    }
    
    public func pause() {
        
        return libvlc_media_player_pause(rawPointer)
    }
    
    public func stop() {
        
        return libvlc_media_player_stop(rawPointer)
    }
}

// MARK: - Internal

extension Player: ManagedHandle {
    
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
            libvlc_media_player_retain(rawPointer)
        }
        
        @inline(__always)
        func release() {
            libvlc_media_player_release(rawPointer)
        }
    }
}

