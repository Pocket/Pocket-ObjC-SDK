//
//  PocketAppDelegate.h
//  PocketSDK
//
//  Created by Steve Streza on 5/30/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PocketAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSTextField *loggedInField;
@property (assign) IBOutlet NSTextField *URLField;

-(IBAction)login:(id)sender;
-(IBAction)save:(id)sender;

@end
