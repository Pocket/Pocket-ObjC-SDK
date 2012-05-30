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

#import <UIKit/UIKit.h>
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