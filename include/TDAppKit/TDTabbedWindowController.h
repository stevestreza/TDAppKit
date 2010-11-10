//
//  TDTabbedWindowController.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TDAppKit/TDTabsListViewController.h>

@interface TDTabbedWindowController : NSWindowController <TDTabsListViewControllerDelegate> {
    TDTabsListViewController *tabsListViewController;
}

@property (nonatomic, retain) TDTabsListViewController *tabsListViewController;
@end
