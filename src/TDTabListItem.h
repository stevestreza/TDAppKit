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
@class TDTabsListViewController;

@interface TDTabListItem : TDListItem {
    TDTabModel *tabModel;
    NSButton *closeButton;
    NSProgressIndicator *progressIndicator;
    TDTabsListViewController *tabsListViewController;
    
    NSTimer *drawHiRezTimer;
    BOOL drawHiRez;
}

+ (NSString *)reuseIdentifier;

- (void)drawHiRezLater;

@property (nonatomic, retain) TDTabModel *tabModel;
@property (nonatomic, retain) NSButton *closeButton;
@property (nonatomic, retain) NSProgressIndicator *progressIndicator;
@property (nonatomic, assign) TDTabsListViewController *tabsListViewController; // weakref
@end
