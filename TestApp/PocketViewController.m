//
//  PocketViewController.m
//  PocketSDK
//
//  Created by Steve Streza on 5/29/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import "PocketViewController.h"
#import "PocketAPI.h"

@interface PocketViewController ()

@end

@implementation PocketViewController

@synthesize usernameField, passwordField, URLField;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	usernameField.text = [[PocketAPI sharedAPI] username];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark Pocket APIs

-(IBAction)login:(id)sender{
	[[PocketAPI sharedAPI] loginWithUsername:usernameField.text password:passwordField.text delegate:self];
}

-(IBAction)saveURL:(id)sender{
	[[PocketAPI sharedAPI] saveURL:[NSURL URLWithString:URLField.text] delegate:self];
}

#pragma mark Pocket API callbacks

-(void)pocketAPILoggedIn:(PocketAPI *)api{
	NSLog(@"Pocket API logged in for user %@", [api username]);
}

-(void)pocketAPI:(PocketAPI *)api hadLoginError:(NSError *)error{
	NSLog(@"Pocket API could not log in: %@", error);
}

-(void)pocketAPI:(PocketAPI *)api savedURL:(NSURL *)url{
	NSLog(@"Pocket API saved URL %@ for user %@", url, [api username]);
}

-(void)pocketAPI:(PocketAPI *)api failedToSaveURL:(NSURL *)url error:(NSError *)error{
	NSLog(@"Pocket API could not save URL %@ for user %@: %@", url, [api username], error);
}

@end
