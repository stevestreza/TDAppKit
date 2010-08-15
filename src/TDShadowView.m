//
//  TDComboFieldListShadowView.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 4/16/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDShadowView.h"
#import <NSBezierPath+TDAdditions.h>

#define SHADOW_RADIUS 10
#define RADIUS 3.0

static NSShadow *sShadow = nil;

@implementation TDShadowView

+ (void)initialize {
    if ([TDShadowView class] == self) {
        sShadow = [[NSShadow alloc] init];
        [sShadow setShadowOffset:NSMakeSize(0, -10)];
        [sShadow setShadowBlurRadius:SHADOW_RADIUS];
        [sShadow setShadowColor:[NSColor colorWithDeviceWhite:0 alpha:.6]];
    }
}


- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setAlphaValue:.8];
    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}


- (BOOL)isFlipped {
    return YES;
}


- (void)drawRect:(NSRect)dirtyRect {
    NSRect bounds = [self bounds];

    //[[NSColor clearColor] set];
    //NSRectFill(bounds);
    
    [sShadow set];
    [[NSColor colorWithDeviceWhite:1 alpha:.8] setFill];
    
    NSRect r = NSOffsetRect(bounds, 10, 0);
    r.size.width -= SHADOW_RADIUS * 2;
    r.size.height -= SHADOW_RADIUS * 2;
    //r = NSInsetRect(r, 20, 20);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundRect:r radius:RADIUS];
    [path fill];
}

@end
