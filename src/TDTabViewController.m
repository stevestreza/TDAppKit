//
//  TDTabController.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDTabViewController.h"

@implementation TDTabViewController

- (id)init {
    self = [super initWithNibName:@"TDTabView" bundle:nil];
    return self;
}


- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)b{
    if (self = [super initWithNibName:name bundle:b]) {
        
    }
    return self;
}


- (void)dealloc {
    self.tabModel = nil;
    [super dealloc];
}


- (void)setTabModel:(TDTabModel *)m {
    if (tabModel != m) {
        [self willChangeValueForKey:@"tabModel"];

        [tabModel autorelease];
        tabModel = [m retain];
        
        if (tabModel) {
            [tabModel addObserver:self forKeyPath:@"title" options:0 context:NULL];
        }
        
        [self didChangeValueForKey:@"tabModel"];
    }
}

@synthesize tabModel;
@end
