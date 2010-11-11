//
//  TDTabModel.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabModel.h>

@interface TDTabModel ()

@end

@implementation TDTabModel

+ (TDTabModel *)tabModelFromPlist:(NSDictionary *)plist {
    TDTabModel *m = [[[self alloc] init] autorelease];
    m.title = [plist objectForKey:@"title"];
    m.index = [[plist objectForKey:@"index"] integerValue];
    m.selected = [[plist objectForKey:@"selected"] boolValue];
    return m;
}


- (void)dealloc {
    self.representedObject = nil;
    self.image = nil;
    self.scaledImage = nil;
    self.title = nil;
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<TDTabModel %p %@>", self, title];
}


- (NSDictionary *)plist {
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:3];
    [d setObject:title forKey:@"title"];
    [d setObject:[NSNumber numberWithInteger:index] forKey:@"index"];
    [d setObject:[NSNumber numberWithInteger:selected] forKey:@"selected"];
    return d;
}


- (BOOL)wantsNewImage {
    if (needsNewImage || !image) {
        needsNewImage = NO;
        return YES;
    }

    return NO;
}


- (void)setNeedsNewImage:(BOOL)yn {
    needsNewImage = yn;
}

@synthesize representedObject;
@synthesize image;
@synthesize scaledImage;
@synthesize title;
@synthesize index;
@synthesize selected;
@end
