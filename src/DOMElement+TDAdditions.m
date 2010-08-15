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

#import <TDAppKit/DOMElement+TDAdditions.h>
#import <TDAppKit/DOMNodeList+TDAdditions.h>

@implementation DOMElement (TDAdditions)

- (NSString *)defaultXPath {
    NSMutableString *xpath = [NSMutableString string];
    
    DOMElement *el = self;
    DOMNode *parent = [el parentNode];
    while (parent && [el isKindOfClass:[DOMElement class]]) {
        NSString *tagName = [el nodeName];
        
        NSMutableArray *siblings = [NSMutableArray array];
        for (DOMNode *child in [[parent childNodes] asArray]) {
            if ([child isKindOfClass:[DOMElement class]] && [[child nodeName] isEqualToString:tagName]) {
                [siblings addObject:child];
            }
        }
        
        NSAssert([siblings count], @"");
        NSUInteger i = [siblings indexOfObject:el] + 1;
        NSString *s = [NSString stringWithFormat:@"/%@[%d]", tagName, i];
        [xpath insertString:s atIndex:0];
        
        el = (DOMElement *)parent;
        parent = [el parentNode];
    }
    
    return [[xpath copy] autorelease];
}


- (void)dispatchClickEvent {
    // create DOM click event
    DOMDocument *doc = [self ownerDocument];
    DOMAbstractView *window = [doc defaultView];
    DOMUIEvent *evt = (DOMUIEvent *)[doc createEvent:@"UIEvents"];
    [evt initUIEvent:@"click" canBubble:YES cancelable:YES view:window detail:1];
    [self dispatchEvent:evt];
}


- (BOOL)isTextField {
    NSString *type = [self getAttribute:@"type"];
    
    return [self isKindOfClass:[DOMHTMLInputElement class]] &&
        (![type length] || [@"text" isEqualToString:type] || [@"password" isEqualToString:type]);
}


- (BOOL)isTextArea {
    return [self isKindOfClass:[DOMHTMLTextAreaElement class]];
}


- (BOOL)isFileChooser {
    return [self isKindOfClass:[DOMHTMLInputElement class]] && [@"file" isEqualToString:[self getAttribute:@"type"]];
}


- (BOOL)isRadio {
    return [self isKindOfClass:[DOMHTMLInputElement class]] && [@"radio" isEqualToString:[self getAttribute:@"type"]];
}


- (BOOL)isCheckbox {
    return [self isKindOfClass:[DOMHTMLInputElement class]] && [@"checkbox" isEqualToString:[self getAttribute:@"type"]];
}


- (BOOL)isSelect {
    if ([self isKindOfClass:[DOMHTMLSelectElement class]]) {
        DOMHTMLSelectElement *selEl = (DOMHTMLSelectElement *)self;
        return !selEl.multiple;
    }
    return NO;
}


- (BOOL)isMultiSelect {
    if ([self isKindOfClass:[DOMHTMLSelectElement class]]) {
        DOMHTMLSelectElement *selEl = (DOMHTMLSelectElement *)self;
        return selEl.multiple;
    }
    return NO;
}

@end
