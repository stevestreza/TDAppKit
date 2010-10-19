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

#import "TDLine.h"

@implementation TDLine

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.mainColor = [NSColor darkGrayColor];
        self.nonMainColor = [NSColor grayColor];
    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.mainColor = nil;
    self.nonMainColor = nil;
    [super dealloc];
}


- (void)drawRect:(NSRect)dirtyRect {
    NSColor *color = [[self window] isMainWindow] ? mainColor : nonMainColor;
    [color set];
    //[[NSColor redColor] set];
    
    NSRect bounds = [self bounds];
    //NSPoint origin = bounds.origin;
    
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGPoint p1 = CGPointMake(0, 1.0);
    CGPoint p2 = CGPointMake(bounds.size.width, 1.0);
    //    CGPoint p1 = FakeAlignCGPointToUserSpace(ctx, CGPointMake(0, 1));
    //    CGPoint p2 = FakeAlignCGPointToUserSpace(ctx, CGPointMake(bounds.size.width, 1));
    
    CGContextSetLineWidth(ctx, 1.0);
    CGContextMoveToPoint(ctx, p1.x, p1.y);
    CGContextAddLineToPoint(ctx, p2.x, p2.y);
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    
    //    NSPoint p1 = FakeAlignNSPointToUserSpace(ctx, NSMakePoint(origin.x, origin.y + 1));
    //    NSPoint p2 = FakeAlignNSPointToUserSpace(ctx, NSMakePoint(origin.x + bounds.size.width, origin.y + 1));
    
    //    NSPoint p1 = NSMakePoint(0, 1);
    //    NSPoint p2 = NSMakePoint(bounds.size.width, 1);
    
    //    [NSBezierPath setDefaultLineWidth:.5];
    //    [NSBezierPath strokeLineFromPoint:p1 toPoint:p2];
}


- (void)awakeFromNib {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:[self window]];
    [nc addObserver:self selector:@selector(windowDidResignMain:) name:NSWindowDidResignMainNotification object:[self window]];        
}


- (void)windowDidBecomeMain:(NSNotification *)n {
    [self setNeedsDisplay:YES];
}


- (void)windowDidResignMain:(NSNotification *)n {
    [self setNeedsDisplay:YES];
}

@synthesize mainColor;
@synthesize nonMainColor;
@end
