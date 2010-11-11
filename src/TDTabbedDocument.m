//
//  TDTabbedDocument.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabbedDocument.h>
#import <TDAppKit/TDTabModel.h>
#import <TDAppKit/TDTabViewController.h>

static NSMutableDictionary *sDocuments = nil;

@interface TDTabbedDocument ()
+ (TDTabbedDocument *)documentForIdentifier:(NSString *)identifier;
+ (void)addDocument:(TDTabbedDocument *)doc;
+ (void)removeDocument:(TDTabbedDocument *)doc;
+ (NSString *)nextUniqueID;

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, retain) NSMutableArray *models;
@property (nonatomic, retain, readwrite) TDTabModel *selectedTabModel;
@end

@implementation TDTabbedDocument

+ (void)initialize {
    if ([TDTabbedDocument class] == self) {
        sDocuments = [[NSMutableDictionary alloc] init];
    }
}

                      
+ (TDTabbedDocument *)documentForIdentifier:(NSString *)identifier {
    NSParameterAssert([identifier length]);
    TDTabbedDocument *doc = nil;
    @synchronized (sDocuments) {
        doc = [sDocuments objectForKey:identifier];
    }
    NSAssert(doc, @"");
    return doc;
}              


+ (void)addDocument:(TDTabbedDocument *)doc {
    @synchronized (sDocuments) {
        [sDocuments setObject:doc forKey:doc.identifier];
    }
}


+ (void)removeDocument:(TDTabbedDocument *)doc {
    @synchronized (sDocuments) {
        [sDocuments removeObjectForKey:doc.identifier];
    }
}


+ (NSString *)nextUniqueID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *s = [(id)CFUUIDCreateString(NULL, uuid) autorelease];
    CFRelease(uuid);
    return s;
}


- (id)init {
    if (self = [super init]) {
        self.identifier = [[self class] nextUniqueID];
        [[self class] addDocument:self];
        
        self.models = [NSMutableArray array];
        self.tabViewControllers = [NSMutableArray array];
        selectedTabIndex = NSNotFound;
    }
    return self;
}


- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [[self class] removeDocument:self];
    
    self.models = nil;
    self.tabViewControllers = nil;
    self.selectedTabModel = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark NSDocument

- (void)makeWindowControllers {

}


- (void)shouldCloseWindowController:(NSWindowController *)wc delegate:(id)delegate shouldCloseSelector:(SEL)sel contextInfo:(void *)ctx {
    [super shouldCloseWindowController:wc delegate:delegate shouldCloseSelector:sel contextInfo:ctx];
}


- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)sel contextInfo:(void *)ctx {
    [super canCloseDocumentWithDelegate:delegate shouldCloseSelector:sel contextInfo:ctx];
}


#pragma mark -
#pragma mark Actions

- (IBAction)closeTab:(id)sender {
    [self removeTabModelAtIndex:self.selectedTabIndex];
}


- (IBAction)closeWindow:(id)sender {
    [self close];
}


- (IBAction)newTab:(id)sender {
    NSUInteger i = [models count];
    [self addTabModelAtIndex:[models count]];
    self.selectedTabIndex = i;
}


- (IBAction)newBackgroundTab:(id)sender {
    [self addTabModelAtIndex:[models count]];
}


#pragma mark -
#pragma mark Public

- (void)addTabModelAtIndex:(NSUInteger)i {
    // create model
    TDTabModel *tm = [[[TDTabModel alloc] init] autorelease];
    [self addTabModel:tm atIndex:i];
}


- (void)addTabModel:(TDTabModel *)tm atIndex:(NSUInteger)i {
    NSParameterAssert(tm);
    NSParameterAssert(NSNotFound != i && i >= 0 && i <= [models count]);
    
    // set index
    tm.index = i;
    
    // create viewController
    TDTabViewController *tvc = [[self newTabViewController] autorelease];
    tvc.tabModel = tm;
    
    // add or insert
    BOOL isAppend = (i == [models count]);
    if (isAppend) {
        [models addObject:tm];
        [tabViewControllers addObject:tvc];
    } else {
        [models insertObject:tm atIndex:i];
        [tabViewControllers insertObject:tvc atIndex:i];
    }
    
    // notify
    [self didAddTabModel:tm];
}


