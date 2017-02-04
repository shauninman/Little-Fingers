//
//  TapController.m
//  Little Fingers
//
//  Created by Shaun Inman on 2/3/17.
//  Copyright © 2017 Shaun Inman. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "TapController.h"

// TODO: rewrite to only listen to keydown flagchanged when unlocked

BOOL isShiftDown = NO;
BOOL isControlDown = NO;
BOOL isOptionDown = NO;
BOOL isCommandDown = NO;
BOOL isLDown = NO;

BOOL isLocked = NO;
BOOL wasLocked = NO;

void lockChanged() {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SINotificationLockChanged" object:nil]];
}

CGEventRef myCGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
	CGKeyCode keycode = (CGKeyCode)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
	
	if (type == kCGEventFlagsChanged) {
		// NSLog(@"flag changed:%u",keycode);
		if (keycode == (CGKeyCode)56) isShiftDown = !isShiftDown;
		if (keycode == (CGKeyCode)59) isControlDown = !isControlDown;
		if (keycode == (CGKeyCode)58) isOptionDown = !isOptionDown;
		if (keycode == (CGKeyCode)55) isCommandDown = !isCommandDown;
	}
	
	if (type == kCGEventKeyDown) {
		// NSLog(@"keycode (down):%u",keycode);
		if (keycode == (CGKeyCode)37) isLDown = YES;
	}
	else if (type == kCGEventKeyUp) {
		// NSLog(@"keycode (up):%u",keycode);
		if (keycode == (CGKeyCode)37) isLDown = NO;
	}
	
	if (isShiftDown && isControlDown && isOptionDown && isCommandDown && isLDown) {
		isLocked = !isLocked;
		
		lockChanged();
		
		// isShiftDown = NO;
		// isControlDown = NO;
		// isOptionDown = NO;
		// isCommandDown = NO;
		
		isLDown = NO;
		
		// NSLog(@"isLocked:%i", isLocked);
		return NULL;
	}
	
	if (isLocked) {
		// NSLog(@"ignore input");
		return NULL;
	}
	else {
		return event;
	}
}

@implementation TapController

-(id)init {
	self = [super init];
	if (self) {
		CFMachPortRef      eventTap;
		CGEventMask        eventMask;
		CFRunLoopSourceRef runLoopSource;
		
		// Create an event tap. We want to capture everything.
		eventMask = kCGEventMaskForAllEvents;
		eventTap = CGEventTapCreate(kCGSessionEventTap,
									kCGHeadInsertEventTap,
									kCGEventTapOptionDefault,
									eventMask,
									myCGEventCallback, NULL);
		if (!eventTap) {
			NSLog(@"failed to create event tap");
			exit(1);
		}
		
		// Create a run loop source.
		runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
		
		// Add to the current run loop.
		CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
		
		// enable the event tap.
		CGEventTapEnable(eventTap, true);
		
		// disable lock during screensavers/sleep
		NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
		
		[dnc addObserver:self selector:@selector(pauseLock) name:@"com.apple.shutdownInitiated" object:nil];
		[dnc addObserver:self selector:@selector(pauseLock) name:@"com.apple.shieldWindowRaised" object:nil];
		[dnc addObserver:self selector:@selector(resumeLock) name:@"com.apple.shieldWindowLowered" object:nil];
		[dnc addObserver:self selector:@selector(resumeLock) name:@"com.apple.logoutCancelled" object:nil];
	}
	return self;
}

+(BOOL)isAccessibilityEnabled {
	// http://stackoverflow.com/questions/17693408/enable-access-for-assistive-devices-programmatically-on-10-9
	NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @NO};
	return AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
}

+(BOOL)isLocked {
	return isLocked;
}

-(void)pauseLock {
	if (isLocked) {
		isLocked = NO;
		wasLocked = YES;
		lockChanged();
	}
}
-(void)resumeLock {
	if (wasLocked) {
		isLocked = YES;
		wasLocked = NO;
		lockChanged();
	}
}

@end
