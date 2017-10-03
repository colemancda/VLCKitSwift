//
//  Parameter.swift
//  VLCKitSwift
//
//  Created by Alsey Coleman Miller on 10/2/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

public extension Core {
    
    public enum Configuration {
        
        case noColor
        case noOsd
        case noVideoTitleShow
        case noStats
        case noSnapshotPreview
        case avcodecFast
        case textRenderer(String)
        case aviIndex(Int)
        case playAndPause
        case verbose(Int)
        case noSoundOutKeep
        case videoOut(String)
        case extraintf(String)
    }
}

extension Core.Configuration /* :RawRepresentable */ {
    
    public var rawValue: String {
        
        switch self {
            
        case noColor: return
        case noOsd
        case noVideoTitleShow
        case noStats
        case noSnapshotPreview
        case avcodecFast
        case textRenderer(String)
        case aviIndex(Int)
        case playAndPause
        case verbose(Int)
        case noSoundOutKeep
        case videoOut(String)
        case extraintf(String)
        }
    }
}

extension Core.Options {
    
    public static var `default`: Parameters {
        
        
    }
    
    private static var iOS: Set<Option> {
        
        var parameters: Parameters = [
            .noColor,
            .noOsd,
            .noVideoTitleShow,
            "--no-stats",
            "--no-snapshot-preview",
            "--avcodec-fast",
            "--text-renderer=freetype",
            "--avi-index=3"
        ]
        
        #if arch(i386)
            parameters.append
        #endif
        
        return parameters
    }
}
