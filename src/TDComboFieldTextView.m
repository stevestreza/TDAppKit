//
//  TDComboFieldTextView.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 4/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDComboFieldTextView.h"

@interface TDComboField ()
- (void)removeListWindow;
- (void)textWasInserted:(id)insertString;
@end

@implementation TDComboFieldTextView

- (id)initWithFrame:(NSRect)r {
    if (self = [super initWithFrame:r]) {

    }
    return self;
}


- (void)dealloc {
    self.comboField = nil;
    [super dealloc];
}


- (BOOL)isFieldEditor {
    return YES;
}


// <esc> was pressed. suppresses system-provided completions UI
- (NSArray *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    [comboField escape:self];
    return nil;
}


- (void)moveRight:(id)sender { [comboField removeListWindow]; [super moveRight:sender]; }
- (void)moveLeft:(id)sender { [comboField removeListWindow]; [super moveLeft:sender]; }
- (void)moveWordForward:(id)sender { [comboField removeListWindow]; [super moveWordForward:sender]; }
- (void)moveWordBackward:(id)sender { [comboField removeListWindow]; [super moveWordBackward:sender]; }
- (void)moveToBeginningOfLine:(id)sender { [comboField removeListWindow]; [super moveToBeginningOfLine:sender]; }
- (void)moveToEndOfLine:(id)sender { [comboField removeListWindow]; [super moveToEndOfLine:sender]; }
- (void)moveToBeginningOfParagraph:(id)sender { [comboField removeListWindow]; [super moveToBeginningOfParagraph:sender]; }
- (void)moveToEndOfParagraph:(id)sender { [comboField removeListWindow]; [super moveToEndOfParagraph:sender]; }
- (void)moveToEndOfDocument:(id)sender { [comboField removeListWindow]; [super moveToEndOfDocument:sender]; }
- (void)moveToBeginningOfDocument:(id)sender { [comboField removeListWindow]; [super moveToBeginningOfDocument:sender]; }
- (void)pageDown:(id)sender { [comboField removeListWindow]; [super pageDown:sender]; }
- (void)pageUp:(id)sender { [comboField removeListWindow]; [super pageUp:sender]; }
- (void)centerSelectionInVisibleArea:(id)sender { [comboField removeListWindow]; [super centerSelectionInVisibleArea:sender]; }


- (void)moveUp:(id)sender {
    [comboField moveUp:sender];
}


- (void)moveDown:(id)sender {
    [comboField moveDown:sender];
}


- (void)insertText:(id)insertString {
    [super insertText:insertString];
    [comboField textWasInserted:insertString];
}

@synthesize comboField;
@end
