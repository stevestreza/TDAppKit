//
//  WebScriptObject+TDAdditions.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 9/16/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/WebScriptObject+TDAdditions.h>

@implementation WebScriptObject (TDAdditions)

- (NSMutableArray *)asMutableArray {
    NSUInteger count = 0;
    if ([self respondsToSelector:@selector(length)]) {
        count = [(DOMNodeList *)self length];
    } else {
        count = [[self valueForKey:@"length"] unsignedIntegerValue];
    }
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    
    NSUInteger i = 0;
    for ( ; i < count; i++) {
        [result addObject:[self webScriptValueAtIndex:i]];
    }
    
    return result;
}


- (NSArray *)asArray {
    return [[[self asMutableArray] copy] autorelease];
}

@end
