//
//  TDTabController.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabViewController.h>
#import <TDAppKit/TDTabModel.h>

@interface TDTabViewController ()
//- (void)startObservingTabModel:(TDTabModel *)m;
//- (void)stopObservingTabModel:(TDTabModel *)m;
@end

@implementation TDTabViewController

//- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)b{
//    if (self = [super initWithNibName:name bundle:b]) {
//        
//    }
//    return self;
//}


- (void)dealloc {
#ifdef TDDEBUG
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
#endif
    self.tabModel = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Private

//- (void)startObservingTabModel:(TDTabModel *)m {
//    if (!m) return;
//    
//    [m addObserver:self forKeyPath:@"title" options:0 context:NULL];
//}
//
//
//- (void)stopObservingTabModel:(TDTabModel *)m {
//    if (!m) return;
//    
//    [m removeObserver:self forKeyPath:@"title"];
//}


#pragma mark -
#pragma mark Properties

//- (void)setTabModel:(TDTabModel *)m {
//    if (tabModel != m) {
//        [self willChangeValueForKey:@"tabModel"];
//        
//        [self stopObservingTabModel:tabModel];
//
//        [tabModel autorelease];
//        tabModel = [m retain];
//        
//        [self startObservingTabModel:tabModel];
//        
//        [self didChangeValueForKey:@"tabModel"];
//    }
//}

@synthesize tabModel;
@end
