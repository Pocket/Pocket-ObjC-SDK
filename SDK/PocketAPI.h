//
//  PocketAPI.h
//  PocketSDK
//
//  Created by Steve Streza on 5/29/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PocketAPI;

@protocol PocketAPIDelegate <NSObject>
@optional
-(void)pocketAPILoggedIn:(PocketAPI *)api;
-(void)pocketAPI:(PocketAPI *)api hadLoginError:(NSError *)error;

-(void)pocketAPI:(PocketAPI *)api savedURL:(NSURL *)url;
-(void)pocketAPI:(PocketAPI *)api failedToSaveURL:(NSURL *)url error:(NSError *)error;

@end

@interface PocketAPI : NSObject {
	NSString *APIKey;
}

+(PocketAPI *)sharedAPI;

-(void)setAPIKey:(NSString *)APIKey;

-(void)loginWithUsername:(NSString *)username password:(NSString *)password delegate:(id<PocketAPIDelegate>)delegate;
-(void)saveURL:(NSURL *)url delegate:(id<PocketAPIDelegate>)delegate;
-(void)saveURL:(NSURL *)url withTitle:(NSString *)title delegate:(id<PocketAPIDelegate>)delegate;

@property (nonatomic, retain) NSString *APIKey;

@property (nonatomic, copy, readonly) NSString *username;
@property (nonatomic, assign, readonly, getter=isLoggedIn) BOOL loggedIn;

@end
