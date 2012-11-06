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

@implementation PocketViewController

@synthesize coverView;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[[PocketAPI sharedAPI] addObserver:self forKeyPath:@"username" options:0 context:@"PocketAPIUsername"];
	
	[self updateNavigationBarTitle];
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginCoverView) name:(NSString *)PocketAPILoginStartedNotification  object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideLoginCoverView) name:(NSString *)PocketAPILoginFinishedNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:(NSString *)PocketAPILoginStartedNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:(NSString *)PocketAPILoginFinishedNotification object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == @"PocketAPIUsername") {
		[self updateNavigationBarTitle];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

-(void)showLoginCoverView{
	[self.coverView setHidden:NO];
}

-(void)hideLoginCoverView{
	[self.coverView setHidden:YES];
}

#pragma mark Pocket APIs

-(IBAction)login:(id)sender{
	[[PocketAPI sharedAPI] loginWithHandler:^(PocketAPI *api, NSError *error) {
		if(error){
			[self loginFailed:error];
		}else{
			[self loggedInSuccessfully];
		}
	}];
}

-(IBAction)logout:(id)sender{
	[[PocketAPI sharedAPI] logout];
}

-(void)loggedInSuccessfully{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Logged in"
											   message:[NSString stringWithFormat:@"You are logged in for the Pocket user %@.", [PocketAPI sharedAPI].username]
											  delegate:nil
									 cancelButtonTitle:nil
									 otherButtonTitles:@"Woo hoo!", nil];

	[alertView show];
	[alertView autorelease];
}

-(void)loginFailed:(NSError *)error{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error logging in"
														message:[NSString stringWithFormat:@"There was an error logging in: %@", [error localizedDescription]]
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"Awww", nil];
	
	[alertView show];
	[alertView autorelease];
}

-(void)updateNavigationBarTitle{
	NSString *title = [PocketAPI sharedAPI].username;
	if(!title || !title.length){
		title = @"Not Logged In";
	}
	
	self.navigationBar.topItem.title = title;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	NSDictionary *story = [self storyAtIndexPath:indexPath];
	NSURL *url = [self URLForStory:story];
	if(!url) return;
	
	unsigned long long tweetID = [(NSNumber *)[story objectForKey:@"id"] unsignedLongLongValue];
	
	NSString *title = [self formattedTextForStory:story];
	NSLog(@"Saving URL: %@", url);
	[[PocketAPI sharedAPI] saveURL:url withTitle:title tweetID:PocketAPITweetID(tweetID) handler:^(PocketAPI *api, NSURL *url, NSError *error) {
		if(error){
			NSLog(@"URL %@ could not be saved to %@'s Pocket account. Reason: %@", url, api.username, error.localizedDescription);
		}else{
			NSLog(@"URL %@ was saved to %@'s Pocket account", url, api.username);
		}
	}];
}


-(void)storySaved:(NSDictionary *)story{
	NSString *title = [self formattedTextForStory:story];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Saved!"
														message:[NSString stringWithFormat:@"Saved %@ successfully", title]
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"Yay!", nil];
	[alertView show];
	[alertView release];
}

-(void)storyFailed:(NSDictionary *)story withError:(NSError *)error{
	NSString *errorMessage = error.localizedDescription;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save Failed"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"Aww…", nil];
	[alertView show];
	[alertView release];
}

#pragma mark Pocket API callbacks

-(void)pocketAPILoggedIn:(PocketAPI *)api{
	NSLog(@"Pocket API logged in for user %@", [api username]);
}

-(void)pocketAPI:(PocketAPI *)api hadLoginError:(NSError *)error{
	NSLog(@"Pocket API could not log in: %@", [error localizedDescription]);
}

-(void)pocketAPI:(PocketAPI *)api savedURL:(NSURL *)url{
	NSLog(@"Pocket API saved URL %@ for user %@", url, [api username]);
}

-(void)pocketAPI:(PocketAPI *)api failedToSaveURL:(NSURL *)url error:(NSError *)error{
	NSLog(@"Pocket API could not save URL %@ for user %@: %@.", url, [api username], [error localizedDescription]);
}

@end
