//
//  VLCKitSwiftTests.swift
//  ColemanCDA
//
//  Created by Alsey Coleman Miller on 10/1/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

import Foundation
import XCTest
import VLCKitSwift
import UIKit

final class VLCKitSwiftTests: XCTestCase {
    
    func testPlayVideo() {
        
        let url = URL(string: "http://ring-mac-app-assets.s3.amazonaws.com/player_test/x.mp4")!
        
        let media = Media(url: url)!
        
        let mediaPlayer = Player(media: media)
        
        let expectation = self.expectation(description: "Video finished playing")
        expectation.assertForOverFulfill = false
        
        // notification handler
        func mediaPlayerStateChanged() {
            
            print("State changed to \(mediaPlayer.state)")
            
            switch mediaPlayer.state {
                
            case .ended:
                
                expectation.fulfill()
                
            case .error:
                
                XCTFail("An error ocurred")
                
            default:
                
                break
            }
        }
        
        // register for notifications
        mediaPlayer.eventManager.register(event: .mediaPlayerMediaChanged, callback: mediaPlayerStateChanged)
        mediaPlayer.eventManager.register(event: .mediaPlayerPlaying, callback: mediaPlayerStateChanged)
        mediaPlayer.eventManager.register(event: .mediaPlayerPaused, callback: mediaPlayerStateChanged)
        mediaPlayer.eventManager.register(event: .mediaPlayerEncounteredError, callback: mediaPlayerStateChanged)
        mediaPlayer.eventManager.register(event: .mediaPlayerEndReached, callback: mediaPlayerStateChanged)
        mediaPlayer.eventManager.register(event: .mediaPlayerStopped, callback: mediaPlayerStateChanged)
        mediaPlayer.eventManager.register(event: .mediaPlayerOpening, callback: mediaPlayerStateChanged)
        mediaPlayer.eventManager.register(event: .mediaPlayerBuffering, callback: mediaPlayerStateChanged)
        
        // set view
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        mediaPlayer.drawable = .view(view)
        
        // start playing
        mediaPlayer.play()
        
        waitForExpectations(timeout: 60)
    }
}
