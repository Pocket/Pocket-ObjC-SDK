//
//  PocketAPI.m
//  PocketSDK
//
//  Created by Steve Streza on 5/29/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import "PocketAPI.h"
#import "PocketAPIOperation.h"
#import <dispatch/dispatch.h>

#pragma mark Private APIs (please do not call these directly)

@interface PocketAPI (Credentials)

-(void)pkt_setKeychainValue:(id)value forKey:(NSString *)key;
-(id)pkt_getKeychainValueForKey:(NSString *)key;

@end

#pragma mark Implementation

@implementation PocketAPI

@synthesize APIKey;

#pragma mark Public API

static PocketAPI *sSharedAPI = nil;

+(PocketAPI *)sharedAPI{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sSharedAPI = [[PocketAPI alloc] init];
	});
	return sSharedAPI;
}

-(BOOL)isLoggedIn{
	NSString *username = [self username];
	NSString *password = [self pkt_getPassword];
	return (username && password && username.length > 0 && password.length > 0);
}

-(void)loginWithUsername:(NSString *)username password:(NSString *)password delegate:(id<PocketAPIDelegate>)delegate{
	PocketAPIOperation *operation = [[PocketAPIOperation alloc] init];
	operation.API = self;
	operation.delegate = delegate;
	operation.method = @"auth";
	operation.arguments = [NSDictionary dictionaryWithObjectsAndKeys:
						   username, @"username",
						   password, @"password",
						   nil];
}

-(void)saveURL:(NSURL *)url delegate:(id<PocketAPIDelegate>)delegate{
	
}

#pragma mark Account Info

-(NSString *)username{
	return [self pkt_getKeychainValueForKey:@"username"];
}

-(NSString *)pkt_getPassword{
	return [self pkt_getKeychainValueForKey:@"password"];
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
		[SFHFKeychainUtils storeUsername:key andPassword:value forServiceName:RILGlobalKeychainServiceName updateExisting:YES error:nil];
#endif
	}else{
#if TARGET_IPHONE_SIMULATOR
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@.%@", PocketGlobalKeychainServiceName, key]];
#else
		[SFHFKeychainUtils deleteItemForUsername:key andServiceName:RILGlobalKeychainServiceName error:nil];
#endif
	}
}

-(id)pkt_getKeychainValueForKey:(NSString *)key{
#if TARGET_IPHONE_SIMULATOR
	return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@.%@", PocketGlobalKeychainServiceName, key]];
#else
	return [SFHFKeychainUtils getPasswordForUsername:key andServiceName:RILGlobalKeychainServiceName error:nil];
#endif
}

@end