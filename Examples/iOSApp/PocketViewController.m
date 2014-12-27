//
//  PocketViewController.m
//  PocketSDK
//
//  Created by Steve Streza on 5/29/12.
//  Copyright (c) 2012 Read It Later, Inc.
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this
//  software and associated documentation files (the "Software"), to deal in the Software
//  without restriction, including without limitation the rights to use, copy, modify, 
//  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all copies or
//  substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
//  BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "PocketViewController.h"
#import "PocketAPI.h"
#import "PocketRSSParser.h"

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC, add -fobjc-arc to its compiler flags in the Compile Sources build phase.
#endif

@interface PocketViewController () <PocketAPIDelegate>

@end

@implementation PocketViewController


#pragma mark - UIViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[[PocketAPI sharedAPI] addObserver:self forKeyPath:@"username" options:0 context:@"PocketAPIUsername"];
	
	[self updateNavigationBarTitle];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter addObserver:self selector:@selector(showLoginCoverView) name:(NSString *)PocketAPILoginStartedNotification  object:nil];
	[defaultCenter addObserver:self selector:@selector(hideLoginCoverView) name:(NSString *)PocketAPILoginFinishedNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter removeObserver:self name:(NSString *)PocketAPILoginStartedNotification object:nil];
	[defaultCenter removeObserver:self name:(NSString *)PocketAPILoginFinishedNotification object:nil];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == @"PocketAPIUsername") {
		[self updateNavigationBarTitle];
        return;
	}
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


#pragma mark - Actions

- (void)showLoginCoverView
{
    self.coverView.hidden = NO;
}

- (void)hideLoginCoverView
{
    self.coverView.hidden = YES;
}


#pragma mark - Pocket APIs

- (IBAction)login:(id)sender
{
	[[PocketAPI sharedAPI] loginWithHandler:^(PocketAPI *api, NSError *error) {
		if (error) {
			[self loginFailed:error];
            return;
		}
        
        [self loggedInSuccessfully];
	}];
}

- (IBAction)logout:(id)sender
{
	[[PocketAPI sharedAPI] logout];
}

- (void)loggedInSuccessfully
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Logged in"
											   message:[NSString stringWithFormat:@"You are logged in for the Pocket user %@.", [PocketAPI sharedAPI].username]
											  delegate:nil
									 cancelButtonTitle:nil
									 otherButtonTitles:@"Woo hoo!", nil];

	[alertView show];
}

- (void)loginFailed:(NSError *)error
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error logging in"
														message:[NSString stringWithFormat:@"There was an error logging in: %@", [error localizedDescription]]
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"Awww", nil];
	
	[alertView show];
}

- (void)updateNavigationBarTitle
{
	NSString *title = [PocketAPI sharedAPI].username;
	if (!title || !title.length) {
		title = @"Not Logged In";
	}
	
	self.navigationBar.topItem.title = title;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PocketRSSItem *feedItem = [self feedItemAtIndexPath:indexPath];
    NSURL *url = feedItem.url;
	if (url == nil) return;
	
    NSString *title = feedItem.title;
	NSLog(@"Saving URL: %@", url);
	[[PocketAPI sharedAPI] saveURL:url withTitle:title handler:^(PocketAPI *api, NSURL *url, NSError *error) {
		if (error != nil) {
			NSLog(@"URL %@ could not be saved to %@'s Pocket account. Reason: %@", url, api.username, error.localizedDescription);
		}
        else {
            NSLog(@"URL %@ was saved to %@'s Pocket account", url, api.username);
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
	}];
}


#pragma mark - Pocket API callbacks

- (void)pocketAPILoggedIn:(PocketAPI *)api
{
	NSLog(@"Pocket API logged in for user %@", [api username]);
}

- (void)pocketAPI:(PocketAPI *)api hadLoginError:(NSError *)error
{
	NSLog(@"Pocket API could not log in: %@", [error localizedDescription]);
}

- (void)pocketAPI:(PocketAPI *)api savedURL:(NSURL *)url
{
	NSLog(@"Pocket API saved URL %@ for user %@", url, [api username]);
}

- (void)pocketAPI:(PocketAPI *)api failedToSaveURL:(NSURL *)url error:(NSError *)error
{
	NSLog(@"Pocket API could not save URL %@ for user %@: %@.", url, [api username], [error localizedDescription]);
}

@end
