//
//  TDTabbedDocument.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabbedDocument.h>
#import <TDAppKit/TDTabModel.h>
#import <TDAppKit/TDTabViewController.h>

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
    [super makeWindowControllers];

}


- (void)shouldCloseWindowController:(NSWindowController *)wc delegate:(id)delegate shouldCloseSelector:(SEL)sel contextInfo:(void *)ctx {
    [super shouldCloseWindowController:wc delegate:delegate shouldCloseSelector:sel contextInfo:ctx];
}


- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)sel contextInfo:(void *)ctx {
    [super canCloseDocumentWithDelegate:delegate shouldCloseSelector:sel contextInfo:ctx];
}


#pragma mark -
#pragma mark Actions

- (IBAction)closeTab:(id)sender {
    
}


#pragma mark -
#pragma mark Properties

- (TDTabModel *)selectedTabModel {
    return [tabModels objectAtIndex:selectedTabIndex];
}


- (TDTabViewController *)selectedTabController {
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
