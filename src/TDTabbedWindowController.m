//
//  TDTabbedWindowController.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabbedWindowController.h>
#import <TDAppKit/TDTabsListViewController.h>
#import <TDAppKit/TDTabbedDocument.h>
#import <TDAppKit/TDTabModel.h>

@interface TDTabbedWindowController ()
- (void)setUpTabsListView;
@end

@implementation TDTabbedWindowController

- (void)dealloc {
    self.tabsListViewController = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark NSWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self setUpTabsListView];
}


- (void)setUpTabsListView {
    self.tabsListViewController = [[[TDTabsListViewController alloc] init] autorelease];
    tabsListViewController.delegate = self;
}


#pragma mark -
#pragma mark TDTabsListViewControllerDelegate

- (NSUInteger)numberOfTabsInTabsViewController:(TDTabsListViewController *)tvc {
    TDTabbedDocument *doc = (TDTabbedDocument *)[self document];
    NSUInteger c = [doc.tabModels count];
    return c;
}


- (TDTabModel *)tabsViewController:(TDTabsListViewController *)tvc tabModelAtIndex:(NSUInteger)i {
    TDTabbedDocument *doc = (TDTabbedDocument *)[self document];
    TDTabModel *tabModel = [doc.tabModels objectAtIndex:i];
    return tabModel;
}


- (void)tabsViewController:(TDTabsListViewController *)tvc closeTabModelAtIndex:(NSUInteger)i {
    TDTabbedDocument *doc = (TDTabbedDocument *)[self document];
    [doc closeTabAtIndex:i];
}

@synthesize tabsListViewController;
@end
