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

#import <TDAppKit/TDListView.h>
#import <TDAppKit/TDListItem.h>
#import <TDAppKit/TDScrollView.h>
#import <TDAppKit/NSEvent+TDAdditions.h>
#import "TDListItemQueue.h"

#define EXCEPTION_NAME @"TDListViewDataSourceException"
#define DEFAULT_ITEM_EXTENT 44
#define DRAG_RADIUS 22

NSString *const TDListItemPboardType = @"TDListItemPboardType";

@interface NSToolbarPoofAnimator
+ (void)runPoofAtPoint:(NSPoint)p;
@end

@interface TDListItem ()
@property (nonatomic, assign) NSUInteger index;
@end

@interface TDListView ()
- (void)setUp;
- (void)layoutItems;
- (void)layoutItemsWhileDragging;
- (void)updateSelectionWithEvent:(NSEvent *)evt index:(NSUInteger)i;
- (NSUInteger)indexForItemWhileDraggingAtPoint:(NSPoint)p;
- (TDListItem *)itemAtVisibleIndex:(NSUInteger)i;
- (NSUInteger)visibleIndexForItemAtPoint:(NSPoint)p;
- (TDListItem *)itemWhileDraggingAtIndex:(NSInteger)i;
- (void)draggingSourceDragDidEnd;
- (void)unsuppressLayout;
- (void)handleRightClickEvent:(NSEvent *)evt;
- (void)displayContextMenu:(NSTimer *)t;
- (void)handleDoubleClickAtIndex:(NSUInteger)i;
- (CGFloat)scrollFudgeExtent;

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSMutableArray *unusedItems;
@property (nonatomic, retain) TDListItemQueue *queue;
@property (nonatomic, retain) NSEvent *lastMouseDownEvent;
@property (nonatomic, retain) NSMutableArray *itemFrames;

@property (nonatomic, retain) NSIndexSet *draggingIndexes;
@property (nonatomic, retain) NSIndexSet *draggingVisibleIndexes;
@property (nonatomic, assign) NSPoint dragOffset;
@end

@implementation TDListView

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {        
        [self setUp];
    } 
    return self;
}


- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setUp];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.scrollView = nil;
    self.dataSource = nil;
    self.delegate = nil;
    self.backgroundColor = nil;
    self.items = nil;
    self.unusedItems = nil;
    self.queue = nil;
    self.lastMouseDownEvent = nil;
    self.itemFrames = nil;
    self.selectionIndexes = nil;
    self.draggingIndexes = nil;
    self.draggingVisibleIndexes = nil;
    [super dealloc];
}


//- (void)awakeFromNib {
//
//}


