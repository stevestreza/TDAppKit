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

#import <TDAppKit/TDDraggableBar.h>

@implementation TDDraggableBar

// click thru support
- (BOOL)acceptsFirstMouse:(NSEvent *)evt {
    return YES;
}


// click thru support
- (BOOL)shouldDelayWindowOrderingForEvent:(NSEvent *)evt {
    return NO;
}


- (void)mouseDown:(NSEvent *)evt {
    NSPoint startLoc = [evt locationInWindow];
    
    NSPoint lastLoc = startLoc;

    BOOL keepDragging = YES;
    
    while (keepDragging) {
        evt = [[self window] nextEventMatchingMask:NSLeftMouseUpMask|NSLeftMouseDraggedMask|NSPeriodicMask];
        
        if ([evt type] == NSLeftMouseUp) {
            keepDragging = NO;
        }
		
        NSPoint newLoc = [evt locationInWindow];
        if (NSEqualPoints(newLoc, lastLoc)) {
            continue;
        }
		
        NSRect winFrame = [[self window] frame];
        NSPoint origin = winFrame.origin;
		NSPoint newOrigin = NSMakePoint(origin.x + newLoc.x - startLoc.x, origin.y + newLoc.y - startLoc.y);
		
        [[self window] setFrameOrigin:newOrigin];
        lastLoc = newLoc;
    }
}

@end
