//
//  PocketTweetsViewController.h
//  iOS Test App
//
//  Created by Steve Streza on 8/24/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PocketTweetsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NSArray *stories;

	UITableView *tableView;
	UINavigationBar *navigationBar;
}

@property (nonatomic, retain) NSArray *stories;

@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

-(NSDictionary *)storyAtIndexPath:(NSIndexPath *)indexPath;
-(NSString *)formattedTextForStory:(NSDictionary *)storyData;
-(NSURL *)URLForStory:(NSDictionary *)storyData;

@end