- (void)setUp {
    self.items = [NSMutableArray array];
    self.unusedItems = [NSMutableArray array];
    
    self.selectionIndexes = nil;
    anchorIndex = NSNotFound;

    self.backgroundColor = [NSColor whiteColor];
    self.itemExtent = DEFAULT_ITEM_EXTENT;
    
    self.queue = [[[TDListItemQueue alloc] init] autorelease];
    
    self.displaysClippedItems = YES;
    
    [self setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
    [self setDraggingSourceOperationMask:NSDragOperationNone forLocal:NO];    
}


#pragma mark -
#pragma mark Public

- (void)reloadData {
    [self layoutItems];
    [self setNeedsDisplay:YES];
}


- (TDListItem *)dequeueReusableItemWithIdentifier:(NSString *)s {
    TDListItem *item = [queue dequeueWithIdentifier:s];
    [item prepareForReuse];
    return item;
}


- (NSUInteger)visibleIndexForItemAtPoint:(NSPoint)p {
    NSUInteger i = 0;
    for (TDListItem *item in items) {
        if (NSPointInRect(p, [item frame])) {
            return i;
        }
        i++;
    }
    return NSNotFound;
}


- (NSUInteger)indexForItemAtPoint:(NSPoint)p {
    BOOL variableExtent = (delegate && [delegate respondsToSelector:@selector(listView:extentForItemAtIndex:)]);
    CGFloat n = 0;
    CGFloat w = NSWidth([self frame]);
    CGFloat h = NSHeight([self frame]);

    NSUInteger count = [dataSource numberOfItemsInListView:self];
    NSUInteger i = 0;
    for ( ; i < count; i++) {
        CGFloat extent = floor(variableExtent ? [delegate listView:self extentForItemAtIndex:i] : itemExtent);
        NSRect itemFrame;
        if (self.isPortrait) {
            itemFrame = NSMakeRect(0, n, w, extent);
        } else {
            itemFrame = NSMakeRect(n, 0, extent, h);
        }
        if (NSPointInRect(p, itemFrame)) {
            return i;
        }
        n += extent;
    }
    
    return NSNotFound;
}


- (TDListItem *)itemAtIndex:(NSUInteger)i {
    for (TDListItem *item in items) {
        if (item.index == i) {
            return item;
        }
    }
    return nil; //[dataSource listView:self itemAtIndex:i]; //[self itemAtVisibleIndex:i];
}


- (TDListItem *)itemAtVisibleIndex:(NSUInteger)i {
    if (i < 0 || i >= [items count]) return nil;
    
    return [items objectAtIndex:i];
}


- (NSRect)frameForItemAtIndex:(NSUInteger)i {
    CGFloat extent = 0;

    NSUInteger j = 0;
    for ( ; j < i; j++) {
        extent += [delegate listView:self extentForItemAtIndex:j];
    }
    
    CGFloat x, y, w, h;
    NSRect bounds = [self bounds];
    
    if (self.isPortrait) {
        x = 0; y = extent;
        w = bounds.size.width;
        h = [delegate listView:self extentForItemAtIndex:i];
    } else {
        x = extent; y = 0;
        w = [delegate listView:self extentForItemAtIndex:i];
        h = bounds.size.height;
    }
    NSRect r = NSMakeRect(x, y, w, h);
    return r;
}


- (void)setSelectionIndexes:(NSIndexSet *)set {
    if (set != selectionIndexes) {
        
        // dont consult delegate if we are deselecting
        if (set && delegate && [delegate respondsToSelector:@selector(listView:willSelectItemsAtIndexes:)]) {
            if (![[delegate listView:self willSelectItemsAtIndexes:set] count]) {
                return;
            }
        }
        
        [selectionIndexes autorelease];
        selectionIndexes = [set copy];
        
        // find anchor
        NSUInteger c = [selectionIndexes count];
        
        if (1 == c) {
            anchorIndex = [selectionIndexes firstIndex];
        } else if (0 == c) {
            anchorIndex = NSNotFound;
        }
        
        // reload
        [self reloadData];
        
        if (selectionIndexes && delegate && [delegate respondsToSelector:@selector(listView:didSelectItemsAtIndexes:)]) {
            [delegate listView:self didSelectItemsAtIndexes:set];
        }
    }
}


- (BOOL)isPortrait {
    return TDListViewOrientationPortrait == orientation;
}


- (BOOL)isLandscape {
    return TDListViewOrientationLandscape == orientation;
}


#pragma mark -
#pragma mark Notifications

- (void)viewBoundsChanged:(NSNotification *)n {
    // if this returns false, the view hierarchy is being torn down. 
    // don't try to layout in that case cuz it crashes on Leopard
    if ([[n object] superview] && dataSource) {
        [self layoutItems];
    }
}


#pragma mark -
#pragma mark NSView

- (void)viewWillMoveToSuperview:(NSView *)newSuperview {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    NSView *oldSuperview = [self superview];
    if (oldSuperview) {
        [nc removeObserver:self name:NSViewBoundsDidChangeNotification object:oldSuperview];
    }

    if (newSuperview) {
        [nc addObserver:self selector:@selector(viewBoundsChanged:) name:NSViewBoundsDidChangeNotification object:newSuperview];
    }
}


- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize {
    [self layoutItems];
}


- (BOOL)isFlipped {
    return YES;
}


- (BOOL)acceptsFirstResponder {
    return YES;
}


- (void)drawRect:(NSRect)dirtyRect {
    [backgroundColor set];
    NSRectFill(dirtyRect);
}


#pragma mark -
#pragma mark NSResponder

- (void)rightMouseUp:(NSEvent *)evt {
    [self handleRightClickEvent:evt];
}


- (void)mouseDown:(NSEvent *)evt {
    NSPoint locInWin = [evt locationInWindow];
    NSPoint p = [self convertPoint:locInWin fromView:nil];
    NSUInteger i = [self indexForItemAtPoint:p];
    NSUInteger visibleIndex = [self visibleIndexForItemAtPoint:p];

    // handle right click
    if ([evt isControlKeyPressed] && 1 == [evt clickCount]) {
        [self handleRightClickEvent:evt];
        return;
    } else if ([evt isDoubleClick]) {
        [self handleDoubleClickAtIndex:i];
        return;
    }
    
    BOOL isCopy = [evt isOptionKeyPressed] && (NSDragOperationCopy & [self draggingSourceOperationMaskForLocal:YES]);
    self.lastMouseDownEvent = evt;
    
    BOOL hasUpdatedSelection = NO;
    if (NSNotFound == i || ![self.selectionIndexes containsIndex:i]) {
        hasUpdatedSelection = YES;
        [self updateSelectionWithEvent:evt index:i];
    }
    
    // this adds support for click-to-select-and-drag all in one click. 
    // otherwise you have to click once to select and then click again to begin a drag, which sux.
    BOOL withinDragRadius = YES;
        
    NSInteger radius = DRAG_RADIUS;
    NSRect r = NSMakeRect(locInWin.x - radius, locInWin.y - radius, radius * 2, radius * 2);
    
    while (withinDragRadius) {
        evt = [[self window] nextEventMatchingMask:NSLeftMouseUpMask|NSLeftMouseDraggedMask|NSPeriodicMask];
        
        switch ([evt type]) {
            case NSLeftMouseDragged:
                if (NSPointInRect([evt locationInWindow], r)) {
                    // still within drag radius tolerance. dont drag yet
                    break;
                }
                self.draggingIndexes = self.selectionIndexes; //[NSIndexSet indexSetWithIndex:i];

                NSMutableIndexSet *visSet = [NSMutableIndexSet indexSet];
                NSUInteger visOffset = visibleIndex - i;
                // Backward
                NSUInteger idx = [self.selectionIndexes lastIndex];
                while (NSNotFound != idx) {
                    [visSet addIndex:idx + visOffset];
                    idx = [self.selectionIndexes indexLessThanIndex:idx];
                }
                
                self.draggingVisibleIndexes = isCopy ? nil : visSet; //[NSIndexSet indexSetWithIndex:visibleIndex];
                isDragSource = YES;
                [self mouseDragged:evt];
                withinDragRadius = NO;
                break;
            case NSLeftMouseUp:
            case NSPeriodic:
                withinDragRadius = NO;
                if (!hasUpdatedSelection) {
                    [self updateSelectionWithEvent:evt index:i];
                }
                [self draggingSourceDragDidEnd];
                [self mouseUp:evt];
                break;
            default:
                break;
        }
    }
}


- (void)updateSelectionWithEvent:(NSEvent *)evt index:(NSUInteger)i {
    NSMutableIndexSet *newIndexes = nil;
    if (NSNotFound == i) {
        // set to nil selection
    } else {
        newIndexes = [NSMutableIndexSet indexSet];
        if (self.allowsMultipleSelection) {
            NSIndexSet *oldIndexes = self.selectionIndexes;
            
            if ([evt isCommandKeyPressed]) {
                [newIndexes addIndexes:oldIndexes];
                if ([oldIndexes containsIndex:i]) {
                    [newIndexes removeIndex:i];
                } else {
                    [newIndexes addIndex:i];
                }
            } else if ([evt isShiftKeyPressed]) {
                [newIndexes addIndex:i];
                
                if (i == anchorIndex || NSNotFound == anchorIndex) {
                    // we're done
                } else {
                    NSUInteger firstIndex = [oldIndexes firstIndex];
                    NSUInteger lastIndex = [oldIndexes lastIndex];
                    [newIndexes addIndexes:oldIndexes];
                    if (i < firstIndex) {
                        [newIndexes addIndexesInRange:NSMakeRange(i, firstIndex - i)];
                    } else if (i > lastIndex) {
                        [newIndexes addIndexesInRange:NSMakeRange(lastIndex, i - lastIndex)];
                    } else if (i < anchorIndex) {
                        [newIndexes removeIndexesInRange:NSMakeRange(firstIndex, i - firstIndex)];
                    } else if (i > anchorIndex) {
                        [newIndexes removeIndexesInRange:NSMakeRange(i + 1, lastIndex - i + 1)];
                    }
                }
                
            } else {
                [newIndexes addIndex:i];
            }
        } else {
            [newIndexes addIndex:i];
        }
    }
    self.selectionIndexes = newIndexes;
}


- (void)handleRightClickEvent:(NSEvent *)evt {
    NSPoint locInWin = [evt locationInWindow];
    NSPoint p = [self convertPoint:locInWin fromView:nil];
    NSUInteger i = [self indexForItemAtPoint:p];

    self.selectionIndexes = [NSIndexSet indexSetWithIndex:i];
    
    if (delegate && [delegate respondsToSelector:@selector(listView:contextMenuForItemAtIndex:)]) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:0 
                                                 target:self 
                                               selector:@selector(displayContextMenu:) 
                                               userInfo:evt 
                                                repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }
}


