//
//  VideoViewerViewController.swift
//  imageorg
//
//  Created by Finn Schlenk on 23.10.18.
//  Copyright © 2018 Finn Schlenk. All rights reserved.
//

import Cocoa
import AVKit

enum PlayerStatus {
    case playing
    case paused
}

class VideoViewerViewController: NSViewController {

    var video: Video? {
        didSet {
            guard let video = video else {
                return
            }

            let fileURL = URL(fileURLWithPath: video.filePath)
            player = AVPlayer(url: fileURL)
            playerView.player = player
            player?.play()

            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        }
    }
    var player: AVPlayer?
    var currentPlayerStatus: PlayerStatus = .playing
    var keyDownMonitor: Any!
    fileprivate var videoEndObserver: Any?
    fileprivate let spaceKey: UInt16 = 0x31
    fileprivate let jKey: UInt16 = 0x26
    fileprivate let kKey: UInt16 = 0x28
    fileprivate let lKey: UInt16 = 0x25

    @IBOutlet weak var playerView: AVPlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.window?.makeFirstResponder(playerView)

        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] in
            guard let strongSelf = self else {
                return nil
            }

            if strongSelf.myKeyDown(with: $0) {
                return nil
            } else {
                return $0
            }
        }
    }

    override func viewDidDisappear() {
        NSEvent.removeMonitor(keyDownMonitor)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)

        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
    }

    @objc func playerDidFinishPlaying(notification: NSNotification){
        player?.seek(to: CMTime.zero)
        player?.play()
    }

    func seek(timeInSeconds: Double) {
        guard let currentTime = player?.currentTime() else {
            return
        }
        let secondsAhead = CMTime(seconds: currentTime.seconds + timeInSeconds, preferredTimescale: currentTime.timescale)
        player?.seek(to: secondsAhead)
    }

    func play() {
        currentPlayerStatus = .playing
        player?.play()
    }

    func pause() {
        currentPlayerStatus = .paused
        player?.pause()
    }

    func togglePlayerStatus() {
        if currentPlayerStatus == .paused {
            play()
        } else {
            pause()
        }
    }

    func myKeyDown(with event: NSEvent) -> Bool {
        // handle keyDown only if current window has focus, i.e. is keyWindow
        guard let locWindow = self.view.window,
            NSApplication.shared.keyWindow === locWindow else { return false }
        switch event.keyCode {
        case spaceKey, kKey:
            togglePlayerStatus()
            return true
        case jKey:
            seek(timeInSeconds: -5.0)
            return true
        case lKey:
            seek(timeInSeconds: 5.0)
            return true
        default:
            return false
        }
    }
}
