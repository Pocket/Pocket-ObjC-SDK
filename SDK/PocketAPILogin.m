//
//  PocketAPILogin.m
//  iOS Test App
//
//  Created by Steve Streza on 7/23/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import "PocketAPILogin.h"
#import "PocketAPIOperation.h"

@interface PocketAPIOperation (Private)

-(void)pkt_setBaseURLPath:(NSString *)baseURLPath;

@end

@implementation PocketAPILogin

@synthesize API, uuid, requestToken, accessToken;

-(void)encodeWithCoder:(NSCoder *)aCoder{
	[aCoder encodeObject:self.requestToken forKey:@"requestToken"];
	[aCoder encodeObject:self.accessToken  forKey:@"accessToken" ];
	[aCoder encodeObject:self.uuid         forKey:@"uuid"        ];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
	if(self = [self init]){
		requestToken = [[aDecoder decodeObjectForKey:@"requestToken"] retain];
		accessToken  = [[aDecoder decodeObjectForKey:@"accessToken" ] retain];
		uuid         = [[aDecoder decodeObjectForKey:@"uuid"        ] retain];
	}
	return self;
}

-(void)dealloc{
	[operationQueue waitUntilAllOperationsAreFinished];
	[operationQueue release], operationQueue = nil;
	
	[requestToken release], requestToken = nil;
	[accessToken  release], accessToken  = nil;
	[API release], API = nil;
	
	[super dealloc];
}

-(id)init{
	if(self = [super init]){
		operationQueue = [[NSOperationQueue alloc] init];
		API = [[PocketAPI sharedAPI] retain];
		
		CFUUIDRef uuidRef = CFUUIDCreate(NULL);
		uuid = (NSString *)CFUUIDCreateString(NULL, uuidRef);
		CFRelease(uuidRef);
	}
	return self;
}

-(id)initWithAPI:(PocketAPI *)newAPI{
	if(self = [self init]){
		[newAPI retain];
		[API release];
		API = newAPI;
	}
	return self;
}

-(void)fetchRequestToken{
	PocketAPIOperation *operation = [[PocketAPIOperation alloc] init];
	operation.API = API;
	operation.delegate = self;
	operation.domain = PocketAPIDomainAuth;
	operation.method = @"request";
	
	NSString *redirectURLPath = [NSString stringWithFormat:@"pocket-app-%i:", [self.API appID]];;
	
	operation.arguments = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"code", @"response_type",
						   self.uuid, @"state",
						   redirectURLPath, @"redirect_uri",
						   nil];
	[operationQueue addOperation:operation];
}

#pragma mark Pocket API Delegate

-(void)pocketAPI:(PocketAPI *)api receivedRequestToken:(NSString *)requestToken{
	NSLog(@"Received request token %@",requestToken);
	NSURL *authorizeURL = nil;
	if([PocketAPI hasPocketAppInstalled]){
		authorizeURL = [NSURL URLWithString:[NSString stringWithFormat:@"pocket:///authorize?requestToken=%@",requestToken]];
	}else{
		authorizeURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://getpocket.com/apps/authorize?requestToken=%@",requestToken]];
	}
	
#if TARGET_OS_IPHONE
	[[UIApplication sharedApplication] openURL:authorizeURL];
#else
	[[NSWorkspace sharedWorkspace] openURL:authorizeURL];
#endif
}

@end