- (void)displayContextMenu:(NSTimer *)timer {
    if (delegate && [delegate respondsToSelector:@selector(listView:contextMenuForItemAtIndex:)]) {
        NSEvent *evt = [timer userInfo];
        NSUInteger i = [self.selectionIndexes firstIndex];
        
        //if (NSNotFound == i || i >= [dataSource numberOfItemsInListView:self]) return;
        
        NSMenu *menu = [delegate listView:self contextMenuForItemAtIndex:i];
        if (menu) {
            NSEvent *click = [NSEvent mouseEventWithType:[evt type] 
                                                location:[evt locationInWindow]
                                           modifierFlags:[evt modifierFlags] 
                                               timestamp:[evt timestamp] 
                                            windowNumber:[evt windowNumber] 
                                                 context:[evt context]
                                             eventNumber:[evt eventNumber] 
                                              clickCount:[evt clickCount] 
                                                pressure:[evt pressure]];
            
            [NSMenu popUpContextMenu:menu withEvent:click forView:self];
        }
    }
    
    [timer invalidate];
}


- (void)handleDoubleClickAtIndex:(NSUInteger)i {
    if (NSNotFound == i) {
        if (delegate && [delegate respondsToSelector:@selector(listViewEmptyAreaWasDoubleClicked:)]) {
            [delegate listViewEmptyAreaWasDoubleClicked:self];
        }
    } else {
        if (delegate && [delegate respondsToSelector:@selector(listView:itemWasDoubleClickedAtIndex:)]) {
            [delegate listView:self itemWasDoubleClickedAtIndex:i];
        }
    }    
}


