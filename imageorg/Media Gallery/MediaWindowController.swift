//
//  MediaWindowController.swift
//  imageorg
//
//  Created by Finn Schlenk on 22.10.18.
//  Copyright © 2018 Finn Schlenk. All rights reserved.
//

import Cocoa

class MediaWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        guard let mediaSplitViewController = storyboard?.instantiateController(withIdentifier: "MediaSplitViewController") as? MediaSplitViewController else {
            return
        }

        let navigationController = NSNavigationController(rootViewController: mediaSplitViewController)
        window?.contentViewController = navigationController
    }

    @IBAction func handleToolbarItemAction(_ sender: NSToolbarItem) {
        if let navigationController = contentViewController as? NSNavigationController,
            let mediaSplitViewController = navigationController.topViewController as? MediaSplitViewController {
            mediaSplitViewController.toggleSidebar(self)
        }
    }
}
