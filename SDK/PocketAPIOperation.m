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
-(void)pkt_loggedInWithUsername:(NSString *)username password:(NSString *)password;
@end

@interface PocketAPIOperation ()

-(NSMutableURLRequest *)pkt_URLRequest;
-(NSString *)pkt_urlEncode:(NSString *)urlStr;

@end

@implementation PocketAPIOperation

@synthesize API, delegate;
@synthesize method, arguments;
@synthesize connection, response, data, error;

-(void)start{
	finishedLoading = NO;
	
	NSURLRequest *request = [self pkt_URLRequest];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	[connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
	
	[connection start];
}

-(BOOL)isConcurrent{
	return YES;
}

-(BOOL)isExecuting{
	return !finishedLoading;
}

-(BOOL)isFinished{
	return finishedLoading;
}

-(void)dealloc{
	[API release], API = nil;
	delegate = nil;
	
	[method release], method = nil;
	[arguments release], arguments = nil;
	
	[connection release], connection = nil;
	[response release], response = nil;
	[data release], data = nil;
	[error release], error = nil;
	
	[super dealloc];
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)receivedResponse{
	response = (NSHTTPURLResponse *)[receivedResponse retain];
	if([response statusCode] == 200){
		data = [[NSMutableData alloc] initWithLength:response.expectedContentLength];
	}else if([[response allHeaderFields] objectForKey:@"X-Error"]){
		[connection cancel];
		[self connection:connection didFailWithError:[NSError errorWithDomain:@"PocketSDK" 
																		 code:[response statusCode] 
																	 userInfo:[NSDictionary dictionaryWithObject:[[response allHeaderFields] objectForKey:@"X-Error"]
																										  forKey:@"error"]]];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)inData{
	[data appendData:inData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)theError{
	error = [theError retain];
	if([self.method isEqualToString:@"auth"]){
		if(self.delegate && [self.delegate respondsToSelector:@selector(pocketAPI:hadLoginError:)]){
			[self.delegate pocketAPI:self.API hadLoginError:error];
		}
	}else if([self.method isEqualToString:@"add"]){
		if(self.delegate && [self.delegate respondsToSelector:@selector(pocketAPI:failedToSaveURL:error:)]){
			[self.delegate pocketAPI:self.API 
					 failedToSaveURL:[NSURL URLWithString:[self.arguments objectForKey:@"url"]] 
							   error:error];
		}
	}

	[self willChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];
	finishedLoading = YES;
	[self  didChangeValueForKey:@"isFinished"];
	[self  didChangeValueForKey:@"isExecuting"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	if([self.method isEqualToString:@"auth"]){
		[self.API pkt_loggedInWithUsername:[self.arguments objectForKey:@"username"] password:[self.arguments objectForKey:@"password"]];
		
		if(self.delegate && [self.delegate respondsToSelector:@selector(pocketAPILoggedIn:)]){
			[self.delegate pocketAPILoggedIn:self.API];
		}
	}else if([self.method isEqualToString:@"add"]){
		if(self.delegate && [self.delegate respondsToSelector:@selector(pocketAPI:savedURL:)]){
			[self.delegate pocketAPI:self.API 
							savedURL:[NSURL URLWithString:[self.arguments objectForKey:@"url"]]];
		}
	}

	[self willChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];
	finishedLoading = YES;
	[self  didChangeValueForKey:@"isFinished"];
	[self  didChangeValueForKey:@"isExecuting"];
}

#pragma mark Private APIs

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
	
	NSString *urlString = [NSString stringWithFormat:@"http://readitlaterlist.com/v2/%@", self.method];
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