- (void)mouseDragged:(NSEvent *)evt {
    // have to get the image before calling any delegate methods... they may rearrange or remove views which would cause us to have the wrong image
    self.dragOffset = NSZeroPoint;
    NSImage *dragImg = nil;
    if (delegate && [delegate respondsToSelector:@selector(listView:draggingImageForItemsAtIndexes:withEvent:offset:)]) {
        dragImg = [delegate listView:self draggingImageForItemsAtIndexes:draggingIndexes withEvent:lastMouseDownEvent offset:&dragOffset];
    } else {
        dragImg = [self draggingImageForItemsAtIndexes:draggingIndexes withEvent:evt offset:&dragOffset];
    }
 
    BOOL canDrag = YES;
    BOOL slideBack = YES;
    if (delegate && [delegate respondsToSelector:@selector(listView:canDragItemsAtIndexes:withEvent:slideBack:)]) {
        canDrag = [delegate listView:self canDragItemsAtIndexes:draggingIndexes withEvent:evt slideBack:&slideBack];
    }
    if (!canDrag) return;
    
    NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pboard declareTypes:[NSArray arrayWithObject:TDListItemPboardType] owner:self];
    
    canDrag = NO;
    if (/*NSNotFound != draggingVisibleIndex && */delegate && [delegate respondsToSelector:@selector(listView:writeItemsAtIndexes:toPasteboard:)]) {
        canDrag = [delegate listView:self writeItemsAtIndexes:draggingIndexes toPasteboard:pboard];
    }
    if (!canDrag) return;
    
    self.selectionIndexes = nil;
    
    NSPoint p = [self convertPoint:[evt locationInWindow] fromView:nil];
    
    dragOffset.x = dragOffset.x - ([evt locationInWindow].x - [lastMouseDownEvent locationInWindow].x);
    dragOffset.y = dragOffset.y + ([evt locationInWindow].y - [lastMouseDownEvent locationInWindow].y);
    
    p.x -= dragOffset.x;
    p.y -= dragOffset.y;
    
    NSSize ignored = NSZeroSize;
    [self dragImage:dragImg at:p offset:ignored event:evt pasteboard:pboard source:self slideBack:slideBack];
}


