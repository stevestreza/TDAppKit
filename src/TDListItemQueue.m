//  Copyright 2009 Todd Ditchendorf
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

#import "TDListItemQueue.h"
#import <TDAppKit/TDListItem.h>

@interface TDListItemQueue ()
@property (nonatomic, retain) NSMutableDictionary *dict;
@end

@implementation TDListItemQueue

- (id)init {
    if (self = [super init]) {
        self.dict = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)dealloc {
    self.dict = nil;
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<TDListItemQueue %p %@>", self, dict];
}


- (BOOL)enqueue:(TDListItem *)itemView {
    NSString *s = itemView.reuseIdentifier;
    
    if (![s length]) {
        return NO;
    }
    
    NSMutableSet *set = [dict objectForKey:s];
    if (!set) {
        set = [NSMutableSet set];
        [dict setObject:set forKey:s];
    }
    
    if ([set containsObject:itemView]) {
        return NO;
    } else {
        [set addObject:itemView];
        return YES;
    }
}


- (TDListItem *)dequeueWithIdentifier:(NSString *)s {
    TDListItem *rv = nil;
    
    NSMutableSet *set = [dict objectForKey:s];
    if (set) {
        NSAssert([set count], @"empty sets should be removed");
        rv = [[[set anyObject] retain] autorelease];
        [set removeObject:rv];
        
        if (![set count]) {
            [dict removeObjectForKey:s];
        }
    }
    
    return rv;
}


- (NSUInteger)count {
    NSUInteger c = 0;
    for (NSString *key in dict) {
        c += [[dict objectForKey:key] count];
    }
    return c;
}

@synthesize dict;
@end



