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
#import <TDAppKit/DOMNode+TDAdditions.h>
#import <TDAppKit/DOMNodeList+TDAdditions.h>

@interface DOMElement (TDAdditionsPrivate)
- (void)dispatchUIEventWithName:(NSString *)name;
@end

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


- (void)dispatchUIEventWithName:(NSString *)name {
    // create DOM UIEvents event
    DOMDocument *doc = [self ownerDocument];
    DOMAbstractView *window = [doc defaultView];
    DOMUIEvent *evt = (DOMUIEvent *)[doc createEvent:@"UIEvents"];
    [evt initUIEvent:name canBubble:YES cancelable:YES view:window detail:1];
    [self dispatchEvent:evt];
}


- (void)dispatchClickEvent {
    [self dispatchUIEventWithName:@"click"];
}


- (void)simulateClickEvent {
//    [self dispatchUIEventWithName:@"mouseover"];
//    [self dispatchUIEventWithName:@"mousemove"];
    [self dispatchUIEventWithName:@"mousedown"];
    [self dispatchUIEventWithName:@"click"];
    [self dispatchUIEventWithName:@"mouseup"];
//    [self dispatchUIEventWithName:@"mousemove"];
//    [self dispatchUIEventWithName:@"mouseout"];
}



- (void)dispatchMouseEventType:(NSString *)type 
                    clickCount:(NSInteger)clickCount 
                       ctrlKey:(BOOL)ctrlKeyPressed 
                        altKey:(BOOL)altKeyPressed 
                      shiftKey:(BOOL)shiftKeyPressed 
                       metaKey:(BOOL)metaKeyPressed 
                        button:(NSInteger)button 
                 relatedTarget:(id)relatedTarget 
                       webView:(WebView *)webView
{
    
//    DOMDocument *doc = [self ownerDocument];

    DOMDocument *doc = [webView mainFrameDocument];
    DOMAbstractView *window = [doc defaultView];
    WebFrameView *frameView = [[webView mainFrame] frameView];
    NSView <WebDocumentView> *docView = [frameView documentView];
    
    NSRect screenRect = [[[webView window] screen] frame];
    
    CGFloat x = [self totalOffsetLeft];
    CGFloat y = [self totalOffsetTop];
    CGFloat width = [self offsetWidth];
    CGFloat height = [self offsetHeight];
    
    CGFloat clientX = x + (width / 2);
    CGFloat clientY = y + (height / 2);
    
    NSPoint screenPoint = [[webView window] convertBaseToScreen:[docView convertPointToBase:NSMakePoint(clientX, clientY)]];
    CGFloat screenX = fabs(screenPoint.x);
    CGFloat screenY = fabs(screenPoint.y);
    
    if (screenRect.origin.y >= 0) {
        screenY = screenRect.size.height - screenY;
    }
    
    DOMMouseEvent *evt = (DOMMouseEvent *)[doc createEvent:@"MouseEvents"];
    [evt initMouseEvent:type 
              canBubble:YES 
             cancelable:YES 
                   view:window 
                 detail:clickCount 
                screenX:screenX 
                screenY:screenY 
                clientX:clientX 
                clientY:clientY 
                ctrlKey:ctrlKeyPressed 
                 altKey:altKeyPressed 
               shiftKey:shiftKeyPressed 
                metaKey:metaKeyPressed 
                 button:button 
          relatedTarget:relatedTarget];
    
    // register for next page load
//    [self suspendExecutionUntilProgressFinishedWithCommand:cmd];
    
    // send event to the anchor
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
