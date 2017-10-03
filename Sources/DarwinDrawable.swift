//
//  Drawable.swift
//  VLCKitSwift
//
//  Created by Alsey Coleman Miller on 10/2/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(macOS)
    import Foundation
#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

public typealias Drawable = DarwinDrawable

public enum DarwinDrawable {
    
    case view(View)
    case layer(Layer)
}

public extension DarwinDrawable {
    
    #if os(iOS) || os(tvOS)
    public typealias View = UIView
    public typealias Layer = CALayer
    #elseif os(macOS)
    public typealias View = VLCMediaPlayerView
    public typealias Layer = VLCMediaPlayerLayer
    #endif
}
    
    extension DarwinDrawable: RawRepresentable {
        
        public typealias RawValue = NSObject
        
        public init?(rawValue: RawValue) {
            
            if let view = rawValue as? View {
                self = .view(view)
            } else if let layer = rawValue as? Layer {
                self = .layer(layer)
            } else {
                return nil
            }
        }
        
        public var rawValue: RawValue {
            
            switch self {
            case let .view(object): return object
            case let .layer(object): return object
            }
        }
    }
    
#endif
