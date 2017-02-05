//
//  StatusItemController.swift
//  Little Fingers
//
//  Created by Shaun Inman on 2/3/17.
//  Copyright © 2017 Shaun Inman. All rights reserved.
//

import Cocoa

class StatusItemController: NSObject {
	let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
	var isAccessibilityEnabled = false
	var accessibilityTimer:Timer?
	
	let aboutWindowController = AboutWindowController(windowNibName: "AboutWindow")
	
	override init() {
		super.init()
		
		checkAccessibility()
		
		buildMenu()
		
		if let button = statusItem.button {
			if let image = NSImage(named: "off") {
				image.isTemplate = true
				button.image = image
			}
		}
		
		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(updateIcon),
		                                       name: NSNotification.Name(rawValue: SINotificationLockChanged),
		                                       object: nil)
	}
	
	func checkAccessibility() {
		isAccessibilityEnabled = TapController.isAccessibilityEnabled()
		if !isAccessibilityEnabled {
			showSecurityPrivacy()
		}
		accessibilityTimer = Timer.scheduledTimer(timeInterval: 0.5,
		                                          target: self,
		                                          selector: #selector(updateAccessibility),
		                                          userInfo: nil,
		                                          repeats: true)
	}
	
	func updateAccessibility() {
		let wasAccessibilityEnabled = isAccessibilityEnabled
		isAccessibilityEnabled = TapController.isAccessibilityEnabled()
		if isAccessibilityEnabled {
			accessibilityTimer?.invalidate()
			if !wasAccessibilityEnabled {
				restartApp()
			}
		}
	}
	
	func restartApp() {
		// TODO: also quit System Preferences since they lose focus on restart?
		let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
		let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
		let task = Process()
		task.launchPath = "/usr/bin/open"
		task.arguments = [path]
		task.launch()
		NSApp.terminate(self)
	}
	
	func buildMenu() {
		let menu = NSMenu()
		menu.delegate = self
		
		let item = NSMenuItem()
		item.title = "About Little Fingers"
		item.action = #selector(showAbout)
		item.target = self
		menu.addItem(item)
		
		menu.addItem(NSMenuItem.separator())
		
		menu.addItem(NSMenuItem(title: "Quit Little Fingers", action: #selector(NSApp.terminate), keyEquivalent: ""))
		
		statusItem.menu = menu
	}
	
	func showSecurityPrivacy() {
		// print("show Date & Time")
		let path = Bundle.main.path(forResource: "privacy", ofType: "scpt")
		let url = URL.init(fileURLWithPath: path!)
		let appleScript = NSAppleScript.init(contentsOf: url, error: nil)
		appleScript?.executeAndReturnError(nil)
	}
	
	func showAbout() {
		// print("show About")
		NSApp.activate(ignoringOtherApps: true)
		aboutWindowController.showWindow(NSApp.delegate)
		
//		NSApp.activate(ignoringOtherApps: true)
//		NSApp.orderFrontStandardAboutPanel()
	}
	
	func updateIcon() {
		if let button = statusItem.button {
			if TapController.isLocked() {
				if let image = NSImage(named: "on") {
					image.isTemplate = true
					button.image = image
				}
			}
			else {
				if let image = NSImage(named: "off") {
					image.isTemplate = true
					button.image = image
				}
			}
		}
	}
}

extension StatusItemController : NSMenuDelegate {
	func menuWillOpen(_ menu: NSMenu) {
		(NSApp.delegate as! AppDelegate).hideWindows()
	}
	
	func menuDidClose(_ menu: NSMenu) {
		// print("close menu")
		
		Timer.scheduledTimer(timeInterval: 0,
		                     target: NSApp.delegate as! AppDelegate,
		                     selector: #selector(AppDelegate.hideApp),
		                     userInfo: nil,
		                     repeats: false)
	}
}
