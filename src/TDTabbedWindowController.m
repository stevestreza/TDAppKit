//
//  TDTabbedWindowController.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabbedWindowController.h>
#import "TDTabsListViewController.h"

@implementation TDTabbedWindowController

- (void)dealloc {
    self.tabsListViewController = nil;
    [super dealloc];
}

@synthesize tabsListViewController;
@end
