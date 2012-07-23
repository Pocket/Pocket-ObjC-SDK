//
//  PocketAPILogin.h
//  iOS Test App
//
//  Created by Steve Streza on 7/23/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PocketAPI.h"

@interface PocketAPILogin : NSObject <NSCoding, PocketAPIDelegate> {
	PocketAPI *API;
	
	NSString *uuid; // unique ID for the login process
	
	NSString *requestToken;
	NSString *accessToken;
	
	NSOperationQueue *operationQueue;
}

-(id)initWithAPI:(PocketAPI *)api;

@property (nonatomic, readonly, retain) PocketAPI *API;
@property (nonatomic, readonly, retain) NSString *uuid;
@property (nonatomic, readonly, retain) NSString *requestToken;
@property (nonatomic, readonly, retain) NSString *accessToken;

-(void)fetchRequestToken;

@end
