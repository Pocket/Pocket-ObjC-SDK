//
//  PocketAPITypes.h
//  PocketSDK
//
//  Created by Steve Streza on 5/29/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
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

#import <Foundation/Foundation.h>

@class PocketAPI;

@protocol PocketAPIDelegate <NSObject>
@optional
-(void)pocketAPI:(PocketAPI *)api receivedRequestToken:(NSString *)requestToken;

-(void)pocketAPILoggedIn:(PocketAPI *)api;
-(void)pocketAPI:(PocketAPI *)api hadLoginError:(NSError *)error;

-(void)pocketAPI:(PocketAPI *)api savedURL:(NSURL *)url;
-(void)pocketAPI:(PocketAPI *)api failedToSaveURL:(NSURL *)url error:(NSError *)error;

-(void)pocketAPI:(PocketAPI *)api receivedResponse:(NSDictionary *)response forAPIMethod:(NSString *)APIMethod error:(NSError *)error;

-(void)pocketAPIDidStartLogin:(PocketAPI *)api;
-(void)pocketAPIDidFinishLogin:(PocketAPI *)api;
@end

@protocol PocketAPISupport <NSObject>
@optional
-(BOOL)shouldAllowPocketReverseAuth;

@end

#if NS_BLOCKS_AVAILABLE
typedef void(^PocketAPILoginHandler)(PocketAPI *api, NSError *error);
typedef void(^PocketAPISaveHandler)(PocketAPI *api, NSURL *url, NSError *error);
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

typedef enum {
	//OAuth Errors
	PocketAPIErrorNoConsumerKey = 138,
	PocketAPIErrorNoAccessToken = 107,
	PocketAPIErrorInvalidConsumerKey = 136,
	PocketAPIErrorInvalidRequest = 130,
	PocketAPIErrorNoChangesMade = 131,
	PocketAPIErrorConsumerKeyAccessTokenMismatch = 137,
	PocketAPIErrorEndpointForbidden = 150,
	PocketAPIErrorEndpointRequiresAdditionalPermissions = 151,
	
	// Signup Errors
	PocketAPIErrorSignupInvalidUsernameAndPassword  = 100,
	PocketAPIErrorSignupInvalidUsername = 101,
	PocketAPIErrorSignupInvalidPassword = 102,
	PocketAPIErrorSignupInvalidEmail    = 103,
	PocketAPIErrorSignupUsernameTaken = 104,
	PocketAPIErrorSignupEmailTaken = 105,

	// Server Problems
	PocketAPIErrorServerMaintenance = 199
} PocketAPIError;

extern NSString * const PocketAPIErrorDomain;

extern NSString * const PocketAPILoginStartedNotification;
extern NSString * const PocketAPILoginFinishedNotification;
