//
//  TDComboFieldCell.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 6/7/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDComboFieldCell.h"
#import "TDComboFieldTextView.h"
#import <TDAppKit/TDComboField.h>

#define IMAGE_MARGIN 2.0

@implementation TDComboFieldCell

#if FU_BUILD_TARGET_SNOW_LEOPARD
// for snow leopard
- (NSTextView *)fieldEditorForView:(NSView *)cv {
    if ([cv isMemberOfClass:[TDComboField class]]) {
        return [(TDComboField *)cv fieldEditor];
    } else {
        return [super fieldEditorForView:cv];
    }
}
#endif

//--------------------------------------------------------------//
#pragma mark -- Initialize --
//--------------------------------------------------------------//

- (id)initImageCell:(NSImage *)img {
    if (self = [super init]) {
        
    }
    return self;
}


- (id)initTextCell:(NSString *)s {
    if (self = [super init]) {
        
    }
    return self;
}


- (void)dealloc {
    self.image = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    TDComboFieldCell *cell = (TDComboFieldCell *)[super copyWithZone:zone];
    cell->image = [image retain];
    return cell;
}


- (BOOL)drawsBackground {
    return NO;
}

//--------------------------------------------------------------//
#pragma mark -- Working with image --
//--------------------------------------------------------------//

- (void)setImage:(NSImage *)img {
    if (image != img) {
        [image autorelease];
        image = [img retain];
        
        [[self controlView] setNeedsDisplay:YES];
    }
}


- (NSRect)imageFrameForCellFrame:(NSRect)cellFrame {
    if (image) {
        NSRect imageFrame;
        imageFrame.size = [image size];
        imageFrame.origin = cellFrame.origin;
        imageFrame.origin.x += 3;
        imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
        return imageFrame;
    } else {
        return NSZeroRect;
    }
}


#pragma mark -
#pragma mark Editing

- (void)selectWithFrame:(NSRect)rect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)object start:(NSInteger)selStart length:(NSInteger)selLength {
    // Divide frame
    NSRect textFrame, imageFrame, buttonFrame;
    if (image) {
        NSDivideRect(rect, &imageFrame, &textFrame, IMAGE_MARGIN + [image size].width, NSMinXEdge);
    } else {
        textFrame = rect;
        imageFrame = NSZeroRect;
    }
    
    buttonFrame = [(TDComboField*)controlView buttonFrame];
    textFrame.size.width -= buttonFrame.size.width + 2;
    
    [super selectWithFrame:textFrame 
                    inView:controlView 
                    editor:textObj 
                  delegate:object 
                     start:selStart 
                    length:selLength];
}


- (void)editWithFrame:(NSRect)rect inView:(NSView *)controlView editor:(NSText*)textObj delegate:(id)object event:(NSEvent *)event {
    // Divide frame
    NSRect  textFrame, imageFrame, buttonFrame;
    if (image) {
        NSDivideRect(rect, &imageFrame, &textFrame, IMAGE_MARGIN + [image size].width, NSMinXEdge);
    } else {
        textFrame = rect;
        imageFrame = NSZeroRect;
    }
    
    buttonFrame = [(TDComboField *)controlView buttonFrame];
    textFrame.size.width -= buttonFrame.size.width + 2;
    
    [super editWithFrame:textFrame 
                  inView:controlView 
                  editor:textObj 
                delegate:object 
                   event:event];
}

//--------------------------------------------------------------//
#pragma mark -- Drawing --
//--------------------------------------------------------------//

