//
//  PocketAPIExtensionSafe.m
//  PocketSDK
//
//  Created by Michael Schneider on 5/22/15.
//  Copyright (c) 2015 Read It Later, Inc. All rights reserved.
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

#import "PocketAPIExtensionSafe.h"

@implementation NSBundle (PKTExtensionSafe)

+ (BOOL)pkt_isApplicationExtension
{
    return ([[[self mainBundle] executablePath] containsString:@".appex/"]);
}

@end

#if TARGET_OS_IPHONE
@implementation UIApplication (PKTExtensionSafe)

+ (instancetype)pkt_sharedApplication
{
    if ([NSBundle pkt_isApplicationExtension]) {
        return nil;
    }
    
    return [UIApplication performSelector:@selector(sharedApplication)];
}

- (BOOL)pkt_openURL:(NSURL *)URL
{
    return [self performSelector:@selector(openURL:) withObject:URL];
}

- (BOOL)pkt_canOpenURL:(NSURL *)URL
{
    return [self performSelector:@selector(canOpenURL:) withObject:URL];
}

@end
#endif