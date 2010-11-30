//
//  TDTabbedDocument.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TDAppKit/TDTabsListViewController.h>

@class TDTabModel;
@class TDTabViewController;

@interface TDTabbedDocument : NSDocument  <TDTabsListViewControllerDelegate> {
    NSString *identifier;
    NSMutableArray *models;
    TDTabModel *selectedTabModel;
    NSUInteger selectedTabIndex;
}

//- (IBAction)performClose:(id)sender;
- (IBAction)closeTab:(id)sender;
- (IBAction)closeWindow:(id)sender;

- (IBAction)newTab:(id)sender;
- (IBAction)newBackgroundTab:(id)sender;

- (IBAction)takeTabIndexToCloseFrom:(id)sender;
- (IBAction)takeTabIndexToMoveToNewWindowFrom:(id)sender;

- (void)addTabModelAtIndex:(NSUInteger)i;
- (void)addTabModel:(TDTabModel *)tm;
- (void)addTabModel:(TDTabModel *)tm atIndex:(NSUInteger)i;
- (void)removeTabModelAtIndex:(NSUInteger)i;
- (void)removeTabModel:(TDTabModel *)tm;

- (TDTabModel *)tabModelAtIndex:(NSUInteger)i;
- (NSUInteger)indexOfTabModel:(TDTabModel *)tm;

// subclass
- (void)didAddTabModel:(TDTabModel *)tm;
- (void)willRemoveTabModel:(TDTabModel *)tm;
- (void)selectedTabIndexWillChange;
- (void)selectedTabIndexDidChange;

- (TDTabViewController *)newTabViewController;
- (NSMenu *)contextMenuForTabModelAtIndex:(NSUInteger)i;

@property (nonatomic, retain, readonly) NSArray *tabModels;
@property (nonatomic, assign) NSUInteger selectedTabIndex;
@property (nonatomic, retain, readonly) TDTabModel *selectedTabModel;
@property (nonatomic, retain, readonly) TDTabViewController *selectedTabViewController;
@end
