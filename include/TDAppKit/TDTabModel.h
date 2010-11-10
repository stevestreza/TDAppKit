//
//  TDTabModel.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TDTabModel : NSObject {
    NSString *title;
    NSString *filePath;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *filePath;
@end
