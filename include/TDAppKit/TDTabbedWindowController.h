//
//  TDTabbedWindowController.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TDTabsListViewController;

@interface TDTabbedWindowController : NSWindowController {
    TDTabsListViewController *tabsListViewController;
}

//- (IBAction)performClose:(id)sender; // maps to -closeTab:. must do this for framework calls

@property (nonatomic, retain) TDTabsListViewController *tabsListViewController;
@end
