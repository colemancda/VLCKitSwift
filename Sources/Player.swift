//
//  Player.swift
//  VLCKitSwift
//
//  Created by Alsey Coleman Miller on 10/2/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

import VLC

public final class Player {
    
    // MARK: - Properties
    
    @_versioned
    internal let managedPointer: ManagedPointer<UnmanagedPointer>
    
    // MARK: - Initialization
    
    internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
        
        self.managedPointer = managedPointer
    }
    
    /// Create an empty Media Player object.
    public convenience init(core: Core = .shared) {
        
        guard let rawPointer = libvlc_media_player_new(core.rawPointer)
            else { fatalError("Could not initialize instance") }
        
        self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
    }
    
    public convenience init(media: Media) {
        
        guard let rawPointer = libvlc_media_player_new_from_media(media.rawPointer)
            else { fatalError("Could not initialize instance") }
        
        self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
        
        // hold reference to media object
        self.media = media
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
    
    // Strong reference to internal handle
    public var media: Media? {
        
        didSet {
            
            // update internal handle
            libvlc_media_player_set_media(rawPointer, media?.rawPointer)
        }
    }
    
    public lazy var eventManager: EventManager<Player> = self.getEventManager(libvlc_media_player_event_manager)
    
    /// Get current movie state.
    public var state: Media.State {
        
        get { return Media.State(libvlc_media_player_get_state(rawPointer)) }
    }
    
    /// Whether the media player is playing.
    public var isPlaying: Bool {
        
        get { return libvlc_media_player_is_playing(rawPointer).boolValue }
    }
    
    /// Whether the player able to play.
    public var willPlay: Bool {
        
        get { return libvlc_media_player_will_play(rawPointer).boolValue }
    }
    
    /// Get the number of distinct frequency bands for an equalizer.
    public var bandCount: UInt {
        
        get { return UInt(libvlc_audio_equalizer_get_band_count()) }
    }
    
    /// The current audio channel.
    public var audioChannel: Int {
        
        get { return Int(libvlc_audio_get_channel(rawPointer)) }
        
        set { libvlc_audio_set_channel(rawPointer, Int32(newValue)) }
    }
    
    /// The number of available audio tracks.
    public var trackCount: UInt? {
        
        // -1 if unavailable.
        get { return libvlc_audio_get_track_count(rawPointer).nonErrorValue }
    }
    
    /// Get movie position as percentage between `0.0` and `1.0`.
    public var position: Float {
        
        get { return libvlc_media_player_get_position(rawPointer) }
        
        set { libvlc_media_player_set_position(rawPointer, newValue) }
    }
    
    /// The number of video outputs this media player has.
    public var videoOutputsCount: UInt {
        
        get { return UInt(libvlc_media_player_has_vout(rawPointer)) }
    }
    
    /// The current movie time (in ms).
    ///
    /// - Note: Setting the movie time has no effect if no media is being played.
    /// Not all formats and protocols support this.
    public var time: Time? {
        
        get { return libvlc_media_player_get_time(rawPointer).nonErrorTime }
        
        set { return libvlc_media_player_set_time(rawPointer, newValue.timeValue) }
    }
    
    /// Get movie chapter count.
    public var chapters: UInt? {
        
        get { return libvlc_media_player_get_chapter_count(rawPointer).nonErrorValue }
    }
    
    public var currentChapter: UInt? {
        
        get { return libvlc_media_player_get_chapter(rawPointer).nonErrorValue }
        
        set { libvlc_media_player_set_chapter(rawPointer, CInt(newValue ?? 0)) }
    }
    
    /// Get title chapter count
    ///
    /// - Returns: Number of chapters in title or `nil`.
    public func chapters(for title: Int) -> UInt? {
        
        return libvlc_media_player_get_chapter_count_for_title(rawPointer, Int32(title)).nonErrorValue
    }
    
    // MARK: - Methods
    
    /// Play media.
    @discardableResult
    public func play() -> Bool {
        
        return libvlc_media_player_play(rawPointer) == .success
    }
    
    /// Toggle pause (no effect if there is no media).
    public func pause() {
        
        return libvlc_media_player_pause(rawPointer)
    }
    
    /// Stop (no effect if there is no media). 
    public func stop() {
        
        return libvlc_media_player_stop(rawPointer)
    }
}

// MARK: - EventManager

extension Player: EventEmitter { }

// MARK: - Supporting Types

public extension Player {
    
    public enum State {
        
        case stopped
        case opening
        case buffering
        case ended
        case error
        case playing
        case paused
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

