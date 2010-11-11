//
//  TDTabbedDocumentController.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabbedDocumentController.h>
#import <TDAppKit/TDTabbedDocument.h>

@implementation TDTabbedDocumentController

- (IBAction)toggleFullScreen:(id)sender {
    TDTabbedDocument *doc = [self frontDocument];
    if (!doc) {
        doc = [self openUntitledDocumentAndDisplay:YES error:nil];
    }
    NSWindow *win = [[[doc windowControllers] objectAtIndex:0] window];
    NSView *v = [win contentView];
    if ([v isInFullScreenMode]) {
        [v exitFullScreenModeWithOptions:nil];
        [self didExitFullScreenMode];
    } else {
        [self willEnterFullScreenMode];
        NSDictionary *opts = [self fullScreenOptions];
        [v enterFullScreenMode:[win screen] withOptions:opts];
    }
}


- (IBAction)newTab:(id)sender {
    [self newDocument:sender];
}


- (id)frontDocument {
    // despite what the docs say, -currentDocument does not return a document if it is main but not key. dont trust it. :(
    //return (FUDocument *)[self currentDocument];
    
    for (NSWindow *win in [NSApp orderedWindows]) {
        NSDocument *doc = [self documentForWindow:win];
        if (doc && [doc isKindOfClass:[TDTabbedDocument class]]) {
            return doc;
        }
    }
    return nil;
}


- (NSDictionary *)fullScreenOptions {
    return nil;
}


- (void)willEnterFullScreenMode {
    
}


- (void)didExitFullScreenMode {
    
}

@end
