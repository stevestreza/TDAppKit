//
//  FooBarDemoAppDelegate.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 4/9/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TDAppKit/TDAppKit.h>

@interface ComboFieldDemoAppDelegate : NSObject <TDComboFieldDataSource, TDComboFieldDelegate> {
    IBOutlet NSWindow *window;
    IBOutlet TDComboField *comboField;
    NSArray *data;
}

@property (nonatomic, retain) TDComboField *comboField;
@property (nonatomic, retain) NSArray *data;
@end
