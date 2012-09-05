//
//  pocketsdk_osx_unit_tests.m
//  pocketsdk.osx.unit-tests
//
//  Created by James Yopp on 9/4/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import "pocketsdk_osx_unit_tests.h"
#import "PocketAPI.h"
#import "PocketTestStatus.h"


@implementation pocketsdk_osx_unit_tests

- (void)setUp
{
    [super setUp];
    [[PocketAPI sharedAPI] setAPIKey:@"656g8u81p86b1z4fR5TbO39kH9AnXb33"];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}



- (void)testLogin
{
	PocketTestStatus *test = [[PocketTestStatus alloc] initWithName:NSStringFromSelector(_cmd)];
	[[PocketAPI sharedAPI] loginWithUsername:@"unit-tests"
									password:@"DRHftvHkY7MvM5ID7"
									 handler:^(PocketAPI *api, NSError *error) {
										 if (error) {
											 [test failedWithError:error];
										 } else {
											 [test succeeded];
										 }
									 }];
	[test waitUpTo:10.0];
	if (test.error || test.timedOut) {
		STFail(@"%@", test);
	} else {
		NSLog(@"Passed Test: %@", test);
	}
}

@end
