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

@synthesize stories, tableView, coverView, navigationBar;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Load some stories from Reddit
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.reddit.com/.json"]];
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
		self.stories = [[dataDictionary objectForKey:@"data"] objectForKey:@"children"];
		[self.tableView reloadData];
	}];
	
	[self updateNavigationBarTitle];
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

#pragma mark UITableView

-(NSDictionary *)storyAtIndexPath:(NSIndexPath *)indexPath{
	return [[self.stories objectAtIndex:indexPath.row] objectForKey:@"data"];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.stories.count;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"StoryCell"];
	if(!cell){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"StoryCell"] autorelease];
	}
	
	NSDictionary *storyData = [self storyAtIndexPath:indexPath];
	cell.textLabel.text = [storyData objectForKey:@"title"];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%i pts • /r/%@ • %@",
								 [[storyData objectForKey:@"score"] intValue],
								 [storyData objectForKey:@"subreddit"],
								 [storyData objectForKey:@"domain"]];
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString *urlString = [[self storyAtIndexPath:indexPath] objectForKey:@"url"];
	if(!urlString) return;
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSLog(@"Saving URL: %@", url);
	[[PocketAPI sharedAPI] saveURL:url handler:^(PocketAPI *api, NSURL *url, NSError *error, BOOL needsToRelogin) {
		if(error){
			NSLog(@"URL %@ could not be saved to %@'s Pocket account. Needs to relogin? %@. Reason: %@", url, api.username, (needsToRelogin ? @"Yes" : @"No"), error.localizedDescription);
		}else{
			NSLog(@"URL %@ was saved to %@'s Pocket account", url, api.username);
		}
	}];
}

#pragma mark Pocket APIs

-(IBAction)login:(id)sender{
	[self.coverView setHidden:NO];
	[[PocketAPI sharedAPI] loginWithHandler:^(PocketAPI *api, NSError *error) {
		[self.coverView setHidden:YES];
		NSLog(@"API logged in with error %@: %@", error, api.username);

		UIAlertView *alertView = nil;
		if(error){
			alertView = [[UIAlertView alloc] initWithTitle:@"Error logging in"
												   message:[NSString stringWithFormat:@"There was an error logging in: %@", [error localizedDescription]]
												  delegate:nil
										 cancelButtonTitle:nil
										 otherButtonTitles:@"Awww", nil];
		}else{
			alertView = [[UIAlertView alloc] initWithTitle:@"Logged in"
												   message:[NSString stringWithFormat:@"You are logged in for the Pocket user %@.", api.username]
												  delegate:nil
										 cancelButtonTitle:nil
										 otherButtonTitles:@"Woo hoo!", nil];
		}
		[self updateNavigationBarTitle];
		[alertView show];
		[alertView autorelease];
	}];
}

-(IBAction)logout:(id)sender{
	[[PocketAPI sharedAPI] logout];
	[self updateNavigationBarTitle];
}

-(void)updateNavigationBarTitle{
	NSString *title = [PocketAPI sharedAPI].username;
	if(!title || !title.length){
		title = @"Not Logged In";
	}
	
	self.navigationBar.topItem.title = title;
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

-(void)pocketAPI:(PocketAPI *)api failedToSaveURL:(NSURL *)url error:(NSError *)error needsToRelogin:(BOOL)needsToRelogin{
	NSLog(@"Pocket API could not save URL %@ for user %@: %@. Should prompt to reauth user: %@", url, [api username], [error localizedDescription], needsToRelogin?@"Yes":@"No");
}

@end
