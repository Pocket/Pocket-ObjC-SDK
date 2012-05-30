//
//  PocketAPI.m
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

#import "PocketAPI.h"
#import "PocketAPIOperation.h"
#import <dispatch/dispatch.h>

#pragma mark Private APIs (please do not call these directly)

@interface PocketAPI  ()
-(NSString *)pkt_getPassword;
@end

@interface PocketAPI (Credentials)

-(void)pkt_setKeychainValue:(id)value forKey:(NSString *)key;
-(id)pkt_getKeychainValueForKey:(NSString *)key;

@end

#if NS_BLOCKS_AVAILABLE
@interface PocketAPIBlockDelegate : NSObject <PocketAPIDelegate>{
	PocketAPILoginHandler loginHandler;
	PocketAPISaveHandler saveHandler;
}

+(id)delegateWithLoginHandler:(PocketAPILoginHandler)handler;
+(id)delegateWithSaveHandler: (PocketAPISaveHandler )handler;

@property (nonatomic, copy) PocketAPILoginHandler loginHandler;
@property (nonatomic, copy) PocketAPISaveHandler saveHandler;
@end
#endif

#pragma mark Implementation

@implementation PocketAPI

@synthesize APIKey;

#pragma mark Public API

static PocketAPI *sSharedAPI = nil;

+(PocketAPI *)sharedAPI{
	@synchronized(self)
    {
        if (sSharedAPI == NULL){
            sSharedAPI = [self alloc];
			[sSharedAPI init];
		}
    }
	
    return(sSharedAPI);
}

-(id)init{
	if(self = [super init]){
		operationQueue = [[NSOperationQueue alloc] init];
		
		// set the initial API key to the one from the singleton
		if(sSharedAPI != self){
			APIKey = [sSharedAPI APIKey];
		}
	}
	return self;
}

-(void)dealloc{
	[operationQueue waitUntilAllOperationsAreFinished];
	[operationQueue release], operationQueue = nil;

	[APIKey release], APIKey = nil;
	
	[super dealloc];
}

-(BOOL)isLoggedIn{
	NSString *username = [self username];
	NSString *password = [self pkt_getPassword];
	return (username && password && username.length > 0 && password.length > 0);
}

-(void)loginWithUsername:(NSString *)username password:(NSString *)password delegate:(id<PocketAPIDelegate>)delegate{
	[operationQueue addOperation:[self loginOperationWithUsername:username password:password delegate:delegate]];
}

-(void)saveURL:(NSURL *)url delegate:(id<PocketAPIDelegate>)delegate{
	[operationQueue addOperation:[self saveOperationWithURL:url delegate:delegate]];
}

-(NSOperation *)loginOperationWithUsername:(NSString *)username password:(NSString *)password delegate:(id<PocketAPIDelegate>)delegate{
	PocketAPIOperation *operation = [[[PocketAPIOperation alloc] init] autorelease];
	operation.API = self;
	operation.delegate = delegate;
	operation.method = @"auth";
	operation.arguments = [NSDictionary dictionaryWithObjectsAndKeys:
						   username, @"username",
						   password, @"password",
						   nil];
	return operation;
}

-(NSOperation *)saveOperationWithURL:(NSURL *)url delegate:(id<PocketAPIDelegate>)delegate{
	PocketAPIOperation *operation = [[[PocketAPIOperation alloc] init] autorelease];
	operation.API = self;
	operation.delegate = delegate;
	operation.method = @"add";
	operation.arguments = [NSDictionary dictionaryWithObjectsAndKeys:
						   [url absoluteString], @"url",
						   nil];
	
	return operation;
}

#if NS_BLOCKS_AVAILABLE

-(void)loginWithUsername:(NSString *)username password:(NSString *)password handler:(PocketAPILoginHandler)handler{
	[self loginWithUsername:username password:password delegate:[PocketAPIBlockDelegate delegateWithLoginHandler:handler]];
}

-(void)saveURL:(NSURL *)url handler:(PocketAPISaveHandler)handler{
	[self saveURL:url delegate:[PocketAPIBlockDelegate delegateWithSaveHandler:handler]];
}