#pragma mark -
#pragma mark DraggingSource

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal {
    return isLocal ? localDragOperationMask : nonLocalDragOperationMask;
}


- (void)setDraggingSourceOperationMask:(NSDragOperation)mask forLocal:(BOOL)localDestination {
    if (localDestination) {
        localDragOperationMask = mask;
    } else {
        nonLocalDragOperationMask = mask;
    }
}


- (BOOL)ignoreModifierKeysWhileDragging {
    return YES;
}


- (NSImage *)draggingImageForItemsAtIndexes:(NSIndexSet *)set withEvent:(NSEvent *)evt offset:(NSPointPointer)dragImageOffset {
    CGFloat width = 0;
    CGFloat height = 0;
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[set count]];

    TDListItem *item = nil;
    NSUInteger i = [set firstIndex];
    while (NSNotFound != i) {
        item = [self itemAtIndex:i];
        NSRect itemFrame = [item frame];
        width = itemFrame.size.width;
        height += itemFrame.size.height;
        [images addObject:[item draggingImage]];
        i = [set indexGreaterThanIndex:i];
    }

    // get offset from last item
    if (dragImageOffset) {
        NSPoint p = [item convertPoint:[evt locationInWindow] fromView:nil];
        *dragImageOffset = NSMakePoint(p.x, p.y - NSHeight([item frame]));
    }
    
    NSImage *result = [[[NSImage alloc] initWithSize:NSMakeSize(width, height)] autorelease];
    [result lockFocus];
    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    NSImageInterpolation savedInterpolation = [currentContext imageInterpolation];
    [currentContext setImageInterpolation:NSImageInterpolationHigh];

    CGFloat y = 0;
    for (NSImage *img in [images reverseObjectEnumerator]) {
        NSSize imgSize = [img size];
        [img drawInRect:NSMakeRect(0, y, imgSize.width, imgSize.height) fromRect:NSMakeRect(0, 0, imgSize.width, imgSize.height) operation:NSCompositeSourceOver fraction:.5];
        y += imgSize.height;
    }
    
    [currentContext setImageInterpolation:savedInterpolation];
    [result unlockFocus];
    
    return result;
}


- (void)draggedImage:(NSImage *)image endedAt:(NSPoint)endPointInScreen operation:(NSDragOperation)op {
    // screen origin is lower left
    endPointInScreen.x += dragOffset.x;
    endPointInScreen.y -= dragOffset.y;

    // window origin is lower left
    NSPoint endPointInWin = [[self window] convertScreenToBase:endPointInScreen];

    // get frame of visible portion of list view in window coords
    NSRect dropZone = [self convertRect:[self visibleRect] toView:nil];

    if (!NSPointInRect(endPointInWin, dropZone)) {
        if (delegate && [delegate respondsToSelector:@selector(listView:shouldRunPoofAt:forRemovedItemsAtIndexes:)]) {
            if ([delegate listView:self shouldRunPoofAt:endPointInScreen forRemovedItemsAtIndexes:draggingIndexes]) {
                [NSToolbarPoofAnimator runPoofAtPoint:endPointInScreen];
            }
        }
    }

    [self layoutItems];

    [self draggingSourceDragDidEnd];
}


#pragma mark -
#pragma mark NSDraggingDestination

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)dragInfo {    
    delegateRespondsToValidateDrop = delegate && [delegate respondsToSelector:@selector(listView:validateDrop:proposedIndex:dropOperation:)];
    
    if (!itemFrames) {
        self.itemFrames = [NSMutableArray arrayWithCapacity:[items count]];
        for (TDListItem *item in items) {
            [itemFrames addObject:[NSValue valueWithRect:[item frame]]];
        }
    }
    
    NSPasteboard *pboard = [dragInfo draggingPasteboard];
    NSDragOperation srcMask = [dragInfo draggingSourceOperationMask];
    
    if ([[pboard types] containsObject:TDListItemPboardType]) {
        BOOL optPressed = [[[dragInfo draggingDestinationWindow] currentEvent] isOptionKeyPressed];
        
        if (optPressed && (srcMask & NSDragOperationCopy)) {
            return NSDragOperationCopy;
        } else if ((srcMask & NSDragOperationMove)) {
            return NSDragOperationMove;
        }
    }
    
    return NSDragOperationNone;
}


