//
//  PocketAPIOperation.m
//  PocketSDK
//
//  Created by Steve Streza on 5/29/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import "PocketAPIOperation.h"

@interface PocketAPI ()
-(NSString *)pkt_getPassword;
@end

@interface PocketAPIOperation ()

-(NSMutableURLRequest *)pkt_URLRequestForMethod:(NSString *)method arguments:(NSDictionary *)args;
-(NSString *)pkt_urlEncode:(NSString *)urlStr;

@end

@implementation PocketAPIOperation

@synthesize API, delegate;
@synthesize method, arguments;

-(NSMutableURLRequest *)pkt_URLRequest{
	NSMutableArray *pairs = [NSMutableArray array];
	
	if(self.API.APIKey){
		[pairs addObject:[NSString stringWithFormat:@"apikey=%@", [self pkt_urlEncode:self.API.APIKey]]];
	}
	
	NSString *username = [self.API username];
	NSString *password = [self.API pkt_getPassword];
	if(username && password){
		[pairs addObject:[NSString stringWithFormat:@"username=%@", [self pkt_urlEncode:username]]];
		[pairs addObject:[NSString stringWithFormat:@"password=%@", [self pkt_urlEncode:password]]];
	}
	
	for(NSString *key in [self.arguments allKeys]){
		[pairs addObject:[NSString stringWithFormat:@"%@=%@",key, [self pkt_urlEncode:[self.arguments objectForKey:key]]]];
	}
	
	NSString *urlString = [NSString stringWithFormat:@"https://readitlaterlist.com/v2/%@", self.method];
	if(pairs.count > 0){
		urlString = [urlString stringByAppendingFormat:@"?%@", [pairs componentsJoinedByString:@"&"]];
	}
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	return [request autorelease];
}

-(NSString *)pkt_urlEncode:(NSString *)urlStr
{
	NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)urlStr,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
	return [result autorelease];
}

@end
