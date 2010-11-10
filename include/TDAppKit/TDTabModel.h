//
//  TDTabModel.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TDTabModel : NSObject {
    NSImage *image;
    NSImage *scaledImage;
    NSString *title;
    NSString *URLString;
    NSInteger index;
    CGFloat estimatedProgress;
    BOOL loading;
    BOOL selected;
    NSUInteger changeCount;
    BOOL needsNewImage;
}

+ (TDTabModel *)tabModelFromPlist:(NSDictionary *)plist;

- (NSDictionary *)plist;

- (BOOL)wantsNewImage;
- (void)setNeedsNewImage:(BOOL)yn;

@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) NSImage *scaledImage;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *URLString;
@property (nonatomic) NSInteger index;
@property (nonatomic) CGFloat estimatedProgress;
@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic, getter=isSelected) BOOL selected;
@end
