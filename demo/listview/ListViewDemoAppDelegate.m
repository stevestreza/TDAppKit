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

#import "ListViewDemoAppDelegate.h"
#import "DemoListItemView.h"
#import <TDAppKit/TDAppKit.h>

@implementation ListViewDemoAppDelegate

- (id)init {
    if (self = [super init]) {
        self.colors = [NSMutableArray array];
        [colors addObject:[NSColor magentaColor]];
        [colors addObject:[NSColor redColor]];
        [colors addObject:[NSColor orangeColor]];
        [colors addObject:[NSColor yellowColor]];
        [colors addObject:[NSColor greenColor]];
        [colors addObject:[NSColor blueColor]];
        [colors addObject:[NSColor purpleColor]];
    }
    return self;
}


- (void)dealloc {
    self.listView = nil;
    self.colors = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    // setup drag and drop.
    [listView registerForDraggedTypes:[NSArray arrayWithObjects:NSColorPboardType, nil]];
    [listView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    [listView setDraggingSourceOperationMask:NSDragOperationDelete forLocal:NO];
    
    // setup ui.
    listView.displaysClippedItems = YES;
    listView.backgroundColor = [NSColor darkGrayColor];
    [listView reloadData];
}


#pragma mark -
#pragma mark TDListViewDataSource

- (NSInteger)numberOfItemsInListView:(TDListView *)tv {
    return 7;
}


- (TDListItem *)listView:(TDListView *)lv itemAtIndex:(NSInteger)i {
    static NSString *sIdentifier = @"foo";
    
    DemoListItemView *itemView = (DemoListItemView *)[listView dequeueReusableItemWithIdentifier:sIdentifier];
    
    if (!itemView) {
        itemView = [[[DemoListItemView alloc] initWithFrame:NSZeroRect reuseIdentifier:sIdentifier] autorelease];
    }
    
    itemView.color = [colors objectAtIndex:i];
    itemView.selected = ([listView.selectionIndexes containsIndex:i]);
    [itemView setNeedsDisplay:YES];
    
    return itemView;
}


#pragma mark -
#pragma mark TDListViewDelegate

- (CGFloat)listView:(TDListView *)lv extentForItemAtIndex:(NSUInteger)i {
    return 60 * (i + 1);
}


- (void)listView:(TDListView *)lv willDisplay:(TDListItem *)rv atIndex:(NSInteger)i {
    
}


- (void)listView:(TDListView *)lv itemWasDoubleClickedAtIndex:(NSUInteger)i {
    
}


- (void)listViewEmptyAreaWasDoubleClicked:(TDListView *)lv {
    
}


#pragma mark -
#pragma mark TDListViewDelegate Drag and Drop

- (BOOL)listView:(TDListView *)lv canDragItemAtIndex:(NSUInteger)i withEvent:(NSEvent *)evt slideBack:(BOOL *)slideBack {
    *slideBack = YES;
    return YES;
}

/*
 This method is called after it has been determined that a drag should begin, but before the drag has been started. 
 To refuse the drag, return NO. To start the drag, declare the pasteboard types that you support with -[NSPasteboard declareTypes:owner:], 
 place your data for the items at the given indexes on the pasteboard, and return YES from the method. 
 The drag image and other drag related information will be set up and provided by the view once this call returns YES. 
 You need to implement this method for your list view to be a drag source.
 */
- (BOOL)listView:(TDListView *)lv writeItemAtIndex:(NSUInteger)i toPasteboard:(NSPasteboard *)pboard {
    DemoListItemView *itemView = (DemoListItemView *)[listView itemAtIndex:i];
    if (itemView) {
        [pboard declareTypes:[NSArray arrayWithObjects:NSColorPboardType, nil] owner:self];
        [itemView.color writeToPasteboard:pboard];
        [colors removeObjectAtIndex:i];
        [listView setSelectionIndexes:nil];
        [listView reloadData];
        return YES;
    } else {
        return NO;
    }
}


- (NSDragOperation)listView:(TDListView *)lv validateDrop:(id <NSDraggingInfo>)dragInfo proposedIndex:(NSUInteger *)proposedDropIndex dropOperation:(TDListViewDropOperation *)proposedDropOperation {
    //NSLog(@"%s", _cmd);
    return NSDragOperationMove;
}


- (BOOL)listView:(TDListView *)lv acceptDrop:(id <NSDraggingInfo>)dragInfo index:(NSUInteger)i dropOperation:(TDListViewDropOperation)dropOperation {
    NSPasteboard *pboard = [dragInfo draggingPasteboard];
    
    if (![[pboard types] containsObject:NSColorPboardType]) {
        return NO;
    }
    
    NSColor *color = [NSColor colorFromPasteboard:pboard];
    if (i < [colors count]) {
        [colors insertObject:color atIndex:i];
    } else {
        [colors addObject:color];
    }
    [listView reloadData];
    
    return YES;
}

@synthesize listView;
@synthesize colors;
@end
