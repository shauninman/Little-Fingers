//
//  AppDelegate.swift
//  Little Fingers
//
//  Created by Shaun Inman on 2/3/17.
//  Copyright © 2017 Shaun Inman. All rights reserved.
//

import Cocoa

let SINotificationLockChanged = "SINotificationLockChanged"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	var tapController:TapController!
	var statusItemController:StatusItemController!

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		NSApplication.shared().setActivationPolicy(.accessory)
		
		let defaults = UserDefaults.standard
		defaults.register(defaults: ["autoLaunch": true,
		                             "firstRun": true])
		
		if defaults.object(forKey: "firstRun") as! Bool {
			defaults.set(false, forKey: "firstRun")
			LoginItems.addApp()
		}
		
		tapController = TapController()
		statusItemController = StatusItemController()
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		
	}

	func applicationWillResignActive(_ notification: Notification) {
		hideWindows()
	}
	
	func windowWillClose() {
		NSApp.hide(nil)
	}
	
	func hideWindows() {
		for window in NSApp.windows {
			if window.isKind(of: NSPanel.self) && window.isVisible {
				window.orderOut(nil)
			}
		}
	}
	
	func hideApp() {
		var visibleWindows:Int = 0
		for window in NSApp.windows {
			if window.isKind(of: NSPanel.self) && window.isVisible {
				visibleWindows += 1
			}
		}
		if visibleWindows == 0 {
			NSApp.hide(nil)
		}
	}
}

