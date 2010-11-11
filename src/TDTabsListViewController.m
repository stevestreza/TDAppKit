//
//  TDTabsViewController.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDTabsListViewController.h"
#import <TDAppKit/TDTabModel.h>
#import <TDAppKit/TDTabListItem.h>

#define KEY_SELECTION_INDEXES @"selectionIndexes"
#define KEY_TAB_CONTROLLER @"FUTabController"
#define KEY_INDEX @"FUIndex"

#define ASPECT_RATIO .7

#define TDTabPboardType @"TDTabPboardType"

@implementation TDTabsListViewController

- (id)init {
    self = [super initWithNibName:@"TDTabsListView" bundle:[NSBundle bundleForClass:[self class]]];
    return self;
}


- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)b{
    if (self = [super initWithNibName:name bundle:b]) {
        
    }
    return self;
}


- (void)dealloc {
    self.scrollView = nil;
    self.listView = nil;
    [super dealloc];
}


- (void)viewDidLoad {
    listView.backgroundColor = [NSColor greenColor];
}


#pragma mark -
#pragma mark TDListViewDataSource

- (NSUInteger)numberOfItemsInListView:(TDListView *)lv {
    NSUInteger c = [delegate numberOfTabsInTabsViewController:self];
    return c;
}


- (TDListItem *)listView:(TDListView *)lv itemAtIndex:(NSUInteger)i {
    TDTabModel *tabModel = [delegate tabsViewController:self tabModelAtIndex:i];
    
    TDTabListItem *listItem = (TDTabListItem *)[listView dequeueReusableItemWithIdentifier:[TDTabListItem reuseIdentifier]];
    
    if (!listItem) {
        listItem = [[[TDTabListItem alloc] init] autorelease];
    }
    
    listItem.tabModel = tabModel;
    listItem.tabsListViewController = self;
    
    [listItem setNeedsDisplay:YES];
    return listItem;
}


#pragma mark -
#pragma mark TDListViewDelegate

- (CGFloat)listView:(TDListView *)lv extentForItemAtIndex:(NSUInteger)i {
    NSSize scrollSize = [scrollView frame].size;
    
    if (listView.isPortrait) {
        return floor(scrollSize.width * ASPECT_RATIO);
    } else {
        return floor(scrollSize.height * 1 / ASPECT_RATIO);
    }
}


- (void)listView:(TDListView *)lv willDisplayView:(TDListItem *)itemView forItemAtIndex:(NSUInteger)i {
    
}


- (void)listView:(TDListView *)lv didSelectItemsAtIndexes:(NSIndexSet *)set {
    [delegate tabsViewController:self didSelectTabModelAtIndex:[set firstIndex]];
}


- (void)listViewEmptyAreaWasDoubleClicked:(TDListView *)lv {
    [delegate tabsViewControllerWantsNewTab:self];
}


- (NSMenu *)listView:(TDListView *)lv contextMenuForItemAtIndex:(NSUInteger)i {
    NSMenu *menu = [delegate tabsViewController:self contextMenuForTabModelAtIndex:i];
    return menu;
}

@synthesize delegate;
@synthesize scrollView;
@synthesize listView;
@end
