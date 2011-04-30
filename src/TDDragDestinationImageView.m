//
//  TDDragDestinationImageView.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 4/30/11.
//  Copyright 2011 Todd Ditchendorf. All rights reserved.
//

#import "TDDragDestinationImageView.h"

@implementation TDDragDestinationImageView

#pragma mark -
#pragma mark NSDraggingDestination

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)dragInfo {
    NSAssert([dragInfo draggingDestinationWindow] == [self window], @"");
    return [[[self window] windowController] draggingEntered:dragInfo];
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)dragInfo {
    NSAssert([dragInfo draggingDestinationWindow] == [self window], @"");
    return [[[self window] windowController] performDragOperation:dragInfo];
}

@end
