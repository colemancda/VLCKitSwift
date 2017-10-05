//
//  Media.swift
//  VLCKitSwift
//
//  Created by Alsey Coleman Miller on 10/2/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

import VLC
import struct Foundation.URL

public final class Media {
    
    // MARK: - Properties
    
    @_versioned
    internal let managedPointer: ManagedPointer<UnmanagedPointer>
    
    // MARK: - Initialization
    
    deinit {
        
        clearUserData()
    }
    
    internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
        
        self.managedPointer = managedPointer
    }
    
    /// Create a media with a certain given media resource location, for instance a valid URL.
    ///
    /// - Returns: Initializes a new VLCMedia object to use the specified URL
    public convenience init?(url: URL, core: Core = .shared) {
        
        let scheme = url.scheme ?? ""
        
        var urlString = url.absoluteString
        
        // remove percent encoding
        
        let percentEncodedSchemes = ["sftp", "smb"]
        
        if percentEncodedSchemes.contains(scheme) {
            
            urlString = urlString.removingPercentEncoding ?? urlString
        }
        
        self.init(urlString: urlString, core: core)
    }
    
    /// Create a media with a certain given media resource location, for instance a valid URL.
    ///
    /// - Returns: Initializes a new VLCMedia object to use the specified URL.
    internal convenience init?(urlString: String, core: Core = .shared) {
        
        let cString = urlString.vlcCString
        
        guard let rawPointer = libvlc_media_new_location(core.rawPointer, cString)
            else { return nil }
        
        self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
        setUserData() // set user data for callbacks
    }
    
    /// Duplicate the media object.
    public var copy: Media {
        
        guard let copy = _copy
            else { fatalError("Could not duplicate object \(self)") }
        
        return copy
    }
    
    // MARK: - Accessors
    
    /// Get the media type of the media descriptor object.
    public var type: MediaType {
        
        get { return MediaType(libvlc_media_get_type(rawPointer)) }
    }
    
    /// Get the media resource locator (`mrl`) from a media descriptor object.
    public var mrl: String? {
        
        get { return getString(libvlc_media_get_mrl) }
    }
    
    /// Get current state of media descriptor object.
    public var state: State {
        
        get { return State(libvlc_media_get_state(rawPointer)) }
    }
    
    // MARK: - Methods
    
}

// MARK: - EventManager

extension Media: EventEmitter {
    
    public var eventManager: EventManager<Media> {
        
        return getEventManager(libvlc_media_event_manager)
    }
}

// MARK: - Internal

extension Media: ManagedHandle {
    
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
            libvlc_media_retain(rawPointer)
        }
        
        @inline(__always)
        func release() {
            libvlc_media_release(rawPointer)
        }
    }
}

extension Media: UserDataHandle {
    
    static var userDataGetFunction: (OpaquePointer?) -> UnsafeMutableRawPointer? {
        return libvlc_media_get_user_data
    }
    
    static var userDataSetFunction: (_ UnmanagedPointer: OpaquePointer?, _ userdata: UnsafeMutableRawPointer?) -> () {
        return libvlc_media_set_user_data
    }
}

extension Media: CopyableHandle {
    
    var _copy: Media? {
        
        guard let rawPointer = libvlc_media_duplicate(rawPointer)
            else { return nil }
        
        let copy = Media(ManagedPointer(UnmanagedPointer(rawPointer)))
        copy.setUserData()
        
        return copy
    }
}

