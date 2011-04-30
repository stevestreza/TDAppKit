//
//  TDHintView.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/11/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDHintView.h>
#import <TDAppKit/TDUtils.h>

#define HINT_MIN_WIDTH 100.0
#define HINT_MAX_WIDTH 400.0

#define HINT_HEIGHT 42.0
#define HINT_MARGIN_X 20.0
#define HINT_PADDING_X 22.0
#define HINT_PADDING_Y 4.0

#define HINT_VERT_FUDGE 0.0

static NSColor *sHintBgColor = nil;
static NSDictionary *sHintAttrs = nil;

@implementation TDHintView

+ (void)initialize {
    if ([TDHintView class] == self) {
        
        //[[NSColor colorWithDeviceWhite:.87 alpha:1] set];
        //[[NSColor colorWithDeviceRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1] set];
        
        sHintBgColor = [[NSColor colorWithDeviceWhite:.68 alpha:1] retain];
        
        NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        [paraStyle setAlignment:NSCenterTextAlignment];
        [paraStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
        [shadow setShadowColor:[NSColor colorWithDeviceWhite:0 alpha:.2]];
        [shadow setShadowOffset:NSMakeSize(0, -1)];
        [shadow setShadowBlurRadius:1];
        
        sHintAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
                      [NSFont boldSystemFontOfSize:12], NSFontAttributeName,
                      [NSColor whiteColor], NSForegroundColorAttributeName,
                      shadow, NSShadowAttributeName,
                      paraStyle, NSParagraphStyleAttributeName,
                      nil];
    }
}


- (void)dealloc {
    self.hintText = nil;
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p '%@'>", [self class], self, hintText];
}


- (NSRect)hintTextRectForBounds:(NSRect)bounds {
    CGFloat w = bounds.size.width - HINT_MARGIN_X * 2 - HINT_PADDING_X * 2;
    w = w < HINT_MIN_WIDTH ? HINT_MIN_WIDTH : w;
    
    NSRect strRect = [hintText boundingRectWithSize:NSMakeSize(w, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:sHintAttrs];

    CGFloat h = strRect.size.height;
    CGFloat x = HINT_MARGIN_X + HINT_PADDING_X;
    CGFloat y = bounds.size.height / 2 - strRect.size.height / 2 + HINT_VERT_FUDGE;
    y += hintTextOffsetY;

    NSRect r = NSMakeRect(x, y, w, h);
    return r;
}


- (void)drawRect:(NSRect)dirtyRect {
    NSRect bounds = [self bounds];
    
    [self.color setFill];
    NSRectFill(bounds);
    
    BOOL showHint = ([hintText length]);
    if (showHint) {
        NSRect hintTextRect = [self hintTextRectForBounds:bounds];
        
        NSRect hintRect = NSInsetRect(hintTextRect, -HINT_PADDING_X, -HINT_PADDING_Y);
        
        CGFloat w = hintRect.size.width;
        w = w > HINT_MAX_WIDTH ? HINT_MAX_WIDTH : w;
        hintRect.size.width = floor(w);
        
        CGFloat x = bounds.size.width / 2 -  hintRect.size.width / 2;
        x = x < HINT_MARGIN_X ? HINT_MARGIN_X : x;
        hintRect.origin.x = floor(x);
        
        hintRect.origin.y = floor(hintRect.origin.y);
        hintRect.size.height = floor(hintRect.size.height);
        CGFloat radius = hintRect.size.height / 2 - 2;
        
        [sHintBgColor setFill];
        
        CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
        TDAddRoundRect(ctx, NSRectToCGRect(hintRect), radius);
        CGContextFillPath(ctx);
        
        [[NSColor whiteColor] set];
        [hintText drawInRect:hintTextRect withAttributes:sHintAttrs];
    }
}

@synthesize hintText;
@synthesize hintTextOffsetY;
@end
