//
//  PocketAppDelegate.h
//  PocketSDK
//
//  Created by Steve Streza on 5/29/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PocketViewController;

@interface PocketAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) PocketViewController *viewController;

@end
