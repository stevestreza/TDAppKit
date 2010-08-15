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

@end
