//
//  MediaSidebarViewController.swift
//  imageorg
//
//  Created by Finn Schlenk on 21.10.18.
//  Copyright © 2018 Finn Schlenk. All rights reserved.
//

import Cocoa

class MediaSidebarViewController: MediaViewController {

    @IBOutlet weak var metaInfoStackView: NSStackView!
    @IBOutlet weak var fileNameTextField: NSTextField!
    @IBOutlet weak var fileSizeTextField: NSTextField!
    @IBOutlet weak var fileTypeTextField: NSTextField!
    @IBOutlet weak var filePathTextField: ClickableTextField!
    @IBOutlet weak var whereFromStackView: NSStackView!
    @IBOutlet weak var whereFromUrlTextField: ClickableTextField!
    @IBOutlet weak var creationDateTextField: NSTextField!
    @IBOutlet weak var modificationDateTextField: NSTextField!

    var mediaStore = MediaStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        let doubleClickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
        doubleClickGesture.numberOfClicksRequired = 2

        filePathTextField.addGestureRecognizer(doubleClickGesture)

        setupView()
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        mediaStore.add(delegate: self)
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        mediaStore.remove(delegate: self)
    }

    func setupView() {
        guard let media = mediaStore.selectedMedia else {
            return
        }

        // bytes to kilobytes
        let fileSize = Int(media.fileSize / 1000)
        let filePath = media.originalFilePath

        fileNameTextField.toolTip = media.name
        fileNameTextField.stringValue = media.name
        fileSizeTextField.stringValue = "\(fileSize) KB"
        fileTypeTextField.stringValue = media.mimeType

        let filePathParagraphStyle = NSMutableParagraphStyle()
        filePathParagraphStyle.alignment = .right
        filePathParagraphStyle.lineBreakMode = .byTruncatingHead
        let filePathAttributedString = NSMutableAttributedString(string: filePath, attributes: [NSAttributedString.Key.paragraphStyle: filePathParagraphStyle])
        filePathAttributedString.setAsLink(textToFind: filePath, link: filePath)
        filePathTextField.toolTip = filePath
        filePathTextField.attributedStringValue = filePathAttributedString
        filePathTextField.link = filePath

        if let whereFrom = media.whereFrom, whereFrom.isValidURL {
            let whereFromParagraphStyle = NSMutableParagraphStyle()
            whereFromParagraphStyle.alignment = .right
            whereFromParagraphStyle.lineBreakMode = .byTruncatingHead
            let whereFromAttributedString = NSMutableAttributedString(string: whereFrom, attributes: [NSAttributedString.Key.paragraphStyle: filePathParagraphStyle])
            whereFromAttributedString.setAsLink(textToFind: whereFrom, link: whereFrom)
            whereFromUrlTextField.attributedStringValue = whereFromAttributedString
            whereFromStackView.isHidden = false
        } else {
            whereFromStackView.isHidden = true
        }

        creationDateTextField.stringValue = Date(date: media.creationDate).toString()

        if let modificationDate = media.modificationDate {
            modificationDateTextField.stringValue = Date(date: modificationDate).toString()
        }
    }

    @objc func handleClick() {
        guard let media = mediaStore.selectedMedia else {
            return
        }

        NSWorkspace.shared.openFile(media.originalFilePath)
    }
}

extension MediaSidebarViewController: MediaStoreDelegate {

    func didSelect(media: Media) {
        setupView()
    }
}
