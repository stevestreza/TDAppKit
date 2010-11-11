//
//  TDTabbedDocument.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabbedDocument.h>
#import <TDAppKit/TDTabModel.h>
#import <TDAppKit/TDTabViewController.h>

@interface TDTabbedDocument ()
@property (nonatomic, retain, readwrite) TDTabModel *selectedTabModel;
@end

@implementation TDTabbedDocument

- (id)init {
    if (self = [super init]) {
        selectedTabIndex = NSNotFound;
        
        self.tabModels = [NSMutableArray array];
        self.tabViewControllers = [NSMutableArray array];
    }
    return self;
}


- (void)dealloc {
    self.tabModels = nil;
    self.tabViewControllers = nil;
    self.selectedTabModel = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark NSDocument

- (void)makeWindowControllers {

}


- (void)shouldCloseWindowController:(NSWindowController *)wc delegate:(id)delegate shouldCloseSelector:(SEL)sel contextInfo:(void *)ctx {
    [super shouldCloseWindowController:wc delegate:delegate shouldCloseSelector:sel contextInfo:ctx];
}


- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)sel contextInfo:(void *)ctx {
    [super canCloseDocumentWithDelegate:delegate shouldCloseSelector:sel contextInfo:ctx];
}


#pragma mark -
#pragma mark Actions

- (IBAction)closeTab:(id)sender {
    [self removeTabAtIndex:self.selectedTabIndex];
}


- (IBAction)closeWindow:(id)sender {
    [self close];
}


- (IBAction)newTab:(id)sender {
    [self addTabAtIndex:[tabModels count] select:YES];
}


- (IBAction)newBackgroundTab:(id)sender {
    [self addTabAtIndex:[tabModels count] select:NO];
}


#pragma mark -
#pragma mark Public

- (void)addTabAtIndex:(NSUInteger)i select:(BOOL)select {
    NSParameterAssert(NSNotFound != i && i >= 0 && i <= [tabModels count]);
    
    // create model
    TDTabModel *tm = [[[TDTabModel alloc] init] autorelease];
    tm.index = i;
    
    // create viewController
    TDTabViewController *tvc = [[self newTabViewController] autorelease];
    tvc.tabModel = tm;
    
    // add or insert
    BOOL isAppend = (i == [tabModels count]);
    if (isAppend) {
        [tabModels addObject:tm];
        [tabViewControllers addObject:tvc];
    } else {
        [tabModels insertObject:tm atIndex:i];
        [tabViewControllers insertObject:tvc atIndex:i];
    }
    
    // notify
    [self didAddTabModel:tm];
    
    if (select) {
        // select
        self.selectedTabIndex = tm.index;
    }
}


- (void)removeTabAtIndex:(NSUInteger)i {
    NSParameterAssert(NSNotFound != i && i >= 0 && i <= [tabModels count]);

    NSUInteger c = [tabModels count];

    if (1 == c) {
        [self closeWindow:nil];
        return;
    }
    
    NSUInteger newIndex = i;
    if (i == c - 1) {
        newIndex--;
    }
    
    //TDTabModel *tm = 
    [[[tabModels objectAtIndex:i] retain] autorelease];
    [tabModels removeObjectAtIndex:i];
    
    TDTabViewController *tvc = [[[tabViewControllers objectAtIndex:i] retain] autorelease];
    [[tvc view] removeFromSuperview]; // ?? 
    [tabViewControllers removeObjectAtIndex:i];
    
    self.selectedTabIndex = newIndex;
}


#pragma mark -
#pragma mark Subclass

- (void)didAddTabModel:(TDTabModel *)tm {
    
}


- (void)willRemoveTabModel:(TDTabModel *)tm {
    
}


- (void)selectedTabIndexWillChange {
    
}


- (void)selectedTabIndexDidChange {
    
}


- (TDTabViewController *)newTabViewController {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return nil;
}


#pragma mark -
#pragma mark TDTabsListViewControllerDelegate

- (NSUInteger)numberOfTabsInTabsViewController:(TDTabsListViewController *)tvc {
    NSUInteger c = [tabModels count];
    return c;
}


- (TDTabModel *)tabsViewController:(TDTabsListViewController *)tvc tabModelAtIndex:(NSUInteger)i {
    TDTabModel *tabModel = [tabModels objectAtIndex:i];
    return tabModel;
}


- (NSMenu *)tabsViewController:(TDTabsListViewController *)tvc contextMenuForTabModelAtIndex:(NSUInteger)i {
    return nil;
}


- (void)tabsViewController:(TDTabsListViewController *)tvc didSelectTabModelAtIndex:(NSUInteger)i {
    self.selectedTabIndex = i;
}


- (void)tabsViewController:(TDTabsListViewController *)tvc didCloseTabModelAtIndex:(NSUInteger)i {
    [self removeTabAtIndex:i];
}


- (void)tabsViewControllerWantsNewTab:(TDTabsListViewController *)tvc {
    [self newTab:nil];
}


#pragma mark -
#pragma mark Properties

- (TDTabViewController *)selectedTabViewController {
    return [tabViewControllers objectAtIndex:selectedTabIndex];
}


- (void)setSelectedTabIndex:(NSUInteger)i {
    if (selectedTabIndex != i) {
        [self willChangeValueForKey:@"selectedTabIndex"];

        [self selectedTabIndexWillChange];
        
        selectedTabModel.selected = NO;

        selectedTabIndex = i;
        
        TDTabModel *tm = nil;
        if (NSNotFound != selectedTabIndex) {
            tm = [tabModels objectAtIndex:selectedTabIndex];
            tm.selected = YES;
        }
        self.selectedTabModel = tm;

        [self selectedTabIndexDidChange];
        
        [self didChangeValueForKey:@"selectedTabIndex"];
    }
}

@synthesize tabModels;
@synthesize tabViewControllers;
@synthesize selectedTabIndex;
@synthesize selectedTabModel;
@end
