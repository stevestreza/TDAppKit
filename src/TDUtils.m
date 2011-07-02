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

#import <TDAppKit/TDUtils.h>
#import <TDAppKit/NSBezierPath+TDAdditions.h>
#import <QuartzCore/QuartzCore.h>

NSBezierPath *TDGetRoundRect(NSRect r, CGFloat radius, CGFloat lineWidth) {
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundRect:r radius:radius];
    [path setLineWidth:lineWidth];
    return path;
    
//    CGFloat minX = NSMinX(r);
//    CGFloat midX = NSMidX(r);
//    CGFloat maxX = NSMaxX(r);
//    CGFloat minY = NSMinY(r);
//    CGFloat midY = NSMidY(r);
//    CGFloat maxY = NSMaxY(r);
//    
//    NSBezierPath *path = [NSBezierPath bezierPath];
//    [path setLineWidth:lineWidth];
//    [path moveToPoint:NSMakePoint(minX, midY)];
//    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX, minY) toPoint:NSMakePoint(midX, minY) radius:radius];
//    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) toPoint:NSMakePoint(maxX, midY) radius:radius];
//    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) toPoint:NSMakePoint(midX, maxY) radius:radius];
//    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) toPoint:NSMakePoint(minX, midY) radius:radius];
//    [path closePath];
//    
//    return path;
}


NSBezierPath *TDDrawRoundRect(NSRect r, CGFloat radius, CGFloat lineWidth, NSGradient *fillGradient, NSColor *strokeColor) {
    //    CGContextRef c = [[NSGraphicsContext currentContext] graphicsPort];
    //
    //    CGContextSetLineWidth(c, lineWidth);
    
    //    NSLog(@"before r: %@", NSStringFromRect(r));
    //    r = CGContextConvertRectToDeviceSpace(c, r);
    //    NSLog(@"after r: %@", NSStringFromRect(r));
    
    NSBezierPath *path = TDGetRoundRect(r, radius, lineWidth);
    [fillGradient drawInBezierPath:path angle:90.0];
    
    [strokeColor setStroke];
    [path stroke];
    
    return path;
    
    //    CGContextSetLineWidth(c, lineWidth);
    //    
    //    CGContextBeginPath(c);
    //    CGContextMoveToPoint(c, minX, midY);
    //    CGContextAddArcToPoint(c, minX, minY, midX, minY, radius);
    //    CGContextAddArcToPoint(c, maxX, minY, maxX, midY, radius);
    //    CGContextAddArcToPoint(c, maxX, maxY, midX, maxY, radius);
    //    CGContextAddArcToPoint(c, minX, maxY, minX, midY, radius);
    //    CGContextClosePath(c);
    //    CGContextDrawPath(c, kCGPathFillStroke);
}


void TDAddRoundRect(CGContextRef ctx, CGRect rect, CGFloat radius) {
    CGFloat minx = CGRectGetMinX(rect);
    CGFloat midx = CGRectGetMidX(rect);
    CGFloat maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect);
    CGFloat midy = CGRectGetMidY(rect);
    CGFloat maxy = CGRectGetMaxY(rect);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, minx, midy);
    CGContextAddArcToPoint(ctx, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(ctx, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(ctx, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(ctx, minx, maxy, minx, midy, radius);
    CGContextClosePath(ctx);
}


BOOL TDIsCommandKeyPressed(NSInteger modifierFlags) {
    NSInteger commandKeyWasPressed = (NSCommandKeyMask & modifierFlags);
    return [[NSNumber numberWithInteger:commandKeyWasPressed] boolValue];
}


BOOL TDIsControlKeyPressed(NSInteger modifierFlags) {
    NSInteger controlKeyWasPressed = (NSControlKeyMask & modifierFlags);
    return [[NSNumber numberWithInteger:controlKeyWasPressed] boolValue];
}


BOOL TDIsShiftKeyPressed(NSInteger modifierFlags) {
    NSInteger commandKeyWasPressed = (NSShiftKeyMask & modifierFlags);
    return [[NSNumber numberWithInteger:commandKeyWasPressed] boolValue];
}


BOOL TDIsOptionKeyPressed(NSInteger modifierFlags) {
    NSInteger commandKeyWasPressed = (NSAlternateKeyMask & modifierFlags);
    return [[NSNumber numberWithInteger:commandKeyWasPressed] boolValue];         
}


CGPoint TDAlignCGPointToUserSpace(CGContextRef ctx, CGPoint p) {
    p = CGContextConvertPointToDeviceSpace(ctx, p);
    p.x = floor(p.x);
    p.y = floor(p.y);
    p = CGContextConvertPointToUserSpace(ctx, p);
    return p;
}


NSPoint TDAlignPointToUserSpace(CGContextRef ctx, NSPoint p) {
    CGPoint cgpoint = NSPointToCGPoint(p);
    return NSPointFromCGPoint(TDAlignCGPointToUserSpace(ctx, cgpoint));
}


NSNib *TDLoadNib(id owner, NSString *nibName, NSBundle *bundle) {
    if (!bundle) {
        bundle = [NSBundle mainBundle];
    }
    NSNib *nib = [[[NSNib alloc] initWithNibNamed:nibName bundle:bundle] autorelease];
    if (![nib instantiateNibWithOwner:owner topLevelObjects:nil]) {
        NSLog(@"Could not load nib named %@", nibName);
        return nil;
    }
    return nib;
}

BOOL TDIsLionOrLater() {
    NSUInteger major, minor, bugfix;
    TDGetSystemVersion(&major, &minor, &bugfix);
    return minor > 6;
}


BOOL TDIsSnowLeopardOrLater() {
    NSUInteger major, minor, bugfix;
    TDGetSystemVersion(&major, &minor, &bugfix);
    return minor > 5;
}


void TDGetSystemVersion(NSUInteger *major, NSUInteger *minor, NSUInteger *bugfix) {
    OSErr err;
    SInt32 systemVersion, versionMajor, versionMinor, versionBugFix;
    if ((err = Gestalt(gestaltSystemVersion, &systemVersion)) != noErr) goto fail;
    if (systemVersion < 0x1040) {
        if (major) *major = ((systemVersion & 0xF000) >> 12) * 10 + ((systemVersion & 0x0F00) >> 8);
        if (minor) *minor = (systemVersion & 0x00F0) >> 4;
        if (bugfix) *bugfix = (systemVersion & 0x000F);
    } else {
        if ((err = Gestalt(gestaltSystemVersionMajor, &versionMajor)) != noErr) goto fail;
        if ((err = Gestalt(gestaltSystemVersionMinor, &versionMinor)) != noErr) goto fail;
        if ((err = Gestalt(gestaltSystemVersionBugFix, &versionBugFix)) != noErr) goto fail;
        if (major) *major = versionMajor;
        if (minor) *minor = versionMinor;
        if (bugfix) *bugfix = versionBugFix;
    }
    
    return;
    
fail:
    NSLog(@"Unable to obtain system version: %ld", (long)err);
    if (major) *major = 10;
    if (minor) *minor = 0;
    if (bugfix) *bugfix = 0;
}
