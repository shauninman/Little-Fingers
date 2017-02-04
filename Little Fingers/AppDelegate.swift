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

	let tapController = TapController()
	let statusItemController = StatusItemController()

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		NSApplication.shared().setActivationPolicy(.accessory)
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