// operation API

-(NSOperation *)loginOperationWithUsername:(NSString *)username password:(NSString *)password handler:(PocketAPILoginHandler)handler{
	return [self loginOperationWithUsername:username password:password delegate:[PocketAPIBlockDelegate delegateWithLoginHandler:handler]];
}

-(NSOperation *)saveOperationWithURL:(NSURL *)url handler:(PocketAPISaveHandler)handler{
	return [self saveOperationWithURL:url delegate:[PocketAPIBlockDelegate delegateWithSaveHandler:handler]];
}

#endif

#pragma mark Account Info

-(NSString *)username{
	return [self pkt_getKeychainValueForKey:@"username"];
}

-(NSString *)pkt_getPassword{
	return [self pkt_getKeychainValueForKey:@"password"];
}

-(void)pkt_loggedInWithUsername:(NSString *)username password:(NSString *)password{
	[self pkt_setKeychainValue:username forKey:@"username"];
	[self pkt_setKeychainValue:password forKey:@"password"];
}

@end

#pragma mark Keychain Credentials

#import <TargetConditionals.h>
#import "SFHFKeychainUtils.h"

@implementation PocketAPI (Credentials)

#define PocketGlobalKeychainServiceName @"PocketAPI"

-(void)pkt_setKeychainValue:(id)value forKey:(NSString *)key{
	if(value){
#if TARGET_IPHONE_SIMULATOR
		[[NSUserDefaults standardUserDefaults] setObject:value forKey:[NSString stringWithFormat:@"%@.%@", PocketGlobalKeychainServiceName, key]];
#else
		[SFHFKeychainUtils storeUsername:key andPassword:value forServiceName:PocketGlobalKeychainServiceName updateExisting:YES error:nil];
#endif
	}else{
#if TARGET_IPHONE_SIMULATOR
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@.%@", PocketGlobalKeychainServiceName, key]];
#else
		[SFHFKeychainUtils deleteItemForUsername:key andServiceName:PocketGlobalKeychainServiceName error:nil];
#endif
	}
}

-(id)pkt_getKeychainValueForKey:(NSString *)key{
#if TARGET_IPHONE_SIMULATOR
	return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@.%@", PocketGlobalKeychainServiceName, key]];
#else
	return [SFHFKeychainUtils getPasswordForUsername:key andServiceName:PocketGlobalKeychainServiceName error:nil];
#endif
}

@end

#if NS_BLOCKS_AVAILABLE
@implementation PocketAPIBlockDelegate

@synthesize loginHandler, saveHandler;

-(void)pocketAPILoggedIn:(PocketAPI *)api{
	if(self.loginHandler){
		self.loginHandler(api, nil);
	}
}

-(void)pocketAPI:(PocketAPI *)api hadLoginError:(NSError *)error{
	if(self.loginHandler){
		self.loginHandler(api, error);
	}
}

-(void)pocketAPI:(PocketAPI *)api savedURL:(NSURL *)url{
	if(self.saveHandler){
		self.saveHandler(api, url, nil, NO);
	}
}

-(void)pocketAPI:(PocketAPI *)api failedToSaveURL:(NSURL *)url error:(NSError *)error needsToRelogin:(BOOL)needsToRelogin{
	if(self.saveHandler){
		self.saveHandler(api, url, error, needsToRelogin);
	}
}

+(id)delegateWithLoginHandler:(PocketAPILoginHandler)handler{
	PocketAPIBlockDelegate *delegate = [[[self alloc] init] autorelease];
	delegate.loginHandler = [[handler copy] autorelease];
	return delegate;
}

+(id)delegateWithSaveHandler: (PocketAPISaveHandler)handler{
	PocketAPIBlockDelegate *delegate = [[[self alloc] init] autorelease];
	delegate.saveHandler = [[handler copy] autorelease];
	return delegate;
}

-(void)dealloc{
	[loginHandler release], loginHandler = nil;
	[saveHandler release], saveHandler = nil;
	
	[super dealloc];
}

@end
#endif