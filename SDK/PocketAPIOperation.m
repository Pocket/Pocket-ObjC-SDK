//
//  PocketAPIOperation.m
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

#import "PocketAPIOperation.h"

@interface PocketAPI ()
-(void)pkt_loggedInWithUsername:(NSString *)username token:(NSString *)accessToken;
@end

@interface PocketAPIOperation ()

-(void)pkt_connectionFinishedLoading;

-(NSMutableURLRequest *)pkt_URLRequest;
-(NSString *)pkt_urlEncode:(NSString *)urlStr;

@end

@implementation PocketAPIOperation

@synthesize API, delegate, error;

@synthesize domain, method, arguments;
@synthesize connection, response, data;

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

-(id)init{
	if(self = [super init]){
		domain = PocketAPIDomainDefault;
	}
	return self;
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

-(NSString *)description{
	return [NSString stringWithFormat:@"<%@: %p https://%@%@ %@>", [self class], self, self.baseURLPath, self.method, self.arguments];
}

-(NSString *)baseURLPath{
	switch (self.domain) {
		case PocketAPIDomainAuth:
			return @"getpocket.com/oauth/";
			break;
		case PocketAPIDomainDefault:
		default:
			return @"getpocket.com/v2/";
			break;
	}
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)receivedResponse{
	response = (NSHTTPURLResponse *)[receivedResponse retain];
	if([response statusCode] == 200){
		data = [[NSMutableData alloc] initWithCapacity:0];
	}else if([[response allHeaderFields] objectForKey:@"X-Error"]){
		[connection cancel];
        NSString *xError = [[response allHeaderFields] objectForKey:@"X-Error"];
        NSDictionary *userInfo = xError ? [NSDictionary dictionaryWithObjectsAndKeys:xError,NSLocalizedDescriptionKey,nil] : nil;
		[self connection:connection didFailWithError:[NSError errorWithDomain:@"PocketSDK" 
																		 code:[response statusCode] 
																	 userInfo:userInfo]];
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
		if(self.delegate && [self.delegate respondsToSelector:@selector(pocketAPI:failedToSaveURL:error:needsToRelogin:)]){
			[self.delegate pocketAPI:self.API 
					 failedToSaveURL:[NSURL URLWithString:[self.arguments objectForKey:@"url"]] 
							   error:error
					  needsToRelogin:[error code] == 401];
		}
	}else if([self.method isEqualToString:@"request"]){
		[self.delegate pocketAPI:self.API receivedRequestToken:@"abc123"];
	}
	
	[self pkt_connectionFinishedLoading];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	if([self.method isEqualToString:@"auth"]){
		[self.API pkt_loggedInWithUsername:[self.arguments objectForKey:@"username"] token:[self.arguments objectForKey:@"token"]];
		
		if(self.delegate && [self.delegate respondsToSelector:@selector(pocketAPILoggedIn:)]){
			[self.delegate pocketAPILoggedIn:self.API];
		}
	}else if([self.method isEqualToString:@"add"]){
		if(self.delegate && [self.delegate respondsToSelector:@selector(pocketAPI:savedURL:)]){
			[self.delegate pocketAPI:self.API 
							savedURL:[NSURL URLWithString:[self.arguments objectForKey:@"url"]]];
		}
	}
	else if([self.method isEqualToString:@"request"]){
		[self.delegate pocketAPI:self.API receivedRequestToken:@"abc123"];
	}
	
	[self pkt_connectionFinishedLoading];
}

#pragma mark Private APIs

-(NSMutableURLRequest *)pkt_URLRequest{
	NSMutableArray *pairs = [NSMutableArray array];
	
	if(self.API.consumerKey){
		[pairs addObject:[NSString stringWithFormat:@"consumer_key=%@", [self pkt_urlEncode:self.API.consumerKey]]];
	}
	
	for(NSString *key in [self.arguments allKeys]){
		[pairs addObject:[NSString stringWithFormat:@"%@=%@",key, [self pkt_urlEncode:[self.arguments objectForKey:key]]]];
	}
	
	NSString *urlString = [NSString stringWithFormat:@"https://%@/%@", self.baseURLPath, self.method];
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

-(void)pkt_connectionFinishedLoading{
	[self willChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];
	finishedLoading = YES;
	[self  didChangeValueForKey:@"isFinished"];
	[self  didChangeValueForKey:@"isExecuting"];

	[delegate release], delegate = nil;
}

@end