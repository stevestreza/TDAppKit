//
//  TDTabbedDocumentController.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TDTabbedDocumentController : NSDocumentController {

}

- (IBAction)toggleFullScreen:(id)sender;
- (IBAction)newTab:(id)sender;

- (id)frontDocument;

- (NSDictionary *)fullScreenOptions;
- (void)willEnterFullScreenMode;
- (void)didExitFullScreenMode;
@end
