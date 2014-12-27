//
//  PocketRSSParser.m
//  iOS Test App
//
//  Created by Michael Schneider
//  Copyright (c) 2014 Read It Later, Inc.
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

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC, add -fobjc-arc to its compiler flags in the Compile Sources build phase.
#endif

#import "PocketRSSParser.h"

NSString * const PocketRSSParserItemElementName = @"item";
NSString * const PocketRSSParserItemTitleName = @"title";
NSString * const PocketRSSParserItemLinkName = @"link";


#pragma mark - PocketRSSItem

@interface PocketRSSItem ()
@property (copy, nonatomic, readwrite) NSString *title;
@property (strong, nonatomic, readwrite) NSURL *url;
@end

@implementation PocketRSSItem

#pragma mark - Lifecycle

- (instancetype)initWithTitle:(NSString *)title url:(NSURL *)url
{
    self = [super init];
    if (self == nil) { return self; }
    _title = [title copy];
    _url = url;
    return self;
}


#pragma mark - Resolve URL

- (void)resolveURLCompletionHandler:(void(^)(void))completionHandler
{
    // Resolve feedburner url's
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
    request.HTTPMethod = @"HEAD";

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        self.url = httpResponse.URL;
        if (completionHandler) { completionHandler(); }
    }];
}

@end


#pragma mark - PocketRSSParser

@interface PocketRSSParser () <NSXMLParserDelegate>

@property (strong, nonatomic) NSURL *feedURL;
@property (strong, nonatomic) NSXMLParser *feedXMLParser;
@property (copy, nonatomic) void (^completionHandler)(PocketRSSParser *parser);

@property (strong, nonatomic) NSString *feedItemElement;
@property (strong, nonatomic) NSMutableString *feedItemTitle;
@property (strong, nonatomic) NSMutableString *feedItemLink;

@property (strong, nonatomic) NSMutableArray *feedEntries;
@end

@implementation PocketRSSParser


#pragma mark - Lifecycle

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self == nil) { return self; }
    _feedURL = url;
    return self;
}

#pragma mark - Getter / Setter

- (NSArray *)entries
{
    return [self.feedEntries copy];
}


#pragma mark - API

- (void)parseWithCompletionHandler:(void (^)(PocketRSSParser *parser))completionHandler
{
    NSAssert(self.feedURL != nil, @"Feed URL should not be nil");
    
    self.completionHandler = completionHandler;
    self.feedEntries = [NSMutableArray array];

    NSURLRequest *request = [NSURLRequest requestWithURL:self.feedURL];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        self.feedXMLParser = [[NSXMLParser alloc] initWithData:data];
        self.feedXMLParser.shouldResolveExternalEntities = NO;
        self.feedXMLParser.delegate = self;
        [self.feedXMLParser parse];
    }];

}


#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.feedItemElement = elementName;
    
    if ([self.feedItemElement isEqualToString:PocketRSSParserItemElementName]) {
        self.feedItemTitle = [NSMutableString new];
        self.feedItemLink = [NSMutableString new];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([self.feedItemElement isEqualToString:PocketRSSParserItemTitleName]) {
        [self.feedItemTitle appendString:string];
        return;
    }
    
    if ([self.feedItemElement isEqualToString:PocketRSSParserItemLinkName]) {
        [self.feedItemLink appendString:string];
        return;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:PocketRSSParserItemElementName]) {
        NSString *urlString = [self.feedItemLink stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        PocketRSSItem *item = [[PocketRSSItem alloc] initWithTitle:self.feedItemTitle url:[NSURL URLWithString:urlString]];
        [self.feedEntries addObject:item];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSUInteger numberOfFeedEntries = self.feedEntries.count;
    if (numberOfFeedEntries == 0) {
        [self finishParsing];
        return;
    }
 
    // Resolve all URL's before complete
    __block NSUInteger resolvedEntries = 0;
    [self.feedEntries enumerateObjectsUsingBlock:^(PocketRSSItem *item, NSUInteger idx, BOOL *stop) {
        [item resolveURLCompletionHandler:^{
            resolvedEntries += 1;
            if (resolvedEntries == numberOfFeedEntries) {
                [self finishParsing];
            }
        }];
    }];

}

- (void)finishParsing
{
    if (self.completionHandler) { self.completionHandler(self); }
    self.completionHandler = nil;
}

@end
