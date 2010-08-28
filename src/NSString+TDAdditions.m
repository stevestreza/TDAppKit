//
//  NSString+TDAdditions.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 7/11/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/NSString+TDAdditions.h>

@implementation NSString (TDAdditions)

- (NSString *)stringByCollapsingWhitespace {
    NSArray *comps = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSMutableString *ms = [NSMutableString stringWithCapacity:[self length]];
    for (NSString *s in comps) {
        if ([s length]) {
            [ms appendFormat:@"%@ ", s];
        }
    }
    
    if ([ms hasSuffix:@" "]) {
        [ms replaceCharactersInRange:NSMakeRange([ms length] - 1, 1) withString:@""];
    }
    
    return [[ms copy] autorelease];
}


- (NSString *)stringByReplacingWhitespaceWithStars {
    NSArray *comps = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSMutableString *ms = [NSMutableString stringWithCapacity:[self length]];
    for (NSString *s in comps) {
        if ([s length]) {
            [ms appendFormat:@"%@*", s];
        }
    }
    
    if ([ms hasSuffix:@"*"]) {
        [ms replaceCharactersInRange:NSMakeRange([ms length] - 1, 1) withString:@""];
    }
    
    return [[ms copy] autorelease];
}


- (NSString *)stringByTrimmingFirstAndLastChars {
    NSUInteger len = [self length];
    
    if (len < 2) {
        return self;
    }
    
    NSRange r = NSMakeRange(0, len);
    
    unichar c = [self characterAtIndex:0];
    if (!isalnum(c)) {
        unichar quoteChar = c;
        r.location = 1;
        r.length -= 1;
        
        c = [self characterAtIndex:len - 1];
        if (c == quoteChar) {
            r.length -= 1;
        }
        return [self substringWithRange:r];
    } else {
        return self;
    }
}

@end
