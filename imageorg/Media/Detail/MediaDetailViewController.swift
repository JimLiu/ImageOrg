//
//  MediaDetailViewController.swift
//  imageorg
//
//  Created by Finn Schlenk on 23.10.18.
//  Copyright © 2018 Finn Schlenk. All rights reserved.
//

import Cocoa

class MediaDetailViewController: MediaViewController {

    @IBOutlet weak var containerView: NSView!

    private let deleteKey: UInt16 = 0x33
    private let leftArrowKey: UInt16 = 0x7B
    private let rightArrowKey: UInt16 = 0x7C

    var keyDownMonitor: Any!
    var imageViewerViewController: ImageViewerViewController?
    var videoViewerViewController: VideoViewerViewController?
    var mediaStore = MediaStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let media = mediaStore.selectedMedia else {
            return
        }

        NSApplication.shared.keyWindow?.title = media.name

        if media is Image {
            setupImageViewer()
        } else if media is Video {
            setupVideoViewer()
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        subscribeToKeyboardEvents()
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterFullScreen), name: NSWindow.didEnterFullScreenNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleExitFullScreen), name: NSWindow.willExitFullScreenNotification, object: nil)
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        if let mediaToolbar = mediaToolbar {
            let configuration = MediaGalleryToolbarConfiguration(toolbar: mediaToolbar)
            mediaToolbar.replaceItems(for: configuration)
        }

        unsubscribeFromKeyboardEvents()
        NotificationCenter.default.removeObserver(self, name: NSWindow.didEnterFullScreenNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSWindow.willExitFullScreenNotification, object: nil)
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        mediaWindowController?.goBack = { [weak self] in
            self?.goBack()
        }
        mediaWindowController?.delete = { [weak self] in
            self?.delete()
        }
        mediaWindowController?.toggleFavorite = { [weak self] in
            self?.toggleFavorite()
        }
        mediaWindowController?.zoomIn = { [weak self] in
            self?.zoomIn()
        }
        mediaWindowController?.zoomOut = { [weak self] in
            self?.zoomOut()
        }
    }

    func setupImageViewer() {
        imageViewerViewController = ImageViewerViewController(nibName: "ImageViewerViewController", bundle: Bundle.main)
        addChild(imageViewerViewController!)
        containerView.addSubview(imageViewerViewController!.view)

        imageViewerViewController!.image = mediaStore.selectedMedia as? Image
        imageViewerViewController!.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageViewerViewController!.view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            imageViewerViewController!.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            imageViewerViewController!.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            imageViewerViewController!.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0)
        ])
    }

    func setupVideoViewer() {
        videoViewerViewController = VideoViewerViewController(nibName: "VideoViewerViewController", bundle: Bundle.main)
        addChild(videoViewerViewController!)
        containerView.addSubview(videoViewerViewController!.view)

        videoViewerViewController!.video = mediaStore.selectedMedia as? Video
        videoViewerViewController!.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            videoViewerViewController!.view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            videoViewerViewController!.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            videoViewerViewController!.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            videoViewerViewController!.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0)
        ])
    }

    func setupFullscreenImageViewer() {
        guard let image = mediaStore.selectedMedia as? Image else {
            return
        }

        let fullscreenImageViewerViewController = FullscreenImageViewerViewController(nibName: "FullscreenImageViewerViewController", bundle: Bundle.main)
        fullscreenImageViewerViewController.setup(with: image)

        navigationController?.pushViewController(fullscreenImageViewerViewController, animated: false)
    }

    func goBack() {
        navigationController?.popViewController(animated: false)
    }

    func delete() {
        guard let media = mediaStore.selectedMedia else {
            return
        }

        let mediaDestructor = MediaDestructor(mediaItems: [media])
        mediaDestructor.delete()

        navigationController?.popViewController(animated: false)
    }

    func toggleFavorite() {
        guard var media = mediaStore.selectedMedia else {
            return
        }

        media.isFavorite.toggle()

        if let mediaToolbar = mediaToolbar {
            let configuration = MediaDetailToolbarConfiguration(toolbar: mediaToolbar, isFavorite: media.isFavorite, isImage: media is Image)
            mediaToolbar.replaceItems(for: configuration)
        }

        let mediaCoreDataService = MediaCoreDataService()
        media = mediaCoreDataService.update(media: media)
        mediaStore.update(media: media)
    }

    func zoomIn() {
        imageViewerViewController?.zoomIn()
    }

    func zoomOut() {
        imageViewerViewController?.zoomOut()
    }

    @objc func handleEnterFullScreen(_ notification: NSNotification) {
        setupFullscreenImageViewer()
    }

    @objc func handleExitFullScreen(_ notification: NSNotification) {
        navigationController?.popViewController(animated: false)
    }
}

extension MediaDetailViewController: KeyboardMonitoring {

    func handleKeyDown(with event: NSEvent) -> Bool {
        guard !(view.window?.firstResponder is NSTextView) else {
            return false
        }

        // handle keyDown only if current window has focus, i.e. is keyWindow
        guard let locWindow = self.view.window,
            NSApplication.shared.keyWindow === locWindow else { return false }
        switch event.keyCode {
        case deleteKey:
            navigationController?.popViewController(animated: false)
            return true
        case leftArrowKey:
            mediaStore.selectPrevious()
            return true
        case rightArrowKey:
            mediaStore.selectNext()
            return true
        default:
            return false
        }
    }
}


extension NSRect {
    func centerAndAdjustPercentage(percentage p: CGFloat) -> NSRect {
        let w = self.width
        let h = self.height

        let newW = w * p
        let newH = h * p
        let newX = (w - newW) / 2
        let newY = (h - newH) / 2

        return NSRect(x: newX, y: newY, width: newW, height: newH)
    }
}
