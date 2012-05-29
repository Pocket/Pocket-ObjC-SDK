//
//  PocketAPIOperation.h
//  PocketSDK
//
//  Created by Steve Streza on 5/29/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PocketAPI.h"

@interface PocketAPIOperation : NSOperation {
	PocketAPI *API;
	id<PocketAPIDelegate> delegate;
	
	NSString *method;
	NSDictionary *arguments;
}

@property (nonatomic, retain) PocketAPI *API	;
@property (nonatomic, assign) id<PocketAPIDelegate> delegate;

@property (nonatomic, retain) NSString *method;
@property (nonatomic, retain) NSDictionary *arguments;

@end
