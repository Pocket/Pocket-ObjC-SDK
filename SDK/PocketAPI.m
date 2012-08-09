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
#import "PocketAPILogin.h"
#import "PocketAPIOperation.h"
#import <dispatch/dispatch.h>

static NSString *kPocketAPICurrentLoginKey = @"PocketAPICurrentLogin";

#pragma mark Private APIs (please do not call these directly)

@interface PocketAPI  ()
-(NSString *)pkt_getToken;

-(void)pkt_loadCurrentLoginFromDefaults;
-(void)pkt_saveCurrentLoginToDefaults;

-(NSDictionary *)pkt_actionDictionaryWithName:(NSString *)name parameters:(NSDictionary *)params;

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

@synthesize consumerKey;

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

+(BOOL)hasPocketAppInstalled{
#if TARGET_OS_IPHONE
	return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"pocket-oauth-v1:"]];
#else
	return NO;
#endif
}

-(id)init{
	if(self = [super init]){
		operationQueue = [[NSOperationQueue alloc] init];
		
		// set the initial API key to the one from the singleton
		if(sSharedAPI != self){
			self.consumerKey = [sSharedAPI consumerKey];
		}
		
		// register for lifecycle notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	}
	return self;
}

-(void)setConsumerKey:(NSString *)aConsumerKey{
	[aConsumerKey retain];
	[consumerKey release];
	consumerKey = aConsumerKey;
	
#if DEBUG
	if(!consumerKey) return;
	
	// check to make sure 
	NSString *expectedURLScheme = [self appURLScheme];
	BOOL foundURLScheme = NO;
	NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
	NSArray *urlSchemeLists = [infoDict objectForKey:@"CFBundleURLTypes"];
	for(NSDictionary *urlSchemeList in urlSchemeLists){
		NSArray *urlSchemes = [urlSchemeList objectForKey:@"CFBundleURLSchemes"];
		if([urlSchemes containsObject:expectedURLScheme]){
			foundURLScheme = YES;
			break;
		}
	}
	
	if(!foundURLScheme){
		NSLog(@"** WARNING: You haven't added a URL scheme for the Pocket SDK. This will prevent login from working. See the SDK readme.");
		NSLog(@"** The URL scheme you need to register is: %@",expectedURLScheme);
	}
#endif
}

-(void)applicationDidEnterBackground:(NSNotification *)notification{
	[self pkt_saveCurrentLoginToDefaults];
}

-(void)dealloc{
	[operationQueue waitUntilAllOperationsAreFinished];
	[operationQueue release], operationQueue = nil;

	[consumerKey release], consumerKey = nil;
	
	[super dealloc];
}

-(BOOL)handleOpenURL:(NSURL *)url{
	// TODO implement
	NSLog(@"URL to open: %@",url);
	if([[url scheme] isEqualToString:[self appURLScheme]]){
		[self pkt_loadCurrentLoginFromDefaults];
		[currentLogin convertRequestTokenToAccessToken];
		return YES;
	}
	
	return NO;
}

-(NSUInteger)appID{
	NSUInteger appID = NSNotFound;
	if(self.consumerKey){
		NSArray *keyPieces = [self.consumerKey componentsSeparatedByString:@"-"];
		if(keyPieces && keyPieces.count > 0){
			NSString *appIDPiece = [keyPieces objectAtIndex:0];
			if(appIDPiece && appIDPiece.length > 0){
				appID = [appIDPiece integerValue];
			}
		}
	}
	return appID;
}

-(NSString *)appURLScheme{
	return [NSString stringWithFormat:@"pocketapp%i", [self appID]];
}

-(BOOL)isLoggedIn{
	NSString *username = [self username];
	NSString *token    = [self pkt_getToken];
	return (username && token && username.length > 0 && token.length > 0);
}

-(void)loginWithDelegate:(id<PocketAPIDelegate>)delegate{
	[currentLogin autorelease];
	currentLogin = [[PocketAPILogin alloc] initWithAPI:self delegate:delegate];
	[currentLogin fetchRequestToken];
}

-(void)saveURL:(NSURL *)url delegate:(id<PocketAPIDelegate>)delegate{
	[operationQueue addOperation:[self saveOperationWithURL:url delegate:delegate]];
}

-(void)saveURL:(NSURL *)url withTitle:(NSString *)title delegate:(id<PocketAPIDelegate>)delegate{
	[operationQueue addOperation:[self saveOperationWithURL:url title:title delegate:delegate]];
}

-(NSOperation *)saveOperationWithURL:(NSURL *)url title:(NSString *)title delegate:(id<PocketAPIDelegate>)delegate{
	if(!url || !url.absoluteString) return nil;
	
	NSMutableDictionary *actionParameters = [NSMutableDictionary dictionary];
	[actionParameters setObject:url.absoluteString forKey:@"url"];
	
	if(title){
		[actionParameters setObject:title forKey:@"title"];
	}
	
	NSDictionary *action = [self pkt_actionDictionaryWithName:@"add" parameters:actionParameters];
	NSArray *actionsArray = [NSArray arrayWithObject:action];
	
	PocketAPIOperation *operation = [[[PocketAPIOperation alloc] init] autorelease];
	operation.API = self;
	operation.delegate = delegate;
	operation.APIMethod = @"send";
	operation.HTTPMethod = PocketAPIHTTPMethodPOST;
	operation.arguments = [NSDictionary dictionaryWithObjectsAndKeys:
						   actionsArray, @"actions",
						   nil];
	
	return operation;
}

-(NSOperation *)saveOperationWithURL:(NSURL *)url delegate:(id<PocketAPIDelegate>)delegate{
	return [self saveOperationWithURL:url title:nil delegate:delegate];
}

#if NS_BLOCKS_AVAILABLE

-(void)loginWithHandler:(PocketAPILoginHandler)handler{
	[self loginWithDelegate:[PocketAPIBlockDelegate delegateWithLoginHandler:handler]];
}

-(void)saveURL:(NSURL *)url handler:(PocketAPISaveHandler)handler{
	[self saveURL:url delegate:[PocketAPIBlockDelegate delegateWithSaveHandler:handler]];
}

-(void)saveURL:(NSURL *)url withTitle:(NSString *)title handler:(PocketAPISaveHandler)handler{
	[self saveURL:url withTitle:title delegate:[PocketAPIBlockDelegate delegateWithSaveHandler:handler]];
}

// operation API

-(NSOperation *)saveOperationWithURL:(NSURL *)url handler:(PocketAPISaveHandler)handler{
	return [self saveOperationWithURL:url delegate:[PocketAPIBlockDelegate delegateWithSaveHandler:handler]];
}

-(NSOperation *)saveOperationWithURL:(NSURL *)url title:(NSString *)title handler:(PocketAPISaveHandler)handler{
	return [self saveOperationWithURL:url title:title delegate:[PocketAPIBlockDelegate delegateWithSaveHandler:handler]];
}

#endif

#pragma mark Account Info

-(NSString *)username{
	return [self pkt_getKeychainValueForKey:@"username"];
}

-(NSString *)pkt_getToken{
	return [self pkt_getKeychainValueForKey:@"token"];
}

-(void)pkt_loggedInWithUsername:(NSString *)username token:(NSString *)token{
	[self willChangeValueForKey:@"username"];
	[self willChangeValueForKey:@"isLoggedIn"];
	
	[self pkt_setKeychainValue:username forKey:@"username"];
	[self pkt_setKeychainValue:token forKey:@"token"];
	
	[self  didChangeValueForKey:@"isLoggedIn"];
	[self  didChangeValueForKey:@"username"];
}

-(void)logout{
	[self willChangeValueForKey:@"username"];
	[self willChangeValueForKey:@"isLoggedIn"];
	
	[self pkt_setKeychainValue:nil forKey:@"username"];
	[self pkt_setKeychainValue:nil forKey:@"token"];
	
	[self  didChangeValueForKey:@"isLoggedIn"];
	[self  didChangeValueForKey:@"username"];
}

-(void)pkt_loadCurrentLoginFromDefaults{
	NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
	
	if(!currentLogin){
		NSData *data = [defaults dataForKey:kPocketAPICurrentLoginKey];
		if(data){
			PocketAPILogin *newLogin = [NSKeyedUnarchiver unarchiveObjectWithData:data];
			currentLogin = [newLogin retain];
		}
	}

	[defaults removeObjectForKey:kPocketAPICurrentLoginKey];
	[defaults synchronize];
	[defaults release];
}

-(void)pkt_saveCurrentLoginToDefaults{
	if(currentLogin){
		NSData *loginData = [NSKeyedArchiver archivedDataWithRootObject:currentLogin];
		
		NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
		[defaults setObject:loginData forKey:kPocketAPICurrentLoginKey];
		[defaults synchronize];
		[defaults release];
	}
}

-(NSDictionary *)pkt_actionDictionaryWithName:(NSString *)name parameters:(NSDictionary *)params{
	if(!name) return nil;
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
	[dict setObject:name forKey:@"action"];
	[dict setObject:[NSNumber numberWithInteger:(NSInteger)([[NSDate date] timeIntervalSince1970])] forKey:@"time"];
	
	return dict;
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