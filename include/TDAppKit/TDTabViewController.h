//
//  TDTabController.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TDTabModel;

@interface TDTabViewController : NSViewController {
    TDTabModel *tabModel;
}

@property (nonatomic, retain) TDTabModel *tabModel;
@end
