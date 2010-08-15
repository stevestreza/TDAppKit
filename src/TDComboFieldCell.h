//
//  TDComboFieldCell.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 6/7/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TDComboFieldCell : NSTextFieldCell {
    NSImage *image;
}

- (NSRect)imageFrameForCellFrame:(NSRect)cellFrame;

// Dragging
- (NSImage *)imageForDraggingWithFrame:(NSRect)cellFrame inView:(NSView *)cv;
- (void)drawInteriorImageOnlyWithFrame:(NSRect)cellFrame inView:(NSView *)cv;

@property (nonatomic, retain) NSImage *image;
@end
