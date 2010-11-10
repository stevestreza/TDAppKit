//
//  TDTabListItem.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabListItem.h>
#import <TDAppKit/TDTabModel.h>
//#import "FUTabsViewController.h"
#import <TDAppKit/TDUtils.h>
#import <TDAppKit/NSImage+TDAdditions.h>
//#import <Fluidium/FUUtils.h>
//#import <Fluidium/FUWindowController.h>

#define NORMAL_RADIUS 4
#define SMALL_RADIUS 3
#define BGCOLOR_INSET 2
#define THUMBNAIL_DIFF 0

static NSDictionary *sSelectedTitleAttrs = nil;
static NSDictionary *sTitleAttrs = nil;

static NSGradient *sSelectedOuterRectFillGradient = nil;
static NSGradient *sInnerRectFillGradient = nil;

static NSColor *sSelectedOuterRectStrokeColor = nil;

static NSColor *sSelectedInnerRectStrokeColor = nil;
static NSColor *sInnerRectStrokeColor = nil;

static NSImage *sProgressImage = nil;

@interface NSImage (TDTabAdditions)
- (NSImage *)scaledImageOfSize:(NSSize)size alpha:(CGFloat)alpha hiRez:(BOOL)hiRez cornerRadius:(CGFloat)radius progress:(CGFloat)progress;
- (NSImage *)scaledImageOfSize:(NSSize)size alpha:(CGFloat)alpha hiRez:(BOOL)hiRez clip:(NSBezierPath *)path progress:(CGFloat)progress;
@end

@implementation NSImage (TDTabAdditions)

- (NSImage *)scaledImageOfSize:(NSSize)size alpha:(CGFloat)alpha hiRez:(BOOL)hiRez cornerRadius:(CGFloat)radius progress:(CGFloat)progress {
    NSBezierPath *path = TDGetRoundRect(NSMakeRect(0, 0, size.width, size.height), radius, 1);
    return [self scaledImageOfSize:size alpha:alpha hiRez:hiRez clip:path progress:progress];
}


- (NSImage *)scaledImageOfSize:(NSSize)size alpha:(CGFloat)alpha hiRez:(BOOL)hiRez clip:(NSBezierPath *)path progress:(CGFloat)progress {
    NSImage *result = [[[NSImage alloc] initWithSize:size] autorelease];
    [result lockFocus];
    
    // get context
    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    
    // store previous state
    BOOL savedAntialias = [currentContext shouldAntialias];
    NSImageInterpolation savedInterpolation = [currentContext imageInterpolation];
    
    // set new state
    [currentContext setShouldAntialias:YES];
    [currentContext setImageInterpolation:hiRez ? NSImageInterpolationHigh : NSImageInterpolationDefault];
    
    // set clip
    [path setClip];
    
    // draw image
    NSSize fromSize = [self size];
    [self drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:NSMakeRect(0, 0, fromSize.width, fromSize.height) operation:NSCompositeSourceOver fraction:alpha];
    
    fromSize = [sProgressImage size];
    [sProgressImage drawInRect:NSMakeRect(0, 0, size.width * progress, size.height) fromRect:NSMakeRect(0, 0, fromSize.width, fromSize.height) operation:NSCompositeSourceOver fraction:.5];
    
    // restore state
    [currentContext setShouldAntialias:savedAntialias];
    [currentContext setImageInterpolation:savedInterpolation];
    
    [result unlockFocus];
    return result;
}

@end

@interface TDTabListItem ()
- (NSImage *)imageNamed:(NSString *)name scaledToSize:(NSSize)size;
- (void)startObserveringModel:(TDTabModel *)m;
- (void)stopObserveringModel:(TDTabModel *)m;

- (void)startDrawHiRezTimer;
- (void)drawHiRezTimerFired:(NSTimer *)t;
- (void)killDrawHiRezTimer;

@property (nonatomic, retain) NSTimer *drawHiRezTimer;
@end

@implementation TDTabListItem

