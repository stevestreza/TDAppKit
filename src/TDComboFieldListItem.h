//
//  TDComboFieldListItem.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 4/9/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDListItem.h>

@interface TDComboFieldListItem : TDListItem {
    NSString *labelText;
    BOOL selected;
    BOOL first;
    BOOL last;
    CGFloat labelMarginLeft;
}

+ (NSString *)reuseIdentifier;
+ (CGFloat)defaultHeight;

- (NSRect)labelRectForBounds:(NSRect)bounds;

@property (nonatomic, copy) NSString *labelText;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isFirst) BOOL first;
@property (nonatomic, getter=isLast) BOOL last;
@property (nonatomic) CGFloat labelMarginLeft;
@end
