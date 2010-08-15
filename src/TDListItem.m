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

#import <TDAppKit/TDListItem.h>

@interface TDListItem ()
@property (nonatomic, assign) NSUInteger index;
@end

@implementation TDListItem

- (id)initWithFrame:(NSRect)frame reuseIdentifier:(NSString *)s {
    if (self = [super initWithFrame:frame]) {
        self.reuseIdentifier = s;
    }
    return self;
}


- (void)dealloc {
    self.reuseIdentifier = nil;
    [super dealloc];
}


- (BOOL)isFlipped {
    return YES;
}


- (void)prepareForReuse {
    
}


- (NSImage *)draggingImage {
    NSRect r = [self bounds];
    NSBitmapImageRep *bitmap = [self bitmapImageRepForCachingDisplayInRect:r];
    [self cacheDisplayInRect:r toBitmapImageRep:bitmap];
    
    NSSize imgSize = [bitmap size];
    NSImage *img = [[[NSImage alloc] initWithSize:imgSize] autorelease];
    [img addRepresentation:bitmap];
    
    NSImage *result = [[[NSImage alloc] initWithSize:imgSize] autorelease];
    [result lockFocus];
    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    NSImageInterpolation savedInterpolation = [currentContext imageInterpolation];
    [currentContext setImageInterpolation:NSImageInterpolationHigh];
    [img drawInRect:NSMakeRect(0, 0, imgSize.width, imgSize.height) fromRect:NSMakeRect(0, 0, imgSize.width, imgSize.height) operation:NSCompositeSourceOver fraction:.5];
    [currentContext setImageInterpolation:savedInterpolation];
    [result unlockFocus];
    
    return result;
}

@synthesize reuseIdentifier;
@synthesize index;
@end