/* TODO if the destination responded to draggingEntered: but not to draggingUpdated: the return value from draggingEntered: should be used */
- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)dragInfo {
    if (!delegateRespondsToValidateDrop) {
        return NSDragOperationNone;
    }
    
    NSDragOperation dragOp = NSDragOperationNone;
    BOOL isDraggingListItem = (draggingVisibleIndexes || [[[dragInfo draggingPasteboard] types] containsObject:TDListItemPboardType]);
    
    NSPoint locInWin = [dragInfo draggingLocation];
    NSPoint locInList = [self convertPoint:locInWin fromView:nil];

    if (isDraggingListItem) {
        dropIndex = [self indexForItemWhileDraggingAtPoint:locInList];
    } else {
        dropIndex = [self indexForItemAtPoint:locInList];
    }
        
    NSUInteger itemCount = [items count];
    //if (dropIndex < 0 || NSNotFound == dropIndex) {// || dropIndex > itemCount) {
    if (dropIndex < 0 || NSNotFound == dropIndex || dropIndex > itemCount) {
        dropIndex = itemCount;
    }
    
    TDListItem *item = [self itemAtIndex:dropIndex];
    NSUInteger firstIndex = 0;
    if ([items count]) {
        firstIndex =  [[items objectAtIndex:0] index];
    }
    if (item) {
        dropVisibleIndex = [items indexOfObject:item];
        dropVisibleIndex += firstIndex;
    } else {
        dropVisibleIndex = firstIndex - (firstIndex - dropIndex);
    }

    dropIndex += firstIndex;
    item = [self itemWhileDraggingAtIndex:dropIndex];
    NSPoint locInItem = [item convertPoint:locInWin fromView:nil];

    NSRect itemBounds = [item bounds];
    NSRect front, back;
    
    if (self.isPortrait) {
        front = NSMakeRect(itemBounds.origin.x, itemBounds.origin.y, itemBounds.size.width, itemBounds.size.height / 3);
        back = NSMakeRect(itemBounds.origin.x, ceil(itemBounds.size.height * .66), itemBounds.size.width, itemBounds.size.height / 3);
    } else {
        front = NSMakeRect(itemBounds.origin.x, itemBounds.origin.y, itemBounds.size.width / 3, itemBounds.size.height);
        back = NSMakeRect(ceil(itemBounds.size.width * .66), itemBounds.origin.y, itemBounds.size.width / 3, itemBounds.size.height);
    }
    
    dropOp = TDListViewDropOn;
    if (isDraggingListItem) {
        if (NSPointInRect(locInItem, front)) {
            // if p is in the first 1/3 of the item change the op to DropBefore
            dropOp = TDListViewDropBefore;
            
        } else if (NSPointInRect(locInItem, back)) {
            // if p is in the last 1/3 of the item view change op to DropBefore and increment index
            dropIndex++;
            dropVisibleIndex++;
            dropOp = TDListViewDropBefore;
        } else {
            // if p is in the middle 1/3 of the item view leave as DropOn
        }    
    }
    
    // if copying...
    //if (NSNotFound == draggingVisibleIndexes && dropIndex > draggingIndexes) {
    if (!draggingVisibleIndexes && dropIndex > [draggingIndexes lastIndex]) {
        dropIndex++;
    }

    dragOp = [delegate listView:self validateDrop:dragInfo proposedIndex:&dropIndex dropOperation:&dropOp];
    
    //NSLog(@"over: %@. Drop %@ : %d", item, dropOp == TDListViewDropOn ? @"On" : @"Before", dropIndex);

    //if (isDraggingListItem) {
        [self layoutItemsWhileDragging];
    //}
    
    return dragOp;
}


- (void)draggingExited:(id <NSDraggingInfo>)dragInfo {
    [super draggingExited:dragInfo];
    if (!isDragSource) {
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:.3];
    }
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)dragInfo {
    //if (dropIndex > draggingIndexes) {
    if (dropIndex > [draggingIndexes lastIndex]) {

//        NSUInteger diff = dropIndex - draggingIndex;
//        dropIndex -= diff;
//        dropVisibleIndex -= diff;
        dropIndex--;
        dropVisibleIndex--;
    }
    self.itemFrames = nil;
    
    suppressLayout = YES;
    [self performSelector:@selector(unsuppressLayout) withObject:nil afterDelay:.15];

    if (delegate && [delegate respondsToSelector:@selector(listView:acceptDrop:index:dropOperation:)]) {
        return [delegate listView:self acceptDrop:dragInfo index:dropIndex dropOperation:dropOp];
    } else {
        return NO;
    }
}


