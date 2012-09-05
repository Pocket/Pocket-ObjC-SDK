//
//  PocketTestResult.h
//  Mac Test App
//
//  Created by James Yopp on 9/4/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PocketTestStatus : NSObject

@property (readonly, retain) NSString* name;
@property (readonly, retain) NSError* error;
@property (readonly) BOOL timedOut;

- (id) initWithName:(NSString*)name;
- (void) waitUpTo:(NSTimeInterval)timeout;
- (void) failedWithError:(NSError*)error;
- (void) succeeded;

@end
