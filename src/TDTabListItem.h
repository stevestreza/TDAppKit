//
//  TDTabListItem.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TDAppKit/TDListItem.h>

@class TDTabModel;

@interface TDTabListItem : TDListItem {
    TDTabModel *tabModel;
    NSButton *closeButton;
    NSProgressIndicator *progressIndicator;
//    FUTabsViewController *viewController;
    
    NSTimer *drawHiRezTimer;
    BOOL drawHiRez;
}

+ (CGFloat)defaultHeight;
+ (NSString *)reuseIdentifier;

- (void)drawHiRezLater;

@property (nonatomic, retain) TDTabModel *tabModel;
@property (nonatomic, retain) NSButton *closeButton;
@property (nonatomic, retain) NSProgressIndicator *progressIndicator;
//@property (nonatomic, assign) FUTabsViewController *viewController;
@end
