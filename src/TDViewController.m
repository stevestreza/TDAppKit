//
//  TDViewController.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDViewController.h>
#import <TDAppKit/TDView.h>

@implementation TDViewController

- (void)dealloc {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
    NSView *v = [self view];
    if (v) {
        [(TDView *)v setViewController:nil];
    }
    [super dealloc];
}


- (void)loadView {
    [super loadView];    
    [self viewDidLoad];
}


- (void)setView:(NSView *)v {
    if (v) {
        [(TDView *)v setViewController:self];
    }
    [super setView:v];
}


- (void)viewDidLoad {
    
}


- (void)viewWillAppear {
    
}


- (void)viewDidAppear {
    
}


- (void)viewWillDisappear {
    
}


- (void)viewDidDisappear {
    
}


- (void)viewWillMoveToSuperview:(NSView *)v {
    
}


- (void)viewDidMoveToSuperview {
    
}


- (void)viewWillMoveToWindow:(NSWindow *)win {
    
}


- (void)viewDidMoveToWindow {
    
}

@end
