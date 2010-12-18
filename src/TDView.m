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

//- (id)initWithFrame:(CGRect)f {
//    if (self = [super initWithFrame:f]) {
//        NSLog(@"%s", __PRETTY_FUNCTION__);
//    }
//    return self;
//}


- (void)dealloc {
#ifdef TDDEBUG
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
#endif
    self.viewController = nil;
    [super dealloc];
}


//- (void)awakeFromNib {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}


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
