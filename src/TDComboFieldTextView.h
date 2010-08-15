//
//  TDComboFieldTextView.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 4/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDComboField.h>

@interface TDComboFieldTextView : NSTextView {
    TDComboField *comboField;
}

@property (nonatomic, assign) TDComboField *comboField;
@end
