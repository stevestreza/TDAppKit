//
//  TDTabbedDocument.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDTabbedDocument.h"
#import "TDTabModel.h"
#import "TDTabController.h"

@interface TDTabbedDocument ()
//@property (nonatomic, retain, readwrite) TDTabController *selectedTabModel;
//@property (nonatomic, retain, readwrite) TDTabController *selectedTabController;
@end

@implementation TDTabbedDocument

- (void)dealloc {
    self.tabModels = nil;
    self.tabControllers = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark NSDocument

- (void)makeWindowControllers {
    
}


#pragma mark -
#pragma mark Properties

- (TDTabModel *)selectedTabModel {
    return [tabModels objectAtIndex:selectedTabIndex];
}


- (TDTabController *)selectedTabController {
    return [tabControllers objectAtIndex:selectedTabIndex];
}


- (void)setSelectedTabIndex:(NSUInteger)i {
    if (selectedTabIndex != i) {
        [self willChangeValueForKey:@"selectedTabIndex"];
        
        selectedTabIndex = i;
        
        [self didChangeValueForKey:@"selectedTabIndex"];
    }
}

@synthesize tabModels;
@synthesize tabControllers;
@synthesize selectedTabIndex;
@end
