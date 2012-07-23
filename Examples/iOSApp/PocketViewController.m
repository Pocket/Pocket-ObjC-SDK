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

@synthesize stories, tableView;

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

#pragma mark Pocket APIs

-(IBAction)login:(id)sender{
	[[PocketAPI sharedAPI] loginWithHandler:^(PocketAPI *api, NSError *error) {
		NSLog(@"API logged in with error %@: %@", error, api.username);
	}];
}

-(IBAction)logout:(id)sender{
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
