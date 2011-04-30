//
//  TDRegisterWindowController.m
//  Fluid
//
//  Created by Todd Ditchendorf on 4/30/11.
//  Copyright 2011 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDRegisterWindowController.h>
#import <TDAppKit/TDHintView.h>

@interface NSObject ()
- (BOOL)registerWithLicenseAtPath:(NSString *)path;
@end

@interface TDRegisterWindowController ()
- (void)setUpTitle;
- (void)setUpHint;
- (void)handleDroppedFilenames:(NSArray *)filenames;
@end

@implementation TDRegisterWindowController

- (id)initWithAppName:(NSString *)s licenseFileExtension:(NSString *)ext {
    if (self = [super initWithWindowNibName:@"TDRegisterWindow"]) {
        self.appName = s;

        NSMutableSet *set = [NSMutableSet setWithObject:ext];
        [set addObject:@"xml"];
        [set addObject:@"plist"];
        
        self.licenseFileExtensions = [set allObjects];
    }
    return self;
}


- (void)dealloc {
    self.hintView = nil;
    self.imageView = nil;
    self.appName = nil;
    self.licenseFileExtensions = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark NSWindowController

- (void)awakeFromNib {
    [[self window] center];
    
    NSArray *types = [NSArray arrayWithObject:NSFilenamesPboardType];
    [[self window] registerForDraggedTypes:types];
    [[self imageView] registerForDraggedTypes:types];
    
    [self setUpTitle];
    [self setUpHint];
}


#pragma mark -
#pragma mark NSDragginDestination

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)dragInfo {
    NSPasteboard *pboard = [dragInfo draggingPasteboard];
    NSDragOperation mask = [dragInfo draggingSourceOperationMask];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        if (mask & NSDragOperationGeneric) {
            NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
            if ([filenames count] && [licenseFileExtensions containsObject:[[filenames objectAtIndex:0] pathExtension]]) {
                return NSDragOperationCopy;
            }
        }
    }
    
    return NSDragOperationNone;
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)dragInfo {
    NSPasteboard *pboard = [dragInfo draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
        [self performSelector:@selector(handleDroppedFilenames:) withObject:filenames afterDelay:0.0];
        return YES;
    } else {
        return NO;
    }
}


#pragma mark -
#pragma mark Private

- (void)setUpTitle {
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Register %@", @""), appName];
    [[self window] setTitle:title];
}


- (void)setUpHint {
    hintView.color = [NSColor windowBackgroundColor];
    hintView.hintTextOffsetY = 72.0;
    
    NSString *hint = [NSString stringWithFormat:NSLocalizedString(@"Drag your\n%@ license file here.", @""), appName];
    hintView.hintText = hint;
    
    [hintView setNeedsDisplay:YES];
}


- (void)handleDroppedFilenames:(NSArray *)filenames {
    if ([filenames count]) {
        NSString *filename = [filenames objectAtIndex:0];
        if ([licenseFileExtensions containsObject:[filename pathExtension]]) {
            id appDelegate = [NSApp delegate];
            if (appDelegate && [appDelegate respondsToSelector:@selector(registerWithLicenseAtPath:)]) {
                if ([appDelegate registerWithLicenseAtPath:filename]) {

                } else {
                    NSBeep();
                }
            }
        }
    }
}

@synthesize imageView;
@synthesize hintView;
@synthesize appName;
@synthesize licenseFileExtensions;
@end
