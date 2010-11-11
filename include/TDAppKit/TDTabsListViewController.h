//
//  TDTabsViewController.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TDAppKit/TDListView.h>

@class TDTabModel;
@class TDTabsListViewController;

@protocol TDTabsListViewControllerDelegate <NSObject>
- (NSUInteger)numberOfTabsInTabsViewController:(TDTabsListViewController *)tvc;
- (TDTabModel *)tabsViewController:(TDTabsListViewController *)tvc tabModelAtIndex:(NSUInteger)i;
@end

@interface TDTabsListViewController : NSViewController <TDListViewDataSource, TDListViewDelegate> {
    id <TDTabsListViewControllerDelegate> delegate;
    TDListView *listView;
}

@property (nonatomic, assign) id <TDTabsListViewControllerDelegate> delegate; // weak ref
@property (nonatomic, retain) IBOutlet TDListView *listView;
@end
