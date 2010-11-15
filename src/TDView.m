//
//  TDView.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/14/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDView.h>
#import <TDAppKit/TDViewController.h>

@implementation TDView

- (void)dealloc {
    self.viewController = nil;
    [super dealloc];
}


- (void)viewWillMoveToSuperview:(NSView *)v {
    [viewController viewWillMoveToSuperview:v];
}


- (void)viewDidMoveToSuperview {
    [viewController viewDidMoveToSuperview];
}


- (void)viewWillMoveToWindow:(NSWindow *)win {
    [viewController viewWillMoveToWindow:win];
}


- (void)viewDidMoveToWindow {
    [viewController viewDidMoveToWindow];
}

@synthesize viewController;
@end
