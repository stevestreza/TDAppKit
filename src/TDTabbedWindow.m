//
//  TDTabbedWindow.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/12/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDTabbedWindow.h"

@implementation TDTabbedWindow

- (IBAction)performClose:(id)sender {
    [[[self windowController] document] performClose:sender];
}

@end