- (void)removeTabModelAtIndex:(NSUInteger)i {
    NSParameterAssert(NSNotFound != i && i >= 0 && i <= [models count]);

    NSUInteger c = [models count];

    if (1 == c) {
        [self closeWindow:nil];
        return;
    }
    
    NSUInteger newIndex = i;
    if (i == c - 1) {
        newIndex--;
    }
    
    //TDTabModel *tm = 
    [[[models objectAtIndex:i] retain] autorelease];
    [models removeObjectAtIndex:i];
    
    TDTabViewController *tvc = [[[tabViewControllers objectAtIndex:i] retain] autorelease];
    [[tvc view] removeFromSuperview]; // ?? 
    [tabViewControllers removeObjectAtIndex:i];
    
    self.selectedTabIndex = newIndex;
}


- (void)removeTabModel:(TDTabModel *)tm {
    [self removeTabModelAtIndex:[models indexOfObject:tm]];
}


- (TDTabModel *)tabModelAtIndex:(NSUInteger)i {
    return [models objectAtIndex:i];
}


- (NSUInteger)indexOfTabModel:(TDTabModel *)tm {
    return [models indexOfObject:tm];
}


#pragma mark -
#pragma mark Subclass

- (void)didAddTabModel:(TDTabModel *)tm {
    
}


- (void)willRemoveTabModel:(TDTabModel *)tm {
    
}


- (void)selectedTabIndexWillChange {
    
}


- (void)selectedTabIndexDidChange {
    
}


- (TDTabViewController *)newTabViewController {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return nil;
}


#pragma mark -
#pragma mark TDTabsListViewControllerDelegate

- (NSUInteger)numberOfTabsInTabsViewController:(TDTabsListViewController *)tvc {
    NSUInteger c = [models count];
    return c;
}


- (TDTabModel *)tabsViewController:(TDTabsListViewController *)tvc tabModelAtIndex:(NSUInteger)i {
    TDTabModel *tabModel = [models objectAtIndex:i];
    return tabModel;
}


- (NSMenu *)tabsViewController:(TDTabsListViewController *)tvc contextMenuForTabModelAtIndex:(NSUInteger)i {
    return nil;
}


- (void)tabsViewController:(TDTabsListViewController *)tvc didSelectTabModelAtIndex:(NSUInteger)i {
    self.selectedTabIndex = i;
}


- (void)tabsViewController:(TDTabsListViewController *)tvc didCloseTabModelAtIndex:(NSUInteger)i {
    [self removeTabModelAtIndex:i];
}


- (void)tabsViewControllerWantsNewTab:(TDTabsListViewController *)tvc {
    [self newTab:nil];
}


#pragma mark -
#pragma mark Properties

- (NSArray *)tabModels {
    return [[models copy] autorelease];
}


- (TDTabViewController *)selectedTabViewController {
    return [tabViewControllers objectAtIndex:selectedTabIndex];
}


- (void)setSelectedTabIndex:(NSUInteger)i {
    //if (selectedTabIndex != i) {
        [self willChangeValueForKey:@"selectedTabIndex"];

        [self selectedTabIndexWillChange];
        
        selectedTabModel.selected = NO;

        selectedTabIndex = i;
        
        TDTabModel *tm = nil;
        if (NSNotFound != selectedTabIndex) {
            tm = [models objectAtIndex:selectedTabIndex];
            tm.selected = YES;
        }
        self.selectedTabModel = tm;

        [self selectedTabIndexDidChange];
        
        [self didChangeValueForKey:@"selectedTabIndex"];
    //}
}

@synthesize identifier;
@synthesize models;
@synthesize tabViewControllers;
@synthesize selectedTabIndex;
@synthesize selectedTabModel;
@end
