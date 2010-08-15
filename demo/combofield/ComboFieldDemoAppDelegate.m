//
//  FooBarDemoAppDelegate.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 4/9/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "ComboFieldDemoAppDelegate.h"

@implementation ComboFieldDemoAppDelegate

- (void)dealloc {
    self.data = nil;
    self.comboField = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    //[[window contentView] setWantsLayer:YES];
    
    self.data = [NSArray arrayWithObjects:
                 [@"Alabama" lowercaseString], 
                 [@"Alaska" lowercaseString], 
                 [@"Arizona" lowercaseString], 
                 [@"Arkansas" lowercaseString], 
                 [@"California" lowercaseString], 
                 [@"Colorado" lowercaseString], 
                 [@"Connecticut" lowercaseString], 
                 [@"Delaware" lowercaseString], 
                 [@"Florida" lowercaseString], 
                 [@"Georgia" lowercaseString], 
                 [@"Hawaii" lowercaseString], 
                 [@"Idaho" lowercaseString], 
                 [@"Illinois" lowercaseString], 
                 [@"Indiana" lowercaseString], 
                 [@"Iowa" lowercaseString], 
                 [@"Kansas" lowercaseString], 
                 [@"Kentucky" lowercaseString], 
                 [@"Louisiana" lowercaseString], 
                 [@"Maine" lowercaseString], 
                 [@"Maryland" lowercaseString], 
                 [@"Massachusetts" lowercaseString], 
                 [@"Michigan" lowercaseString], 
                 [@"Minnesota" lowercaseString], 
                 [@"Mississippi" lowercaseString], 
                 [@"Missouri" lowercaseString], 
                 [@"Montana" lowercaseString], 
                 [@"Nebraska" lowercaseString], 
                 [@"Nevada" lowercaseString], 
                 [@"New Hampshire" lowercaseString], 
                 [@"New Jersey" lowercaseString], 
                 [@"New Mexico" lowercaseString], 
                 [@"New York" lowercaseString], 
                 [@"North Carolina" lowercaseString], 
                 [@"North Dakota" lowercaseString], 
                 [@"Ohio" lowercaseString], 
                 [@"Oklahoma" lowercaseString], 
                 [@"Oregon" lowercaseString], 
                 [@"Pennsylvania" lowercaseString], 
                 [@"Rhode Island" lowercaseString], 
                 [@"South Carolina" lowercaseString], 
                 [@"South Dakota" lowercaseString], 
                 [@"Tennessee" lowercaseString], 
                 [@"Texas" lowercaseString], 
                 [@"Utah" lowercaseString], 
                 [@"Vermont" lowercaseString], 
                 [@"Virginia" lowercaseString], 
                 [@"Washington" lowercaseString], 
                 [@"West Virginia" lowercaseString], 
                 [@"Wisconsin" lowercaseString], 
                 [@"Wyoming" lowercaseString], 
                 [@"Springfield" lowercaseString],
                 [@"Indianapolis" lowercaseString],
                 [@"Des Moines" lowercaseString],
                 [@"Topeka" lowercaseString],
                 [@"Frankfort" lowercaseString],
                 [@"Baton Rouge" lowercaseString],
                 [@"Augusta" lowercaseString],
                 [@"Annapolis" lowercaseString],
                 [@"Boston" lowercaseString],
                 [@"Lansing" lowercaseString],
                 [@"St. Paul" lowercaseString],
                 [@"Jackson" lowercaseString],
                 [@"Jefferson City" lowercaseString],
                 [@"Helena" lowercaseString],
                 [@"Lincoln" lowercaseString],
                 [@"Carson City" lowercaseString],
                 [@"New Concord" lowercaseString],
                 [@"New Trenton" lowercaseString],
                 [@"New Santa Fe" lowercaseString],
                 [@"New Albany" lowercaseString],
                 [@"North Raleigh" lowercaseString],
                 [@"North Bismarck" lowercaseString],
                 [@"Columbus" lowercaseString],
                 [@"Oklahoma City" lowercaseString],
                 [@"Salem" lowercaseString],
                 [@"Harrisburg" lowercaseString],
                 [@"Rhode Providence" lowercaseString],
                 [@"South Columbia" lowercaseString],
                 [@"South Pierre" lowercaseString],
                 [@"Nashville" lowercaseString],
                 [@"Austin" lowercaseString],
                 [@"Salt Lake City" lowercaseString],
                 [@"Montpelier" lowercaseString],
                 [@"Richmond" lowercaseString],
                 [@"Olympia" lowercaseString],
                 [@"West Charleston" lowercaseString],
                 [@"Madison" lowercaseString],
                 [@"Cheyenne" lowercaseString],
                 nil];    
}


- (NSArray *)currentData {
    NSString *txt = [comboField stringValue];
    NSUInteger txtLen = [txt length];
    if (!txtLen) return nil;

    NSMutableArray *res = [NSMutableArray array];
    
    for (NSString *state in data) {
        if ([state hasPrefix:txt] && txtLen < [state length]) {
            [res addObject:state];
        }
    }
    
    return res;
}


#pragma mark -
#pragma mark TDComboFieldDataSource

- (NSUInteger)numberOfItemsInComboField:(TDComboField *)cf {
    return [[self currentData] count];
}


- (id)comboField:(TDComboField *)cf objectAtIndex:(NSUInteger)i {
    return [[self currentData] objectAtIndex:i];
}


- (NSUInteger)comboField:(TDComboField *)cf indexOfItemWithStringValue:(NSString *)string {
    NSUInteger i = 0;
    
    for (NSString *s in [self currentData]) {
        if ([s isEqualToString:string]) {
            return i;
        } else {
            i++;
        }
    }
    
    return NSNotFound;
}


- (NSString *)comboField:(TDComboField *)cf completedString:(NSString *)uncompletedString {
    
    for (NSString *s in [self currentData]) {
        if ([s hasPrefix:uncompletedString]) {
            return s;
        }
    }

    return nil;
}


#pragma mark -
#pragma mark TDComboFieldDelegate

- (BOOL)comboField:(TDComboField *)cf writeDataToPasteboard:(NSPasteboard *)pboard {
    NSURL *URL = [NSURL URLWithString:@"http://apple.com"];
    [URL writeToPasteboard:pboard];
    return YES;
}


@synthesize comboField;
@synthesize data;
@end
