//
//  TDTabModel.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabModel.h>

@interface TDTabModel ()
- (NSUInteger)incrementChangeCount;
@end

@implementation TDTabModel

+ (TDTabModel *)tabModelFromPlist:(NSDictionary *)plist {
    TDTabModel *m = [[[self alloc] init] autorelease];
    m.title = [plist objectForKey:@"title"];
    m.URLString = [plist objectForKey:@"URLString"];
    m.index = [[plist objectForKey:@"index"] integerValue];
    m.selected = [[plist objectForKey:@"selected"] boolValue];
    return m;
}


- (void)dealloc {
    self.image = nil;
    self.scaledImage = nil;
    self.title = nil;
    self.URLString = nil;
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<TDTabModel %p %@>", self, title];
}


- (NSDictionary *)plist {
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:3];
    [d setObject:title forKey:@"title"];
    [d setObject:URLString forKey:@"URLString"];
    [d setObject:[NSNumber numberWithInteger:index] forKey:@"index"];
    [d setObject:[NSNumber numberWithInteger:selected] forKey:@"selected"];
    return d;
}


- (NSUInteger)incrementChangeCount {
    return ++changeCount;
}


- (BOOL)wantsNewImage {
    if (needsNewImage || !image) {
        needsNewImage = NO;
        return YES;
    }
    
    [self incrementChangeCount];
    if (estimatedProgress > .9) {
        self.estimatedProgress = 1.0;
        return YES;
    } else {
        // only update web image every sixth notification
        return (0 == changeCount % 6);
    }
}


- (void)setNeedsNewImage:(BOOL)yn {
    needsNewImage = yn;
}

@synthesize image;
@synthesize scaledImage;
@synthesize title;
@synthesize URLString;
@synthesize index;
@synthesize estimatedProgress;
@synthesize loading;
@synthesize selected;
@end