+ (void)initialize {
    if ([TDTabListItem class] == self) {
        
        NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        [paraStyle setAlignment:NSLeftTextAlignment];
        [paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        
        NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
        [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0 alpha:.4]];
        [shadow setShadowOffset:NSMakeSize(0, -1)];
        [shadow setShadowBlurRadius:0];
        
        sSelectedTitleAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSFont boldSystemFontOfSize:10], NSFontAttributeName,
                               [NSColor whiteColor], NSForegroundColorAttributeName,
                               paraStyle, NSParagraphStyleAttributeName,
                               shadow, NSShadowAttributeName,
                               nil];
        
        sTitleAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
                       [NSFont boldSystemFontOfSize:10], NSFontAttributeName,
                       [NSColor colorWithDeviceWhite:.3 alpha:1], NSForegroundColorAttributeName,
                       paraStyle, NSParagraphStyleAttributeName,
                       nil];
        
        // outer round rect fill
        NSColor *fillTopColor = [NSColor colorWithDeviceRed:134.0/255.0 green:147.0/255.0 blue:169.0/255.0 alpha:1.0];
        NSColor *fillBottomColor = [NSColor colorWithDeviceRed:108.0/255.0 green:120.0/255.0 blue:141.0/255.0 alpha:1.0];
        sSelectedOuterRectFillGradient = [[NSGradient alloc] initWithStartingColor:fillTopColor endingColor:fillBottomColor];
        
        sInnerRectFillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:[NSColor whiteColor]];
        
        // outer round rect stroke
        sSelectedOuterRectStrokeColor = [[NSColor colorWithDeviceRed:91.0/255.0 green:100.0/255.0 blue:115.0/255.0 alpha:1.0] retain];
        
        // inner round rect stroke
        sSelectedInnerRectStrokeColor = [[sSelectedOuterRectStrokeColor colorWithAlphaComponent:.8] retain];
        sInnerRectStrokeColor = [[NSColor colorWithDeviceWhite:.7 alpha:1] retain];
        
        sProgressImage = [[NSImage imageNamed:@"progress_indicator.png" inBundleForClass:self] retain];
    }
}


+ (CGFloat)defaultHeight {
    return 10.0;
}


+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self);
}


- (id)init {
    return [self initWithFrame:NSZeroRect reuseIdentifier:[[self class] reuseIdentifier]];
}


- (id)initWithFrame:(NSRect)frame reuseIdentifier:(NSString *)s {
    if (self = [super initWithFrame:frame reuseIdentifier:s]) {
        self.closeButton = [[[NSButton alloc] initWithFrame:NSMakeRect(7, 5, 10, 10)] autorelease];
        [closeButton setButtonType:NSMomentaryChangeButton];
        [closeButton setBordered:NO];
        //[closeButton setAction:@selector(closeTabButtonClick:)];
        
        NSSize imgSize = NSMakeSize(10, 10);
        [closeButton setImage:[self imageNamed:@"close_button" scaledToSize:imgSize]];
        [closeButton setAlternateImage:[self imageNamed:@"close_button_pressed" scaledToSize:imgSize]];
        [self addSubview:closeButton];
        
        //        self.progressIndicator = [[[NSProgressIndicator alloc] initWithFrame:NSZeroRect] autorelease];
        //        [progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
        //        [progressIndicator setControlSize:NSSmallControlSize];
        //        [progressIndicator setDisplayedWhenStopped:NO];
        //        [progressIndicator setIndeterminate:YES];
        //        [progressIndicator sizeToFit];
        //        [self addSubview:progressIndicator];
    }
    return self;
}


- (void)dealloc {
    [self killDrawHiRezTimer];
    
    self.tabModel = nil;
    self.closeButton = nil;
    self.progressIndicator = nil;
    //self.viewController = nil;
    self.drawHiRezTimer = nil;
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p %@>", NSStringFromClass([self class]), self, tabModel.title];
}


#pragma mark -
#pragma mark Events

- (void)drawHiRezLater {
    //NSLog(@"%s YES %@", __PRETTY_FUNCTION__, tabModel);
    drawHiRez = NO;
    [self startDrawHiRezTimer];
}


