//
//  ComboFieldDemoWindow.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 6/7/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TDAppKit/TDComboField.h>

@interface ComboFieldDemoWindow : NSWindow {
    IBOutlet TDComboField *comboField;
}

@property (nonatomic, retain) TDComboField *comboField;
@end