- (void)drawInteriorWithFrame:(NSRect)cellFrame 
                       inView:(NSView*)controlView
{
    // Draw image
    if (image) {
        NSSize    imageSize;
        NSRect    imageFrame;
        
        imageSize = [image size];
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, 
                     IMAGE_MARGIN + imageSize.width, NSMinXEdge);
        imageFrame.origin.x += 3;
        imageFrame.size = imageSize;
        imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
        if ([self drawsBackground]) {
            [[self backgroundColor] set];
            NSRectFill(imageFrame);
        }
        
        imageFrame.origin.y = cellFrame.origin.y;
        if ([controlView isFlipped]) {
            imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2);
        }
        else {
            imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
        }
        
        [image compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
    }
    
    // Draw text
    [super drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorImageOnlyWithFrame:(NSRect)cellFrame 
                                inView:(NSView*)controlView
{
    // Draw image
    if (image) {
        NSSize    imageSize;
        NSRect    imageFrame;
        
        imageSize = [image size];
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, 
                     IMAGE_MARGIN + imageSize.width, NSMinXEdge);
        imageFrame.origin.x += 3;
        imageFrame.size = imageSize;
        imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
        // TODD removing this
        //        if ([self drawsBackground]) {
        //            [[self backgroundColor] set];
        //            NSRectFill(imageFrame);
        //        }
        
        imageFrame.origin.y = cellFrame.origin.y;
        if ([controlView isFlipped]) {
            imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2);
        }
        else {
            imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
        }
        
        [image compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
    }
    
    // Draw text
    //    [super drawInteriorWithFrame:cellFrame inView:controlView];
}

- (NSSize)cellSize
{
    NSSize cellSize = [super cellSize];
    cellSize.width += (image ? [image size].width : 0) + IMAGE_MARGIN;
    return cellSize;
}

- (void)_drawFocusRingWithFrame:(NSRect)rect
{
    if (image) {
        rect.origin.x -= [image size].width + IMAGE_MARGIN;
        rect.size.width += [image size].width + IMAGE_MARGIN;
    }
    
    NSRect  buttonFrame;
    buttonFrame = [(TDComboField*)[self controlView] buttonFrame];
    if (buttonFrame.size.width > 0) {
        rect.size.width += buttonFrame.size.width + 2;
    }
    
//    rect = NSInsetRect(rect, 1.0, 1.0);
//    [super _drawFocusRingWithFrame:rect];
}

//--------------------------------------------------------------//
#pragma mark -- Dragging --
//--------------------------------------------------------------//

- (NSImage*)imageForDraggingWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
    // Create image
    NSImage*    img;
    img = [[NSImage alloc] initWithSize:cellFrame.size];
    [img autorelease];
    
    // Create attributed string
    NSMutableAttributedString*  attrStr;
    float                       alpha = 0.7f;
    attrStr = [[NSMutableAttributedString alloc] 
               initWithAttributedString:[self attributedStringValue]];
    [attrStr autorelease];
    [attrStr addAttribute:NSForegroundColorAttributeName 
                    value:[NSColor colorWithCalibratedWhite:0.0f alpha:alpha] 
                    range:NSMakeRange(0, [attrStr length])];
    
    // Draw cell
    [img lockFocus];
    [img dissolveToPoint:NSZeroPoint fraction:alpha];
    [attrStr drawAtPoint:NSMakePoint([img size].width + IMAGE_MARGIN, 0.0f)];
    [img unlockFocus];
    
    return img;
}

- (BOOL)imageTrackMouse:(NSEvent*)event 
                 inRect:(NSRect)cellFrame 
                 ofView:(NSView*)controlView 
{
    // Check mouse is in image or not
    NSRect  imageFrame;
    NSPoint point;
    
    imageFrame = [self imageFrameForCellFrame:cellFrame];
    
    point = [controlView convertPoint:[event locationInWindow] fromView:nil];
    
    if (NSPointInRect(point, imageFrame)) {        
        return YES;
    }
    
    return NO;
}

- (void)resetCursorRect:(NSRect)cellFrame 
                 inView:(NSView*)controlView
{
    NSRect  textFrame;
    NSRect  imageFrame;
    NSDivideRect(
                 cellFrame, &imageFrame, &textFrame, IMAGE_MARGIN + [image size].width, NSMinXEdge);
    [super resetCursorRect:textFrame inView:controlView];
}



@synthesize image;
@end
