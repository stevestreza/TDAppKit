//
//  TDTabModel.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabModel.h>

@implementation TDTabModel

- (void)dealloc {
    self.title = nil;
    self.filePath = nil;
    [super dealloc];
}

@synthesize title;
@synthesize filePath;
@end
