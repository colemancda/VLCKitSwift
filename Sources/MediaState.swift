//
//  MediaState.swift
//  VLCKitSwift
//
//  Created by Alsey Coleman Miller on 10/4/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

import VLC

public extension Media {
    
    public enum State: libvlc_state_t.RawValue {
        
        case nothingSpecial
        case opening
        case buffering
        case playing
        case paused
        case stopped
        case ended
        case error
    }
}

extension Media.State: VLCEnumeration {
    
    public typealias VLCType = libvlc_state_t
}