- (void)unsuppressLayout {
    suppressLayout = NO;
    [self layoutItems];
}


#pragma mark -
#pragma mark Private

- (void)layoutItems {
    if (suppressLayout) return;
    
    if (!dataSource) {
        return;
        //[NSException raise:EXCEPTION_NAME format:@"TDListView must have a dataSource before doing layout"];
    }

    for (TDListItem *item in items) {
        [queue enqueue:item];
        [unusedItems addObject:item];
        //[item removeFromSuperview];
    }
    
    [items removeAllObjects];
    
    NSRect viewportRect = [self visibleRect];
    NSRect bounds = [self bounds];
    BOOL isPortrait = self.isPortrait;
    
    CGFloat x = itemMargin;
    CGFloat y = 0;
    CGFloat w = isPortrait ? bounds.size.width : 0;
    CGFloat h = isPortrait ? 0 : bounds.size.height;
    
    NSInteger c = [dataSource numberOfItemsInListView:self];
    BOOL respondsToExtentForItem = (delegate && [delegate respondsToSelector:@selector(listView:extentForItemAtIndex:)]);
    BOOL respondsToWillDisplay = (delegate && [delegate respondsToSelector:@selector(listView:willDisplayItem:atIndex:)]);
    
    NSUInteger i = 0;
    for ( ; i < c; i++) {
        // determine item frame
        CGFloat extent = respondsToExtentForItem ? [delegate listView:self extentForItemAtIndex:i] : itemExtent;
        if (isPortrait) {
            h = extent;
        } else {
            w = extent;
        }
        NSRect itemFrame = NSMakeRect(x, y, w, h);
        
        // if the item is visible...
        BOOL isItemVisible = NO;
        if (displaysClippedItems) {
            isItemVisible = NSIntersectsRect(viewportRect, itemFrame);
        } else {
            isItemVisible = NSContainsRect(viewportRect, itemFrame);
        }

        if (isItemVisible) {
            TDListItem *item = [dataSource listView:self itemAtIndex:i];
            if (!item) {
                [NSException raise:EXCEPTION_NAME format:@"nil list item view returned for index: %d by: %@", i, dataSource];
            }
            item.index = i;
            [item setFrame:NSMakeRect(x, y, w, h)];
            [item setHidden:NO];
            [self addSubview:item];
            [items addObject:item];
            [unusedItems removeObject:item];

            if (respondsToWillDisplay) {
                [delegate listView:self willDisplayItem:item atIndex:i];
            }
        }

        if (isPortrait) {
            y += extent + itemMargin; // add height for next row
        } else {
            x += extent + itemMargin;
        }
    }
    
    for (TDListItem *item in unusedItems) {
        [item removeFromSuperview];
    }

    [unusedItems removeAllObjects];
    
    NSDragOperation mask = [self draggingSourceOperationMaskForLocal:YES];
    CGFloat fudge = (mask == NSDragOperationNone) ? 0 : [self scrollFudgeExtent];
    
    NSRect frame = [self frame];
    NSRect vizRect = self.scrollView ? [self.scrollView documentVisibleRect] : viewportRect;
    if (isPortrait) {
        if ([self autoresizingMask] & NSViewHeightSizable) {
            y = y < vizRect.size.height - fudge ? vizRect.size.height : y + fudge;
        }
        frame.size.height = y;
    } else {
        if ([self autoresizingMask] & NSViewWidthSizable) {
            x = x < vizRect.size.width - fudge ? vizRect.size.width : x + fudge;
        }
        frame.size.width = x;
    }
    
    [self setFrame:frame];
    
    //NSLog(@"%s my bounds: %@, viewport bounds: %@", _cmd, NSStringFromRect([self bounds]), NSStringFromRect([[self superview] bounds]));
    //NSLog(@"view count: %d, queue count: %d", [items count], [queue count]);
}


