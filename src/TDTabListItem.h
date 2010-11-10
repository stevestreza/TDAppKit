//
//  TDTabListItem.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TDAppKit/TDListItem.h>

@interface TDTabListItem : TDListItem {
    NSString *title;
}

+ (CGFloat)defaultHeight;
+ (NSString *)reuseIdentifier;

@property (nonatomic, copy) NSString *title;
@end
