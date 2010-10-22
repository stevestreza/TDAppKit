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

#import <TDAppKit/WebView+TDAdditions.h>
#import <TDAppKit/TDJSUtils.h>

@interface WebView (TDAdditionsPrivate)
- (JSGlobalContextRef)javaScriptContext;
- (JSValueRef)valueForEvaluatingScript:(NSString *)script error:(NSString **)outErrMsg inContext:(JSGlobalContextRef)ctx;
@end

@implementation WebView (TDAdditions)

- (JSGlobalContextRef)javaScriptContext {
    // get context
    JSGlobalContextRef ctx = [[self mainFrame] globalContext];
    if (!ctx) {
        ctx = JSGlobalContextCreate(NULL);
    }
    
    return ctx;
}

- (JSValueRef)valueForEvaluatingScript:(NSString *)script error:(NSString **)outErrMsg inContext:(JSGlobalContextRef)ctx {
    if (!ctx) {
        ctx = [self javaScriptContext];    
    }
    
    NSString *sourceURLString = [self mainFrameURL];
    
    JSValueRef result = TDEvaluateScript(ctx, script, sourceURLString, outErrMsg);
    return result;
}


- (id)cocoaValueForEvaluatingScript:(NSString *)script error:(NSString **)outErrMsg {
    JSGlobalContextRef ctx = [self javaScriptContext];
    JSValueRef val = [self valueForEvaluatingScript:script error:outErrMsg inContext:ctx];
    
    if (*outErrMsg) {
        return nil;
    }
    
    JSValueRef e = NULL;
    id result = TDJSValueGetId(ctx, val, &e);
    
    if (e) {
        if (outErrMsg) {
            NSString *msg = TDJSValueGetNSString(ctx, e, NULL);
            *outErrMsg = [NSString stringWithFormat:NSLocalizedString(@"JavaScript evaluation error:\n\n%@", @""), msg];
            NSLog(@"%@", *outErrMsg);
        }
        return nil;
    }
    
    return result;
}


- (JSValueRef)valueForEvaluatingScript:(NSString *)script error:(NSString **)outErrMsg {    
    return [self valueForEvaluatingScript:script error:outErrMsg inContext:NULL];
}


- (BOOL)javaScriptEvalsTrue:(NSString *)script error:(NSString **)outErrMsg {
    // get context
    JSGlobalContextRef ctx = [[self mainFrame] globalContext];
    
    NSString *sourceURLString = [self mainFrameURL];
    
    BOOL result = TDBooleanForScript(ctx, script, sourceURLString, outErrMsg);
    return result;
}


- (BOOL)xpathEvalsTrue:(NSString *)xpath error:(NSString **)outErrMsg {
    BOOL boolValue = NO;
    
    if ([xpath length]) {
        
        // get doc
        DOMDocument *doc = [self mainFrameDocument];
        if (!doc) {
            if (outErrMsg) {
                NSString *msg = @"Error evaling XPath expression: No DOM Document";
                NSLog(@"%@", msg);
                *outErrMsg = msg;
            }
            return NO;
        }
        
        @try {
            DOMXPathResult *result = [doc evaluate:xpath contextNode:doc resolver:nil type:DOM_BOOLEAN_TYPE inResult:nil];
            boolValue = [result booleanValue];
            
        } @catch (NSException *e) {
            if (outErrMsg) {
                NSString *msg = [NSString stringWithFormat:@"Error evaling XPath expression: %@", [e reason]];
                NSLog(@"%@", msg);
                *outErrMsg = msg;
            }
            return NO;
        }
    }
    
    return boolValue;
}


- (NSArray *)allDOMDocumentsFromFrame:(WebFrame *)frame {
    NSMutableArray *docs = [NSMutableArray array];
    
    DOMDocument *doc = [frame DOMDocument];
    if (doc) [docs addObject:doc];
    
    for (WebFrame *childFrame in [frame childFrames]) {
        [docs addObjectsFromArray:[self allDOMDocumentsFromFrame:childFrame]];
    }
    
    return docs;
}


- (NSArray *)allDOMDocuments {
    return [self allDOMDocumentsFromFrame:[self mainFrame]];
}


- (NSMutableArray *)elementsForXPath:(NSString *)xpath error:(NSString **)outErrMsg {
    NSMutableArray *result = [NSMutableArray array];
    
    if ([xpath length]) {
        for (DOMDocument *doc in [self allDOMDocuments]) {
            @try {
                DOMXPathResult *nodes = [doc evaluate:xpath contextNode:doc resolver:nil type:DOM_ORDERED_NODE_SNAPSHOT_TYPE inResult:nil];
                
                NSUInteger i = 0;
                NSUInteger count = [nodes snapshotLength];
                
                if (count) {
                    for ( ; i < count; i++) {
                        DOMNode *node = [nodes snapshotItem:i];
                        if ([node isKindOfClass:[DOMHTMLElement class]]) {
                            [result addObject:node];
                        }
                    }
                } else {
                    // this is a hack cuz sometimes the xpath `(//form)[1]` doesnt work. dunno why
                    SEL sel = NULL;
                    NSString *formsPrefix = @"(//form)[";
                    NSString *linksPrefix = @"(//*[href])[";
                    //NSString *anchorsPrefix = @"(//a)[";
                    //NSString *imagesPrefix = @"(//img)[";
                    
                    NSString *prefix = nil;
                    if ([xpath hasPrefix:formsPrefix]) {
                        prefix = formsPrefix;
                        sel = @selector(forms);
                    } else if ([xpath hasPrefix:linksPrefix]) {
                        prefix = linksPrefix;
                        sel = @selector(links);
                        //                } else if ([xpath hasPrefix:anchorsPrefix]) {
                        //                    prefix = anchorsPrefix;
                        //                    sel = @selector(anchors);
                        //                } else if ([xpath hasPrefix:imagesPrefix]) {
                        //                    prefix = imagesPrefix;
                        //                    sel = @selector(images);
                    }
                    
                    if (prefix && [xpath hasSuffix:@"]"]) {
                        NSScanner *scanner = [NSScanner scannerWithString:xpath];
                        if ([scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil]) {
                            NSInteger idx;
                            if ([scanner scanInteger:&idx]) {
                                [result addObject:[[(DOMHTMLDocument *)doc performSelector:sel] item:idx]];
                            }
                        }
                    }
                }
            } @catch (NSException *e) {
                NSLog(@"error evaling XPath: %@", [e reason]);
                if (outErrMsg) {
                    *outErrMsg = [e reason];
                }
                return nil;
            }
        }
    }
    
    return result;
}

@end
