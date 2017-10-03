//
//  MediaType.swift
//  VLCKitSwift
//
//  Created by Alsey Coleman Miller on 10/2/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

import CVLC

/// Media Type
public enum MediaType: UInt32 {
    
    case unknown
    case file
    case directory
    case disc
    case stream
    case playlist
}

extension MediaType: VLCEnumeration {
    
    public typealias VLCType = libvlc_media_type_t
}
