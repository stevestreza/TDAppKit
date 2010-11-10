//
//  TDTabListItem.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabListItem.h>

@implementation TDTabListItem

+ (CGFloat)defaultHeight {
    return 10.0;
}


+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}


- (void)dealloc {
    self.title = nil;
    [super dealloc];
}

@synthesize title;
@end
