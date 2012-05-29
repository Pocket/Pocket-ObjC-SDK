//
//  PocketViewController.h
//  PocketSDK
//
//  Created by Steve Streza on 5/29/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PocketAPI.h"

@interface PocketViewController : UIViewController <PocketAPIDelegate>{
	UITextField *usernameField;
	UITextField *passwordField;
	UITextField *URLField;
}

@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UITextField *URLField;

-(IBAction)login:(id)sender;
-(IBAction)saveURL:(id)sender;

@end
