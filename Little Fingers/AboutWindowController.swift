//
//  AboutWindowController.swift
//  Little Fingers
//
//  Created by Shaun Inman on 2/5/17.
//  Copyright © 2017 Shaun Inman. All rights reserved.
//

import Cocoa

// TODO: launch at login checkbox is unresponsive at launch...
// TODO: credits text view doesn't scroll at launch either
// TODO: window controls don't work either? wth
// TODO: kinda fixed by delaying opening by a fraction of a second

class AboutWindowController: NSWindowController {

	@IBOutlet weak var nameLabel:NSTextField!
	@IBOutlet weak var versionLabel:NSTextField!
	@IBOutlet weak var iconImageView:NSImageView!
	@IBOutlet weak var creditsScrollView: NSScrollView!
	@IBOutlet weak var autoLaunch:NSButton!
	
    override func windowDidLoad() {
        super.windowDidLoad()
		
		iconImageView.image = NSApp.applicationIconImage
		
		let bundle = Bundle.main
		let plist = bundle.infoDictionary!
		let name = plist["CFBundleName"] as! String
		let versionInternal = plist["CFBundleVersion"] as! String
		let versionExternal = plist["CFBundleShortVersionString"] as! String
		let credits = bundle.path(forResource: "Credits", ofType: "rtf")
		
		nameLabel.stringValue = name
		versionLabel.stringValue = "\(versionExternal) (\(versionInternal))"
		
		let creditsTextView = creditsScrollView.contentView.documentView as! NSTextView
		creditsTextView.textContainerInset = NSSize(width: 14, height: 14)
		creditsTextView.readRTFD(fromFile: credits!)
		
		let defaults = UserDefaults.standard
		autoLaunch.state = defaults.object(forKey: "autoLaunch") as! Int
    }
	
	override func showWindow(_ sender: Any?) {
		super.showWindow(sender)
		
		let defaults = UserDefaults.standard
		let stillAutoLaunch = LoginItems.appAlreadyExists()
		let didAutoLaunch = defaults.object(forKey: "autoLaunch") as! Bool
		
		if stillAutoLaunch != didAutoLaunch {
			let autoLaunchInt = stillAutoLaunch ? 1 : 0
			defaults.set(autoLaunchInt, forKey: "autoLaunch")
			if autoLaunch != nil {
				autoLaunch.state = autoLaunchInt
			}
		}
	}
	
	@IBAction func changeAutoLaunch(_ sender: NSButton) {
		UserDefaults.standard.set(autoLaunch.state, forKey: "autoLaunch")
		
		if autoLaunch.state == 1 {
			LoginItems.addApp()
		}
		else {
			LoginItems.removeApp()
		}
	}
}