- (void)drawRect:(NSRect)dirtyRect {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, tabModel);
    [closeButton setTag:tabModel.index];
    //[closeButton setTarget:viewController];
    
    NSRect bounds = [self bounds];
    
    // outer round rect
    if (bounds.size.width < 24.0) return; // dont draw anymore when you're really small. looks bad.
    
    NSRect roundRect = NSInsetRect(bounds, 2.5, 1.5);
    
    if (tabModel.isSelected) {
        CGFloat radius = (bounds.size.width < 32) ? SMALL_RADIUS : NORMAL_RADIUS;
        TDDrawRoundRect(roundRect, radius, 1, sSelectedOuterRectFillGradient, sSelectedOuterRectStrokeColor);
    }
    
    // title
    if (bounds.size.width < 40.0) return; // dont draw anymore when you're really small. looks bad.
    
    NSRect titleRect = NSInsetRect(roundRect, 11, 2);
    titleRect.origin.x += 8; // make room for close button
    titleRect.size.height = 13;
    NSUInteger opts = NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary *attrs = tabModel.isSelected ? sSelectedTitleAttrs : sTitleAttrs;
    [tabModel.title drawWithRect:titleRect options:opts attributes:attrs];
    
    // inner round rect
    if (bounds.size.width < 55.0) return; // dont draw anymore when you're really small. looks bad.
    
    roundRect = NSInsetRect(roundRect, 4, 4);
    roundRect = NSOffsetRect(roundRect, 0, 12);
    roundRect.size.height -= 10;
    
    NSSize imgSize = roundRect.size;
    imgSize.width = floor(imgSize.width - THUMBNAIL_DIFF);
    imgSize.height = floor(imgSize.height - THUMBNAIL_DIFF);
    
    NSImage *img = tabModel.scaledImage;
    if (!img || !NSEqualSizes(imgSize, [img size])) {
        CGFloat alpha = 1;
        BOOL hiRez = YES;
        if (/*!drawHiRez || */tabModel.isLoading) {
            //alpha = .4;
            hiRez = NO;
        }
        
        [tabModel.image setFlipped:[self isFlipped]];
        
        img = [tabModel.image scaledImageOfSize:imgSize alpha:alpha hiRez:hiRez cornerRadius:NORMAL_RADIUS progress:tabModel.estimatedProgress];
        tabModel.scaledImage = img;
    }
    
    imgSize = [img size];
    
    // draw image
    if (bounds.size.width < 64.0) return; // dont draw anymore when you're really small. looks bad.
    
    // put white behind the image
    NSColor *strokeColor = tabModel.isSelected ? sSelectedInnerRectStrokeColor : sInnerRectStrokeColor;
    TDDrawRoundRect(roundRect, NORMAL_RADIUS, 1, sInnerRectFillGradient, strokeColor);
    
    if (!img) {
        return;
    }
    
    NSRect srcRect = NSMakeRect(0, 0, imgSize.width, imgSize.height);
    NSRect destRect = NSOffsetRect(srcRect, floor(roundRect.origin.x + THUMBNAIL_DIFF/2), floor(roundRect.origin.y + THUMBNAIL_DIFF/2));
    [img drawInRect:destRect fromRect:srcRect operation:NSCompositeSourceOver fraction:1];
    
    // stroke again over image
    TDDrawRoundRect(roundRect, NORMAL_RADIUS, 1, nil, strokeColor);
    
    //    if (tabModel.isLoading) {
    //        [progressIndicator setFrameOrigin:NSMakePoint(NSMaxX(bounds) - 26, 20)];
    //        [progressIndicator startAnimation:self];
    //    } else {
    //        [progressIndicator stopAnimation:self];
    //    }
    //    [progressIndicator setNeedsDisplay:YES];
    [closeButton setNeedsDisplay:YES];
    
    drawHiRez = NO; // reset
}


- (void)setTabModel:(TDTabModel *)m {
    if (m != tabModel) {
        [self willChangeValueForKey:@"tabModel"];
        [self stopObserveringModel:tabModel];
        
        [tabModel autorelease];
        tabModel = [m retain];
        
        [self startObserveringModel:tabModel];
        [self didChangeValueForKey:@"tabModel"];
    }
}


#pragma mark -
#pragma mark Private

- (NSImage *)imageNamed:(NSString *)name scaledToSize:(NSSize)size {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForImageResource:name];
    return [[[[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]] autorelease] scaledImageOfSize:size];
}


- (void)startObserveringModel:(TDTabModel *)m {
    if (m) {
        [m addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];
        [m addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    }
}


- (void)stopObserveringModel:(TDTabModel *)m {
    if (m) {
        [m removeObserver:self forKeyPath:@"image"];
        [m removeObserver:self forKeyPath:@"title"];
    }
}


- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)obj change:(NSDictionary *)change context:(void *)ctx {
    if (obj == tabModel) {
        [self setNeedsDisplay:YES];
    }
}


- (void)startDrawHiRezTimer {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, tabModel);
    [self killDrawHiRezTimer];
    self.drawHiRezTimer = [NSTimer scheduledTimerWithTimeInterval:.3 target:self selector:@selector(drawHiRezTimerFired:) userInfo:nil repeats:NO];
}


- (void)drawHiRezTimerFired:(NSTimer *)t {
    if ([drawHiRezTimer isValid]) {
        //NSLog(@"%s %@", __PRETTY_FUNCTION__, tabModel);
        drawHiRez = YES;
        [super setNeedsDisplay:YES]; // call super to avoid setting flag
    }
}


- (void)killDrawHiRezTimer {
    [drawHiRezTimer invalidate];
    self.drawHiRezTimer = nil;
}

@synthesize tabModel;
@synthesize closeButton;
@synthesize progressIndicator;
//@synthesize viewController;
@synthesize drawHiRezTimer;
@end
