//
//  LoginItems.m
//  Day-O
//
//  Created by Shaun Inman on 10/20/11.
//  Copyright (c) 2011 Shaun Inman. All rights reserved.
//

#import "LoginItems.h"

// TODO: this code is deprecated, consider using SMLoginItemSetEnabled
// http://martiancraft.com/blog/2015/01/login-items/
// https://github.com/kgn/LaunchAtLoginHelper
// https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLoginItems.html#//apple_ref/doc/uid/10000172i-SW5-SW1

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

@implementation LoginItems
+(BOOL)appAlreadyExists
{
	BOOL found = NO;  
	UInt32 seedValue;
	CFURLRef thePath = NULL;
	CFErrorRef *outError= NULL;
	
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
	LSSharedFileListRef theLoginItemsRefs = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	
	// We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
	// and pop it in an array so we can iterate through it to find our item.
	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
	for (id item in (__bridge NSArray *)loginItemsArray) {
		LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
//		LSSharedFileListItemCopyResolvedURL(<#LSSharedFileListItemRef inItem#>, <#LSSharedFileListResolutionFlags inFlags#>, <#CFErrorRef *outError#>)
//		LSSharedFileListItemResolve(<#LSSharedFileListItemRef inItem#>, <#LSSharedFileListResolutionFlags inFlags#>, <#CFURLRef *outURL#>, <#FSRef *outRef#>)
		thePath = LSSharedFileListItemCopyResolvedURL(itemRef, 0, outError);
		if (outError == noErr) {
			if ([[(__bridge NSURL *)thePath path] hasPrefix:appPath]) {
				found = YES;
				break;
			}
            // Docs for LSSharedFileListItemResolve say we're responsible
            // for releasing the CFURLRef that is returned
            if (thePath != NULL) CFRelease(thePath);
		}
	}
	if (loginItemsArray != NULL) CFRelease(loginItemsArray);
	
	return found;
}
+(void)addApp
{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
	LSSharedFileListRef theLoginItemsRefs = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

	// We call LSSharedFileListInsertItemURL to insert the item at the bottom of Login Items list.
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
	LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(theLoginItemsRefs, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);		
	if (item)
		CFRelease(item);
}

+(void)removeApp
{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
	LSSharedFileListRef theLoginItemsRefs = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

	UInt32 seedValue;
	CFURLRef thePath = NULL;
	CFErrorRef *outError= NULL;
	// We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
	// and pop it in an array so we can iterate through it to find our item.
	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
	for (id item in (__bridge NSArray *)loginItemsArray) {		
		LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
		thePath = LSSharedFileListItemCopyResolvedURL(itemRef, 0, outError);
		if (outError == noErr) {
			if ([[(__bridge NSURL *)thePath path] hasPrefix:appPath]) {
				LSSharedFileListItemRemove(theLoginItemsRefs, itemRef); // Deleting the item
			}
			// Docs for LSSharedFileListItemResolve say we're responsible
			// for releasing the CFURLRef that is returned
			if (thePath != NULL) CFRelease(thePath);
		}		
	}
	if (loginItemsArray != NULL) CFRelease(loginItemsArray);
}
@end

#pragma GCC diagnostic pop
