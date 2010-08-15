//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "DemoListItemView.h"

@interface TDListItem ()
@property (nonatomic, assign) NSUInteger index;
@end

@implementation DemoListItemView

- (void)dealloc {
    self.color = nil;
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<ListItemView %@ %d>", color, self.index];
}


- (void)drawRect:(NSRect)dirtyRect {
    [color set];
    NSRectFill([self bounds]);
 
    if (selected) {
        [[NSColor cyanColor] set];
        NSFrameRectWithWidth([self bounds], 5);
    }
}

@synthesize color;
@synthesize selected;
@end
