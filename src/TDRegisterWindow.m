//
//  TDRegisterWindow.m
//  Fluid
//
//  Created by Todd Ditchendorf on 4/30/11.
//  Copyright 2011 Todd Ditchendorf. All rights reserved.
//

#import "TDRegisterWindow.h"

@implementation TDRegisterWindow

#pragma mark -
#pragma mark NSDraggingDestination

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)dragInfo {
    NSAssert([dragInfo draggingDestinationWindow] == self, @"");
    return [[self windowController] draggingEntered:dragInfo];
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)dragInfo {
    NSAssert([dragInfo draggingDestinationWindow] == self, @"");
    return [[self windowController] performDragOperation:dragInfo];
}

@end
