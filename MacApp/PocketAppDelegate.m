//
//  PocketAppDelegate.m
//  PocketSDK
//
//  Created by Steve Streza on 5/30/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import "PocketAppDelegate.h"

#import "PocketAPI.h"

@implementation PocketAppDelegate

@synthesize window = _window;

@synthesize usernameField, passwordField, URLField;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[[PocketAPI sharedAPI] setAPIKey:@"Put Your API Key Here"];
}

-(IBAction)login:(id)sender{
	// get these from your login UI
	NSString *username = usernameField.stringValue; 
	NSString *password = passwordField.stringValue;
	
	// login
	[[PocketAPI sharedAPI] loginWithUsername:username password:password handler:^(PocketAPI *api, NSError *error){
		if(error){
			// login failed, show an error to the user
			NSLog(@"Could not log in to Pocket: %@", error);
		}else{
			// login successful, update your UI here
			NSLog(@"Login succeeded for %@", username);
		}
	}];
}

-(IBAction)save:(id)sender{
	// get this from your application
	NSURL *url = [NSURL URLWithString:URLField.stringValue];
	
	// perform the save
	[[PocketAPI sharedAPI] saveURL:url handler:^(PocketAPI *api, NSURL *url, NSError *error, BOOL needsToRelogin){
		if(error){
			if(needsToRelogin){
				// the user's login information changed elsewhere, prompt them to login here
				NSLog(@"User needs to login again. %@", error);
			}else{
				// a server issue happened, inform the user their URL will not be saved
				NSLog(@"Could not save the item to Pocket: %@", error);
			}
		}else{
			// URL saved successfully, update your UI here
			NSLog(@"Saved URL %@", url);
		}
	}];
}

@end
