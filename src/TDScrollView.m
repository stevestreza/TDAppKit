//
//  Adapted very slightly from BWTransparentScrollView.m
//  BWToolkit
//
//  Created by Brandon Walkin (www.brandonwalkin.com)
//  All code is provided under the New BSD license.
//

#import "TDScrollView.h"
#import "TDScroller.h"
#import "TDClipView.h"

@implementation TDScrollView

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
		//if ([self respondsToSelector:@selector(ibTester)] == NO)
        //[self setDrawsBackground:NO];
	}
	return self;
}


- (void)dealloc {
//    self.contentView = nil;
    [super dealloc];
}



+ (Class)_verticalScrollerClass {
	return [TDScroller class];
}


- (void)scrollClipView:(NSClipView *)cv toPoint:(NSPoint)newOrigin {
	if (self.suppressScrolling) {
		newOrigin.y = NSMinY([cv bounds]);
    }
	[super scrollClipView:cv toPoint:newOrigin];
}

//- (NSClipView *)contentView {
//    if (!contentView) {
//        self.contentView = [[[TDClipView alloc] initWithFrame:NSZeroRect] autorelease];
//    }
//    return contentView;
//}

//@synthesize contentView;
@synthesize suppressScrolling;
@end
