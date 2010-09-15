//  Copyright 2009 Todd Ditchendorf
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

#import <TDAppKit/DOMNode+TDAdditions.h>

@implementation DOMNode (TDAdditions)

- (DOMElement *)firstAncestorOrSelfByTagName:(NSString *)tagName {
    DOMNode *curr = self;
    BOOL isStar = [tagName isEqualToString:@"*"];
    NSArray *tagNames = nil;
    if (!isStar) {
        tagNames = [tagName componentsSeparatedByString:@","];
    }
    do {
        if (DOM_ELEMENT_NODE == [curr nodeType]) {
            if ((isStar && [curr isKindOfClass:[DOMElement class]]) || [tagNames containsObject:[[curr nodeName] lowercaseString]]) {
                return (DOMElement *)curr;
            }
        }
    } while (curr = [curr parentNode]);
    
    return nil;
}


- (CGFloat)totalOffsetTop {
    DOMElement *curr = (DOMElement *)self;
    CGFloat result = 0;
    do {
        result += [curr offsetTop];
    } while ((curr = (DOMElement *)[curr offsetParent]) && [curr isKindOfClass:[DOMElement class]]);
    
    return result;
}


- (CGFloat)totalOffsetLeft {
    DOMElement *curr = (DOMElement *)self;
    CGFloat result = 0;
    do {
        result += [curr offsetLeft];
    } while ((curr = (DOMElement *)[curr offsetParent]) && [curr isKindOfClass:[DOMElement class]]);
    
    return result;
}

@end
