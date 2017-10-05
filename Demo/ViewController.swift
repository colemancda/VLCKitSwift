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
    
    @IBOutlet fileprivate(set) var playBarButtonItem: UIBarButtonItem! {
        
        didSet { toolbarItems = [playBarButtonItem] }
    }
    
    // MARK: - Properties
    
    fileprivate lazy var mediaPlayer: Player = Player()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // configure media player
        //mediaPlayer.delegate = self
        mediaPlayer.drawable = .view(playerView)
        
        // show toolbar
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        // setup player notifications
        mediaPlayer.eventManager.register(event: .mediaPlayerMediaChanged, callback: mediaPlayerStateChanged)
        mediaPlayer.eventManager.register(event: .mediaPlayerPlaying, callback: mediaPlayerStateChanged)
        mediaPlayer.eventManager.register(event: .mediaPlayerPaused, callback: mediaPlayerStateChanged)
        mediaPlayer.eventManager.register(event: .mediaPlayerEncounteredError, callback: mediaPlayerStateChanged)
        mediaPlayer.eventManager.register(event: .mediaPlayerEndReached, callback: mediaPlayerStateChanged)
        mediaPlayer.eventManager.register(event: .mediaPlayerStopped, callback: mediaPlayerStateChanged)
        mediaPlayer.eventManager.register(event: .mediaPlayerOpening, callback: mediaPlayerStateChanged)
        mediaPlayer.eventManager.register(event: .mediaPlayerBuffering, callback: mediaPlayerStateChanged)
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
            
            self?.playMedia(at: url)
        }))
        
        alert.addTextField {
            textField = $0
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func play(_ sender: AnyObject? = nil) {
        
        let oldState = mediaPlayer.isPlaying
        
        let shouldPlay = oldState == false
        
        if shouldPlay {
            
            if mediaPlayer.state == .stopped {
                
                // reset player
                //mediaPlayer.media = Media(url: mediaPlayer.media.url)
            }
            
            mediaPlayer.play()
            
        } else {
            
            mediaPlayer.pause()
        }
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        let isPlaying = mediaPlayer.state == .playing
        
        let playButton: (item: UIBarButtonSystemItem, label: String) = isPlaying ? (.pause, "Pause") : (.play, "Play")
        
        playBarButtonItem = UIBarButtonItem(barButtonSystemItem: playButton.item, target: self, action: #selector(play))
        playBarButtonItem.accessibilityLabel = playButton.label
    }
    
    fileprivate func playMedia(at url: URL) {
        
        // initialize media
        guard let media = Media(url: url)
            else { return }
        
        // play
        mediaPlayer.media = media
        mediaPlayer.play()
    }
    
    private func mediaPlayerStateChanged() {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let controller = self else { return }
            
            let mediaPlayer = controller.mediaPlayer
            
            assert(Thread.isMainThread, "Should only be called from main thread")
            
            print("State changed to \(mediaPlayer.state)")
            
            controller.configureView()
        }
    }
}

extension ViewController: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        playMedia(at: url)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        controller.dismiss(animated: true, completion: nil)
    }
}

