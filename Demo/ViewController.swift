//
//  ViewController.swift
//  Demo
//
//  Created by Alsey Coleman Miller on 10/5/17.
//  Copyright © 2017 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import VLCKitSwift

final class ViewController: UIViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var playerView: UIView!
    
    @IBOutlet private(set) weak var topControlsView: UIView!
    
    @IBOutlet private(set) weak var playPauseButton: UIBarButtonItem!
    
    @IBOutlet private(set) weak var previousButton: UIBarButtonItem!
    
    @IBOutlet private(set) weak var nextButton: UIBarButtonItem!
    
    @IBOutlet private(set) weak var timeSlider: UISlider!
    
    @IBOutlet private(set) weak var streamingProgressIndicatorSlider: UISlider!
    
    @IBOutlet private(set) weak var loadingViewContainer: UIView!
    
    @IBOutlet private(set) weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private(set) weak var elapsedTimeLabel: UILabel!
    
    @IBOutlet private(set) weak var remainingTimeLabel: UILabel!
    
    // MARK: - Properties
    
    private var mediaPlayer: Player?
    
    private var mediaURL: URL? {
        
        didSet { if let url = mediaURL { playMedia(at: url) } }
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        configureView()
    }
    
    // MARK: - Actions
    
    @IBAction func open(_ sender: AnyObject? = nil) {
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeMPEG4 as String], in: .import)
        documentPicker.delegate = self
        
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func openURL(_ sender: AnyObject? = nil) {
        
        let alert = UIAlertController(title: "Open URL",
                                      message: "Type the URL of the video you want to play",
                                      preferredStyle: .alert)
        
        var textField: UITextField!
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { [weak self] _ in
            
            alert.dismiss(animated: true) { }
            
            let text = textField.text ?? ""
            
            print("Will play \(text)")
            
            guard let url = URL(string: text) else { return }
            
            self?.mediaURL = url
        }))
        
        alert.addTextField {
            textField = $0
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func playPause(_ sender: AnyObject? = nil) {
        
        let mediaURL = self.mediaURL
        
        background { (player) in
            
            guard let mediaPlayer = player else { return }
            
            let oldState = mediaPlayer.isPlaying
            
            let shouldPlay = oldState == false
            
            if shouldPlay {
                
                if mediaPlayer.state == .ended,
                    let url = mediaURL {
                    
                    // reset player
                    mediaPlayer.stop()
                    mediaPlayer.media = Media(url: url)
                }
                
                mediaPlayer.play()
                
            } else {
                
                mediaPlayer.pause()
            }
        }
    }
    
    @IBAction func changePosition(_ sender: UISlider) {
        
        let newValue = sender.value
        
        background { [weak self] (player) in
            
            guard let mediaPlayer = player else { return }
            
            if mediaPlayer.state == .playing {
                
                mediaPlayer.pause()
            }
            
            mediaPlayer.position = newValue
            
            // update UI
            self?.main { $0.configureViewForTimeChange() }
        }
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        assert(Thread.isMainThread, "Should only be called from main thread")
        
        let emptyMedia = self.mediaURL == nil
        let isPlaying = mediaPlayer.state == .playing
        let isBuffering = mediaPlayer.state == .opening
        
        // hide or show media player view and controls
        self.playerView.isHidden = emptyMedia
        self.topControlsView.isHidden = emptyMedia
        self.navigationController?.setToolbarHidden(emptyMedia || isBuffering, animated: true)
        self.loadingViewContainer.isHidden = isBuffering == false
        self.timeSlider.isHidden = isBuffering
        self.streamingProgressIndicatorSlider.isHidden = isBuffering
        
        // convigure loading view
        if isBuffering, self.activityIndicator.isAnimating == false {
            
            self.activityIndicator.startAnimating()
            
        } else {
            
            self.activityIndicator.isHidden = false
            self.activityIndicator.stopAnimating()
        }
        
        // configure play button
        configurePlayPauseButton()
        configureViewForPositionChange()
        configureViewForTimeChange()
    }
    
    fileprivate func playMedia(at url: URL) {
        
        assert(Thread.isMainThread, "Should only be called from main thread")
        
        let playerView = self.playerView!
        
        let mediaPlayerStateChanged = self.mediaPlayerStateChanged
        
        background { [weak self] (player) in
            
            // initialize media
            guard let media = Media(url: url)
                else { fatalError("Invalid url: \(url)") }
            
            let oldPlayer = player
            oldPlayer?.stop() // stop playing
            
            // create new player
            let mediaPlayer = Player()
            
            // configure media player
            mediaPlayer.drawable = .view(playerView)
            
            // setup player notifications
            mediaPlayer.eventManager.register(event: .mediaPlayerMediaChanged, callback: mediaPlayerStateChanged)
            mediaPlayer.eventManager.register(event: .mediaPlayerPlaying, callback: mediaPlayerStateChanged)
            mediaPlayer.eventManager.register(event: .mediaPlayerPaused, callback: mediaPlayerStateChanged)
            mediaPlayer.eventManager.register(event: .mediaPlayerEncounteredError, callback: mediaPlayerStateChanged)
            mediaPlayer.eventManager.register(event: .mediaPlayerEndReached, callback: mediaPlayerStateChanged)
            mediaPlayer.eventManager.register(event: .mediaPlayerStopped, callback: mediaPlayerStateChanged)
            mediaPlayer.eventManager.register(event: .mediaPlayerOpening, callback: mediaPlayerStateChanged)
            mediaPlayer.eventManager.register(event: .mediaPlayerBuffering, callback: mediaPlayerStateChanged)
            mediaPlayer.eventManager.register(event: .mediaPlayerTimeChanged, callback: {
                DispatchQueue.main.async { [unowned self] in self.configureViewForTimeChange() }
            })
            mediaPlayer.eventManager.register(event: .mediaPlayerPositionChanged, callback: {
                DispatchQueue.main.async { [unowned self] in self.configureViewForPositionChange() }
            })
            
            // play
            mediaPlayer.media = media
            player = mediaPlayer
            
            // callbacks will trigger UI changes
            self?.main { $0.playPause() }
        }
    }
    
    @objc(VLCBlock)
    final class Block: NSObject {
        
        let block: (inout Player?) -> ()
        
        init(_ block: @escaping (inout Player?) -> ()) {
            
            self.block = block
        }
    }
    
    @objc(backgroundMethod:)
    private func backgroundMethod(_ async: Block) {
        
        guard Thread.isMainThread else { async.block(&self.mediaPlayer); return }
        
        performSelector(inBackground: #selector(backgroundMethod), with: async)
    }
    
    private func background(_ async: @escaping (inout Player?) -> ()) {
        
        guard Thread.isMainThread else { async(&self.mediaPlayer); return }
        
        let block = Block(async)
        
        performSelector(inBackground: #selector(backgroundMethod), with: block)
    }
    
    private func main(_ async: @escaping (ViewController) -> ()) {
        
        DispatchQueue.main.async { [weak self] in
            guard let controller = self else { return }
            async(controller)
        }
    }
    
    private func sync <Result> (_ block: @escaping (Player?) throws -> Result) rethrows {
        
        block()
    }
    
    private func mediaPlayerStateChanged() {
        
        background { if let player = $0 { print("State changed to \(player.state)") } }
        
        main { $0.configureView() }
    }
    
    private func configureViewForTimeChange() {
        
        assert(Thread.isMainThread, "Should only be called from main thread")
        
        let elapsedTimeText: String
        
        let remainingTimeText: String
        
        if let currentTime = mediaPlayer.time,
            let duration = mediaPlayer.media?.duration {
            
            elapsedTimeText = currentTime.description
            
            let remainingTime = currentTime - duration
            
            remainingTimeText = remainingTime.description
            
        } else {
            
            elapsedTimeText = Time?.none.description
            
            remainingTimeText = Time?.none.description
        }
        
        self.elapsedTimeLabel.text = elapsedTimeText
        
        self.remainingTimeLabel.text = remainingTimeText
    }
    
    private func configureViewForPositionChange() {
        
        assert(Thread.isMainThread, "Should only be called from main thread")
        
        let position = mediaPlayer.position
        
        print("Position changed to \(position)")
        
        self.timeSlider.value = position
    }
    
    private func configurePlayPauseButton() {
        
        assert(Thread.isMainThread, "Should only be called from main thread")
        
        let isPlaying = mediaPlayer.state == .playing
        
        let systemItem: UIBarButtonSystemItem = isPlaying ? .pause : .play
        
        let label = isPlaying ? "Pause" : "Play"
        
        var toolbarItems = self.toolbarItems ?? []
        
        guard let index = toolbarItems.index(of: self.playPauseButton) else { return }
        
        let newButton = UIBarButtonItem(barButtonSystemItem: systemItem, target: self, action: #selector(playPause))
        
        newButton.accessibilityLabel = label
        
        self.playPauseButton = newButton
        
        toolbarItems[index] = newButton
        
        self.toolbarItems = toolbarItems
    }
}

extension ViewController: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        self.mediaURL = url
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        controller.dismiss(animated: true, completion: nil)
    }
}
