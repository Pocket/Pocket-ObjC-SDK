//
//  PocketTweetsViewController.m
//  iOS Test App
//
//  Created by Steve Streza on 8/24/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import "PocketTweetsViewController.h"

@interface PocketTweetsViewController ()

@end

@implementation PocketTweetsViewController

@synthesize stories, navigationBar, tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Load some stories from Twitter
	NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://search.twitter.com/search.json?q=pocket.co&result_type=recent&include_entities=true"]] autorelease];
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
		self.stories = [dataDictionary objectForKey:@"results"];
		[self.tableView reloadData];
	}];
}

#pragma mark UITableView

-(NSDictionary *)storyAtIndexPath:(NSIndexPath *)indexPath{
	return [self.stories objectAtIndex:indexPath.row];
}

-(NSString *)formattedTextForStory:(NSDictionary *)storyData{
	NSMutableString *text = [[[storyData objectForKey:@"text"] mutableCopy] autorelease];
	NSArray *urlEntities = [[storyData objectForKey:@"entities"] objectForKey:@"urls"];
	for(NSDictionary *entity in urlEntities){
		NSString *tcoURL = [entity objectForKey:@"url"];
		NSString *displayURL = [entity objectForKey:@"expanded_url"];
		[text replaceOccurrencesOfString:tcoURL withString:displayURL options:0 range:NSMakeRange(0, text.length)];
	}
	return text;
}

-(NSURL *)URLForStory:(NSDictionary *)storyData{
	NSArray *urlEntities = [[storyData objectForKey:@"entities"] objectForKey:@"urls"];
	for(NSDictionary *entity in urlEntities){
		NSString *urlString = [entity objectForKey:@"expanded_url"];
		if([urlString rangeOfString:@"pocket.co"].location != NSNotFound){
			return [NSURL URLWithString:urlString];
		}
	}
	return nil;
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
	cell.textLabel.text = [self formattedTextForStory:storyData];
	cell.detailTextLabel.text = [[self URLForStory:storyData] absoluteString];
	
	return cell;
}

@end
