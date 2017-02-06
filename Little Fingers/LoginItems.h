//
//  LoginItems.h
//  Day-O
//
//  Created by Shaun Inman on 10/20/11.
//  Copyright (c) 2011 Shaun Inman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginItems : NSObject
+(BOOL)appAlreadyExists;
+(void)addApp;
+(void)removeApp;
@end
