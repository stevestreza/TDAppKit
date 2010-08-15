//
//  ComboFieldDemoWindow.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 6/7/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "ComboFieldDemoWindow.h"

@implementation ComboFieldDemoWindow

- (void)dealloc {
    self.comboField = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    [comboField setProgress:.5];
}


- (NSText *)fieldEditor:(BOOL)createWhenNeeded forObject:(id)obj {
    if (obj == comboField) {
        return (NSTextView *)comboField.fieldEditor;
    } else {
        return [super fieldEditor:createWhenNeeded forObject:obj];
    }
}

@synthesize comboField;
@end
