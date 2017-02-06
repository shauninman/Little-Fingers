//
//  AboutWindowController.swift
//  Little Fingers
//
//  Created by Shaun Inman on 2/5/17.
//  Copyright © 2017 Shaun Inman. All rights reserved.
//

import Cocoa

// TODO: hookup launch at login

// TODO: launch at login checkbox is unresponsive at launch...
// TODO: credits text view doesn't scroll at launch either
// TODO: window controls don't work either? wth
// TODO: kinda fixed by delaying opening by a fraction of a second

class AboutWindowController: NSWindowController {

	@IBOutlet weak var nameLabel:NSTextField?
	@IBOutlet weak var versionLabel:NSTextField?
	@IBOutlet weak var iconImageView:NSImageView?
	@IBOutlet weak var creditsScrollView: NSScrollView?
	
    override func windowDidLoad() {
        super.windowDidLoad()
		
		iconImageView?.image = NSApp.applicationIconImage
		
		let bundle = Bundle.main
		let name = bundle.infoDictionary!["CFBundleName"] as! String
		let versionInternal = bundle.infoDictionary!["CFBundleVersion"] as! String
		let versionExternal = bundle.infoDictionary!["CFBundleShortVersionString"] as! String
		let credits = bundle.path(forResource: "Credits", ofType: "rtf")
		
		nameLabel?.stringValue = name
		versionLabel?.stringValue = "\(versionExternal) (\(versionInternal))"
		
		let creditsTextView = creditsScrollView?.contentView.documentView as! NSTextView
		creditsTextView.textContainerInset = NSSize(width: 14, height: 14)
		creditsTextView.readRTFD(fromFile: credits!)
    }
	
	override func showWindow(_ sender: Any?) {
		super.showWindow(sender)
	}
}
