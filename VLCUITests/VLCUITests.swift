//
//  VLCUITests.swift
//  VLCUITests
//
//  Created by Alsey Coleman Miller on 10/5/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

import Foundation
import XCTest
import VLCKitSwift
import UIKit

final class VLCUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPlayVideo() {
        
        let videoURLString = "http://ring-mac-app-assets.s3.amazonaws.com/player_test/x.mp4"
        
        let app = XCUIApplication()
        
        XCTContext.runActivity(named: "Entering video URL") { (activity) in
            
            app.navigationBars.buttons["URL"].tap()
            
            app.alerts.textFields.firstMatch.tap()
            
            app.typeText(videoURLString)
            
            app.alerts.buttons["Open"].tap()
        }
        
        XCTContext.runActivity(named: "Wait for video to start") { (activity) in
            
            app.buttons["Pause"].waitForExistence(timeout: 5)
        }
        
        XCTContext.runActivity(named: "Wait for video to start") { (activity) in
            
            app.buttons["Play"].waitForExistence(timeout: 30)
        }
        
        XCTContext.runActivity(named: "When I add attachment to activity") { (activity) in
            let screen = XCUIScreen.main
            let fullscreenshot = screen.screenshot()
            let fullScreenshotAttachment = XCTAttachment(screenshot: fullscreenshot)
            fullScreenshotAttachment.lifetime = .keepAlways
            activity.add(fullScreenshotAttachment)
        }
    }
}