- (void)layoutItemsWhileDragging {
    //if (NSNotFound == draggingIndex) return;
    
    NSUInteger itemCount = [items count];
    TDListItem *item = nil;
    
    CGFloat draggingExtent = 0;
    if ([draggingVisibleIndexes count]) {

        TDListItem *draggingItem = nil;
        NSUInteger i = [draggingVisibleIndexes firstIndex];
        while (NSNotFound != i) {
            draggingItem = [self itemAtVisibleIndex:i];
            draggingExtent += self.isPortrait ? NSHeight([draggingItem frame]) : NSWidth([draggingItem frame]);
            i = [draggingVisibleIndexes indexGreaterThanIndex:i];
        }
        
    } else {
        draggingExtent = (itemExtent > 0) ? itemExtent : DEFAULT_ITEM_EXTENT;
    }

    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.05];
    
    NSRect startFrame = [[self itemAtVisibleIndex:0] frame];
    CGFloat extent = self.isPortrait ? NSMinY(startFrame) : NSMinX(startFrame);
    
    CGFloat offset = self.isPortrait ? NSMinY([self visibleRect]) : NSMinX([self visibleRect]);
    BOOL scrolled = (offset > 0);
    if (!scrolled) {
        extent = extent > 0 ? 0 : extent;
    } else {
//        CGFloat firstExtent = self.isPortrait ? NSMinY(startFrame) + NSHeight(startFrame) : NSMinX(startFrame) + NSWidth(startFrame);
//        extent = extent > firstExtent ? firstExtent : extent;
    }
    NSUInteger i = 0;
    for ( ; i <= itemCount; i++) {
        item = [self itemAtVisibleIndex:i];
        NSRect frame = [item frame];
        if (self.isPortrait) {
            frame.origin.y = extent;
        } else {
            frame.origin.x = extent;
        }
        
        [item setHidden:[draggingVisibleIndexes containsIndex:i]];
        
        if (i >= dropVisibleIndex) {
            if (self.isPortrait) {
                frame.origin.y += draggingExtent;
            } else {
                frame.origin.x += draggingExtent;
            }
        }
        
        [[item animator] setFrame:frame];
        if (![draggingVisibleIndexes containsIndex:i]) {
            extent += self.isPortrait ? frame.size.height : frame.size.width;
        }
    }

    [NSAnimationContext endGrouping];
}


- (NSUInteger)indexForItemWhileDraggingAtPoint:(NSPoint)p {
    if ([itemFrames count] && [items count]) {
        NSUInteger offset = [[items objectAtIndex:0] index];
        NSUInteger i = 0;
        for (NSValue *v in itemFrames) {
            if (i > [items count] - 1) break;
            
            NSRect r = [v rectValue];
            if (NSPointInRect(p, r)) {
                NSUInteger c = [draggingIndexes count];
                BOOL isLocal = c > 0;
                
                if (isLocal && i >= [draggingVisibleIndexes firstIndex]) {
                    return [[items objectAtIndex:i] index] + c - offset;
                } else {
                    return [[items objectAtIndex:i] index] - offset;
                }
            }
            i++;
        }
    }
    return NSNotFound;
}


- (TDListItem *)itemWhileDraggingAtIndex:(NSInteger)i {
    TDListItem *item = [self itemAtIndex:i];
    TDListItem *draggingItem = [self itemAtVisibleIndex:[draggingVisibleIndexes firstIndex]]; // TODO
                                
    if (item == draggingItem) {
        TDListItem *nextItem = [self itemAtVisibleIndex:i + 1];
        item = nextItem ? nextItem : item;
    }
    if (!item) {
        item = (i < 0) ? [items objectAtIndex:0] : [items lastObject];
    }
    return item;
}


- (void)draggingSourceDragDidEnd {
    self.draggingVisibleIndexes = nil;
    self.draggingIndexes = nil;
    isDragSource = NO;
    self.lastMouseDownEvent = nil;
}


- (CGFloat)scrollFudgeExtent {
    return 0.0;
}

@synthesize scrollView;
@synthesize dataSource;
@synthesize delegate;
@synthesize backgroundColor;
@synthesize itemExtent;
@synthesize itemMargin;
@synthesize selectionIndexes;
@synthesize orientation;
@synthesize items;
@synthesize unusedItems;
@synthesize queue;
@synthesize displaysClippedItems;
@synthesize lastMouseDownEvent;
@synthesize itemFrames;
@synthesize dragOffset;
@synthesize draggingIndexes;
@synthesize draggingVisibleIndexes;
@synthesize allowsMultipleSelection;
@end
