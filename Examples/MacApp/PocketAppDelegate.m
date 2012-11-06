//
//  PocketAppDelegate.m
//  PocketSDK
//
//  Created by Steve Streza on 5/30/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import "PocketAppDelegate.h"

#import "PocketAPI.h"

#import "PocketCredentials.h"

@implementation PocketAppDelegate

@synthesize window = _window;

@synthesize loggedInField, URLField;

- (void)dealloc
{
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[[PocketAPI sharedAPI] setConsumerKey:CONSUMER_KEY];
	[self updateLoggedInField];
}

-(void)updateLoggedInField{
	if([[PocketAPI sharedAPI] isLoggedIn]){
		self.loggedInField.stringValue = [NSString stringWithFormat:@"Logged in as %@", [PocketAPI sharedAPI].username];
	}else{
		self.loggedInField.stringValue = @"Not logged in";
	}
}

-(IBAction)login:(id)sender{
	[[PocketAPI sharedAPI] loginWithHandler:^(PocketAPI *api, NSError *error) {
		NSLog(@"API logged in with error %@: %@", error, api.username);
		[self updateLoggedInField];
	}];
}

-(IBAction)save:(id)sender{
	// get this from your application
	NSURL *url = [NSURL URLWithString:URLField.stringValue];
	
	// perform the save
	[[PocketAPI sharedAPI] saveURL:url handler:^(PocketAPI *api, NSURL *url, NSError *error){
		if(error){
			// a server issue happened or the user has rejected authorization, inform the user their URL will not be saved
			NSLog(@"Could not save the item to Pocket: %@", error);
		}else{
			// URL saved successfully, update your UI here
			NSLog(@"Saved URL %@", url);
		}
	}];
}

@end
