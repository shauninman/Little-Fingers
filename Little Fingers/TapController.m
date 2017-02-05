//
//  TapController.m
//  Little Fingers
//
//  Created by Shaun Inman on 2/3/17.
//  Copyright © 2017 Shaun Inman. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "TapController.h"

@interface TapController () {
	
}
+(void)listen;
+(void)ignore;
@end

CGKeyCode kSIKeyCodeL = (CGKeyCode)37;

BOOL isCommandDown = NO;
BOOL isOptionDown = NO;
BOOL isControlDown = NO;
BOOL isShiftDown = NO;
BOOL isLDown = NO;

BOOL isLocked = NO;
BOOL wasLocked = NO;

void lockChanged() {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SINotificationLockChanged" object:nil]];
}

CGEventRef tapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
	if (type == kCGEventFlagsChanged) {
		NSEventModifierFlags flags = [[NSEvent eventWithCGEvent:event] modifierFlags];
		
		isCommandDown = (flags & NSCommandKeyMask) == NSCommandKeyMask;
		isOptionDown = (flags & NSAlternateKeyMask) == NSAlternateKeyMask;
		isControlDown = (flags & NSControlKeyMask) == NSControlKeyMask;
		isShiftDown = (flags & NSShiftKeyMask) == NSShiftKeyMask;
	}
	
	CGKeyCode keycode = (CGKeyCode)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
	if (type == kCGEventKeyDown) {
		if (keycode == kSIKeyCodeL) isLDown = YES;
	}
	else if (type == kCGEventKeyUp) {
		if (keycode == kSIKeyCodeL) isLDown = NO;
	}
	
	if (isShiftDown && isControlDown && isOptionDown && isCommandDown && isLDown) {
		isLDown = NO;

		isLocked = !isLocked;
		lockChanged();
		
		// TODO: hide/show mouse?
		if (isLocked) {
			[TapController ignore];
		}
		else {
			[TapController listen];
		}
		
		return NULL;
	}
	
	if (isLocked) {
		return NULL;
	}
	else {
		return event;
	}
}

BOOL isTapEnabled = NO;
CFMachPortRef listenEventTap;
CFMachPortRef ignoreEventTap;
CFRunLoopSourceRef	listenRunLoopSource;
CFRunLoopSourceRef	ignoreRunLoopSource;

@implementation TapController

-(id)init {
	self = [super init];
	if (self) {
		CGEventMask	listenEventMask	= CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventKeyUp) | CGEventMaskBit(kCGEventFlagsChanged);
		CGEventMask	ignoreEventMask	= kCGEventMaskForAllEvents;
		
		listenEventTap = CGEventTapCreate(kCGSessionEventTap,
										  kCGHeadInsertEventTap,
										  kCGEventTapOptionDefault,
										  listenEventMask,
										  tapCallback, NULL);
		ignoreEventTap = CGEventTapCreate(kCGSessionEventTap,
										  kCGHeadInsertEventTap,
										  kCGEventTapOptionDefault,
										  ignoreEventMask,
										  tapCallback, NULL);
		
		if (!listenEventTap || !ignoreEventTap) {
			NSLog(@"failed to create event taps");
			exit(1);
		}
		
		listenRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, listenEventTap, 0);
		ignoreRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, ignoreEventTap, 0);
		
		[TapController listen];
		isTapEnabled = YES;
		
		// disable lock during screensavers/sleep
		NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
		
		[dnc addObserver:self selector:@selector(pauseLock) name:@"com.apple.shutdownInitiated" object:nil];
		[dnc addObserver:self selector:@selector(pauseLock) name:@"com.apple.shieldWindowRaised" object:nil];
		[dnc addObserver:self selector:@selector(resumeLock) name:@"com.apple.shieldWindowLowered" object:nil];
		[dnc addObserver:self selector:@selector(resumeLock) name:@"com.apple.logoutCancelled" object:nil];
	}
	return self;
}

+(void)listen {
	if (isTapEnabled) {
		CFRunLoopRemoveSource(CFRunLoopGetCurrent(), ignoreRunLoopSource, kCFRunLoopCommonModes);
		CGEventTapEnable(ignoreEventTap, false);
	}
	
	CFRunLoopAddSource(CFRunLoopGetCurrent(), listenRunLoopSource, kCFRunLoopCommonModes);
	CGEventTapEnable(listenEventTap, true);
}

+(void)ignore {
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), listenRunLoopSource, kCFRunLoopCommonModes);
	CGEventTapEnable(listenEventTap, false);
	
	CFRunLoopAddSource(CFRunLoopGetCurrent(), ignoreRunLoopSource, kCFRunLoopCommonModes);
	CGEventTapEnable(ignoreEventTap, true);
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
