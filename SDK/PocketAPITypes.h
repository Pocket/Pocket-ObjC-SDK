//
//  PocketAPITypes.h
//  PocketSDK
//
//  Created by Steve Streza on 5/29/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PocketAPI;

@protocol PocketAPIDelegate <NSObject>
@optional
-(void)pocketAPI:(PocketAPI *)api receivedRequestToken:(NSString *)requestToken;
-(void)pocketAPILoggedIn:(PocketAPI *)api;
-(void)pocketAPI:(PocketAPI *)api hadLoginError:(NSError *)error;

-(void)pocketAPI:(PocketAPI *)api savedURL:(NSURL *)url;
-(void)pocketAPI:(PocketAPI *)api failedToSaveURL:(NSURL *)url error:(NSError *)error needsToRelogin:(BOOL)needsToRelogin;

-(void)pocketAPI:(PocketAPI *)api receivedResponse:(NSDictionary *)response forAPIMethod:(NSString *)APIMethod error:(NSError *)error;
@end

#if NS_BLOCKS_AVAILABLE
typedef void(^PocketAPILoginHandler)(PocketAPI *api, NSError *error);
typedef void(^PocketAPISaveHandler)(PocketAPI *api, NSURL *url, NSError *error, BOOL needsToRelogin);
typedef void(^PocketAPIResponseHandler)(PocketAPI *api, NSString *apiMethod, NSDictionary *response, NSError *error);
#endif

typedef enum {
	PocketAPIDomainDefault = 0,
	PocketAPIDomainAuth = 10
} PocketAPIDomain;

typedef enum {
	PocketAPIHTTPMethodGET,
	PocketAPIHTTPMethodPOST,
	PocketAPIHTTPMethodPUT,
	PocketAPIHTTPMethodDELETE
} PocketAPIHTTPMethod;