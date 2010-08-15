//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <TDAppKit/NSURLRequest+TDAdditions.h>

@interface NSURLRequest (TDAdditionsPrivate)
- (NSDictionary *)queryStringValues;
- (NSDictionary *)bodyValues;
- (NSDictionary *)argsFromString:(NSString *)s;
@end

@implementation NSURLRequest (TDAdditions)

- (NSDictionary *)formValues {
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    
    NSDictionary *bodyValues = [self bodyValues];
    if (bodyValues) [d addEntriesFromDictionary:bodyValues];

    NSDictionary *queryStringValues = [self queryStringValues];
    if (queryStringValues) [d addEntriesFromDictionary:queryStringValues];
    
    return [[d copy] autorelease];
}

@end

@implementation NSURLRequest (TDAdditionsPrivate)

- (NSDictionary *)queryStringValues {
    NSString *URLString = [[self URL] query];
    if ([URLString hasPrefix:@"?"]) {
        URLString = [URLString substringFromIndex:1];
    }
    
    return [self argsFromString:URLString];
    
}

- (NSDictionary *)bodyValues {
//    NSMutableString *contentType = [NSMutableString stringWithString:[[self valueForHTTPHeaderField:@"Content-type"] lowercaseString]];
//    CFStringTrimWhitespace((CFMutableStringRef)contentType);
//
//    if ([contentType isEqualToString:@"application/x-www-form-urlencoded"]) {

    NSDictionary *bodyValues = nil;
    
    NSData *bodyData = [self HTTPBody];
        
    if ([bodyData length]) {
        NSString *body = [[[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding] autorelease];
        bodyValues = [self argsFromString:body];
    }
    
    return bodyValues;
}


- (NSDictionary *)argsFromString:(NSString *)s {
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    
    // text=foo&more=&password=&select=one
    NSArray *pairs = [s componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs) {
        NSRange r = [pair rangeOfString:@"="];
        if (NSNotFound != r.location) {
            NSString *name = [pair substringToIndex:r.location];
            NSString *value = [pair substringFromIndex:r.location + r.length];
            value = value ? value : @"";
            [d setObject:value forKey:name];
        }
    }

    return d;
}

@end
