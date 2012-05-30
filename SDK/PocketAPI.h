//
//  PocketAPI.h
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

/**
 * The PocketAPI class represents a singleton for saving stuff to a user's Pocket list.
 * To begin, you will need to obtain an API token from https://getpocket.com/api/ and set it
 * on the PocketAPI singleton at some point at the beginning of your application's lifecycle.
 *
 * APIs are presented in one of four ways, but all behave fundamentally the same. Their differences
 * are presented for flexibility for your app. You can use:
 *
 * - a delegate-based API
 * - a block-based API
 * - an NSOperation based on a delegate (for advanced uses)
 * - an NSOperation based on a block (for advanced uses)
 *
 * All delegates and blocks are called on the main thread, so you can safely update UI from there.
 *
 * You can find more information on these in PocketAPITypes.h
 *
 * You will have to present your own login form to the user using UI appropriate for your app.
 * You should check the loggedIn property on the PocketAPI to see if you should present a login UI.
 * Once you have a username and password, call one of the login methods below. If it succeeds,
 * your delegate or block will be notified and the user's credentials will be saved automatically
 * to the keychain.
 *
 * Once the user is logged in, and manually decides to save a URL to their Pocket list, you can
 * call one of the save APIs to save the URL. If you get no error back, the save succeeded, and
 * you should notify the user that their item was saved successfully to their Pocket list.
 * If you get an error back, there are a few status codes you should keep an eye out for:
 * 
 * - 401: This means the user's account information is invalid and you should prompt to login again.
 * - 503: This means the server is temporarily down. The error will contain a message explaining why.
 *
 * The Save API also will inform you through an argument that the user needs to login again or not.
 *
 * These classes are not implemented as ARC, but will interoperate with ARC. You will need to add the
 * -fno-objc-arc compiler flag to each of the files in the SDK.
 */

#import <Foundation/Foundation.h>
#import "PocketAPITypes.h"

@interface PocketAPI : NSObject {
	NSString *APIKey;
	NSOperationQueue *operationQueue;
}

@property (nonatomic, retain) NSString *APIKey;

@property (nonatomic, copy, readonly) NSString *username;
@property (nonatomic, assign, readonly, getter=isLoggedIn) BOOL loggedIn;

+(PocketAPI *)sharedAPI;

-(void)setAPIKey:(NSString *)APIKey;

// Simple API
-(void)loginWithUsername:(NSString *)username password:(NSString *)password delegate:(id<PocketAPIDelegate>)delegate;
-(void)saveURL:(NSURL *)url delegate:(id<PocketAPIDelegate>)delegate;

#if NS_BLOCKS_AVAILABLE
-(void)loginWithUsername:(NSString *)username password:(NSString *)password handler:(PocketAPILoginHandler)handler;
-(void)saveURL:(NSURL *)url handler:(PocketAPISaveHandler)handler;
#endif

@end

// Advanced use if you use your own NSOperationQueues for handling network traffic.
// If you don't need tight control over network requests, just use the simple API.
@interface PocketAPI (NSOperations)

-(NSOperation *)loginOperationWithUsername:(NSString *)username password:(NSString *)password delegate:(id<PocketAPIDelegate>)delegate;
-(NSOperation *)saveOperationWithURL:(NSURL *)url delegate:(id<PocketAPIDelegate>)delegate;

#if NS_BLOCKS_AVAILABLE
-(NSOperation *)loginOperationWithUsername:(NSString *)username password:(NSString *)password handler:(PocketAPILoginHandler)handler;
-(NSOperation *)saveOperationWithURL:(NSURL *)url handler:(PocketAPISaveHandler)handler;
#endif

@end