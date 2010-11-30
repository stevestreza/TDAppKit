//
//  TDTabbedWindow.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/12/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDTabbedWindow.h"
#import "TDTabbedDocument.h"

@implementation TDTabbedWindow

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);    
    [super dealloc];
}


- (IBAction)performClose:(id)sender {
    [super performClose:sender];
//    [[[self windowController] document] performClose:sender];
}


- (void)close {
    [[[self windowController] document] close];
}

@end
