//
//  PocketTestResult.m
//  Mac Test App
//
//  Created by James Yopp on 9/4/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import "PocketTestStatus.h"
#import <SenTestingKit/SenTestingKit.h>

@interface PocketTestStatus () {
	BOOL _completed;
}

@end

@implementation PocketTestStatus

- (id)initWithName:(NSString *)name {
	if ((self = [super init])) {
		_name = [name copy];
	}
	return self;
}

- (void) waitUpTo:(NSTimeInterval)timeout {
	NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
	do {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
		if ([timeoutDate timeIntervalSinceNow] < 0) {
			_timedOut = YES;
			break;
		}
	} while (!_completed);
}

- (void) failedWithError:(NSError *)error {
	_completed = YES;
	_error = error ?: [[NSError alloc] initWithDomain:@"Anonymous Test Failure" code:-1 userInfo:nil];
}

- (void) succeeded {
	_completed = YES;
}

- (NSString*)description {
	if (_error) {
		return [NSString stringWithFormat:@"Failed Test '%@': %@", _name, _error];
	} else if (_timedOut) {
		return [NSString stringWithFormat:@"Failed Test '%@': Timed Out", _name];
	} else {
		return [NSString stringWithFormat:@"Test '%@' (%@)", _name, _completed ? @"Succeeded" : @"Running"];
	}
}

@end
