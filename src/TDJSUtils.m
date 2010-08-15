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

#import "TDJSUtils.h"

NSString *TDJSStringGetNSString(JSStringRef str) {
    return [(id)JSStringCopyCFString(NULL, str) autorelease];
}


JSStringRef TDJSStringCreateWithNSString(NSString *nsstring) {
    return JSStringCreateWithCFString((CFStringRef)nsstring);
}


JSValueRef TDCFTypeToJSValue(JSContextRef ctx, CFTypeRef value, JSValueRef *ex) {
    JSValueRef result = NULL;
    CFTypeID typeID = CFGetTypeID(value);

    if (CFNumberGetTypeID() == typeID) {
        double d;
        CFNumberGetValue(value, kCFNumberDoubleType, &d);
        result = JSValueMakeNumber(ctx, d);
    } else if (CFBooleanGetTypeID() == typeID) {
        Boolean b = CFBooleanGetValue(value);
        result = JSValueMakeBoolean(ctx, b);
    } else if (CFStringGetTypeID() == typeID) {
        result = TDCFStringToJSValue(ctx, value, ex);
    } else if (CFArrayGetTypeID() == typeID) {
        result = TDCFArrayToJSObject(ctx, value, ex);
    } else if (CFDictionaryGetTypeID() == typeID) {
        result = TDCFDictionaryToJSObject(ctx, value, ex);
    } else {
        result = JSValueMakeNull(ctx);
    }
    
    return result;
}

JSValueRef TDCFStringToJSValue(JSContextRef ctx, CFStringRef cfStr, JSValueRef *ex) {
    JSStringRef str = JSStringCreateWithCFString(cfStr);
    JSValueRef result = JSValueMakeString(ctx, str);
    JSStringRelease(str);
    return result;
}

JSValueRef TDNSStringToJSValue(JSContextRef ctx, NSString *nsStr, JSValueRef *ex) {
    return TDCFStringToJSValue(ctx, (CFStringRef)nsStr, ex);
}

JSObjectRef TDCFArrayToJSObject(JSContextRef ctx, CFArrayRef cfArray, JSValueRef *ex) {
    JSObjectRef globalObj = JSContextGetGlobalObject(ctx);
    JSStringRef className = JSStringCreateWithUTF8CString("Array");
    JSObjectRef arrayConstr = (JSObjectRef)JSObjectGetProperty(ctx, globalObj, className, NULL);
    JSStringRelease(className);
    
    JSObjectRef obj = (JSObjectRef)JSObjectCallAsConstructor(ctx, arrayConstr, 0, NULL, NULL);

    CFIndex len = 0;
    if (NULL != cfArray) {
        len = CFArrayGetCount(cfArray);
    }
    
    CFIndex i = 0;
    for ( ; i < len; i++) {
        CFTypeRef value = CFArrayGetValueAtIndex(cfArray, i);
        JSValueRef propVal = TDCFTypeToJSValue(ctx, value, ex);
        JSObjectSetPropertyAtIndex(ctx, obj, i, propVal, NULL);
    }
    
    return obj;
}

JSObjectRef TDNSArrayToJSObject(JSContextRef ctx, NSArray *nsArray, JSValueRef *ex) {
    return TDCFArrayToJSObject(ctx, (CFArrayRef)nsArray, ex);
}

JSObjectRef TDCFDictionaryToJSObject(JSContextRef ctx, CFDictionaryRef cfDict, JSValueRef *ex) {
    JSObjectRef globalObj = JSContextGetGlobalObject(ctx);
    JSStringRef className = JSStringCreateWithUTF8CString("Object");
    JSObjectRef objConstr = (JSObjectRef)JSObjectGetProperty(ctx, globalObj, className, NULL);
    JSStringRelease(className);
    
    JSObjectRef obj = (JSObjectRef)JSObjectCallAsConstructor(ctx, objConstr, 0, NULL, NULL);
    
    if (NULL != cfDict) {
        CFIndex len = CFDictionaryGetCount(cfDict);
        CFStringRef keys[len];
        CFTypeRef values[len];
        CFDictionaryGetKeysAndValues(cfDict, (const void**)keys, (const void**)values);
        
        CFIndex i = 0;
        for ( ; i < len; i++) {
            CFStringRef key = keys[i];
            CFTypeRef value = values[i];
            
            JSStringRef propName = JSStringCreateWithCFString(key);
            JSValueRef propVal = TDCFTypeToJSValue(ctx, value, ex);
            JSObjectSetProperty(ctx, obj, propName, propVal, kJSPropertyAttributeNone, NULL);
            JSStringRelease(propName);
        }
    }
    
    return obj;
}

JSObjectRef TDNSDictionaryToJSObject(JSContextRef ctx, NSDictionary *nsDict, JSValueRef *ex) {
    return TDCFDictionaryToJSObject(ctx, (CFDictionaryRef)nsDict, ex);
}

CFTypeRef TDJSValueCopyCFType(JSContextRef ctx, JSValueRef value, JSValueRef *ex) {
    CFTypeRef result = NULL;
    
    if (JSValueIsBoolean(ctx, value)) {
        Boolean b = JSValueToBoolean(ctx, value);
        result = (b ? kCFBooleanTrue : kCFBooleanFalse);
    } else if (JSValueIsNull(ctx, value)) {
        result = NULL;
    } else if (JSValueIsNumber(ctx, value)) {
        CGFloat d = JSValueToNumber(ctx, value, NULL);
        result = CFNumberCreate(NULL, kCFNumberCGFloatType, &d);
    } else if (JSValueIsString(ctx, value)) {
        result = TDJSValueCopyCFString(ctx, value, ex);
    } else if (JSValueIsObject(ctx, value)) {
        if (TDJSValueIsInstanceOfClass(ctx, value, "Array", NULL)) {
            result = TDJSObjectCopyCFArray(ctx, (JSObjectRef)value, ex);
        } else {
            result = TDJSObjectCopyCFDictionary(ctx, (JSObjectRef)value, ex);
        }
    }
    
    return result;
}

id TDJSValueGetId(JSContextRef ctx, JSValueRef value, JSValueRef *ex) {
    return [(id)TDJSValueCopyCFType(ctx, value, ex) autorelease];
}

CFStringRef TDJSValueCopyCFString(JSContextRef ctx, JSValueRef value, JSValueRef *ex) {
    JSStringRef str = JSValueToStringCopy(ctx, value, ex);
    CFStringRef result = JSStringCopyCFString(NULL, str);
    JSStringRelease(str);
    return result;
}

NSString *TDJSValueGetNSString(JSContextRef ctx, JSValueRef value, JSValueRef *ex) {
    return [(id)TDJSValueCopyCFString(ctx, value, ex) autorelease];
}

CFArrayRef TDJSObjectCopyCFArray(JSContextRef ctx, JSObjectRef obj, JSValueRef *ex) {
    JSStringRef propName = JSStringCreateWithUTF8CString("length");
    JSValueRef propVal = JSObjectGetProperty(ctx, obj, propName, NULL);
    JSStringRelease(propName);
    CFIndex len = (CFIndex)JSValueToNumber(ctx, propVal, NULL);
    
    CFMutableArrayRef cfArray = CFArrayCreateMutable(NULL, len, NULL);
    
    CFIndex i = 0;
    for ( ; i < len; i++) {
        JSValueRef val = JSObjectGetPropertyAtIndex(ctx, obj, i, NULL);
        CFTypeRef cfType = TDJSValueCopyCFType(ctx, val, ex);
        CFArraySetValueAtIndex(cfArray, i, cfType);
        
        CFRelease(cfType);
    }
    
    CFArrayRef result = CFArrayCreateCopy(NULL, cfArray);
    CFRelease(cfArray);
    
    return result;
}

CFDictionaryRef TDJSObjectCopyCFDictionary(JSContextRef ctx, JSObjectRef obj, JSValueRef *ex) {
    JSPropertyNameArrayRef propNames = JSObjectCopyPropertyNames(ctx, obj);
    CFIndex len = JSPropertyNameArrayGetCount(propNames);
    
    CFMutableDictionaryRef cfDict = CFDictionaryCreateMutable(NULL, len, NULL, NULL);
    
    CFIndex i = 0;
    for ( ; i < len; i++) {
        JSStringRef propName = JSPropertyNameArrayGetNameAtIndex(propNames, i);
        JSValueRef val = JSObjectGetProperty(ctx, obj, propName, NULL);
        CFTypeRef cfType = TDJSValueCopyCFType(ctx, val, ex);
        
        CFStringRef key = JSStringCopyCFString(NULL, propName);
        CFDictionarySetValue(cfDict, (const void *)key, (const void *)cfType);

        CFRelease(key);
        CFRelease(cfType);
    }
    
    JSPropertyNameArrayRelease(propNames);
    CFDictionaryRef result = CFDictionaryCreateCopy(NULL, cfDict);
    CFRelease(cfDict);
    
    return result;
}

JSObjectRef TDNSErrorToJSObject(JSContextRef ctx, NSError *nsErr, JSValueRef *ex) {
    JSObjectRef globalObj = JSContextGetGlobalObject(ctx);
    JSStringRef className = JSStringCreateWithUTF8CString("Error");
    JSObjectRef errConstr = (JSObjectRef)JSObjectGetProperty(ctx, globalObj, className, ex);
    JSStringRelease(className);
    
    JSObjectRef obj = (JSObjectRef)JSObjectCallAsConstructor(ctx, errConstr, 0, NULL, ex);
    
    if (nsErr) {
        JSStringRef nameStr = JSStringCreateWithUTF8CString("ParseKitError");
        JSValueRef name = JSValueMakeString(ctx, nameStr);
        JSStringRelease(nameStr);
        
        JSStringRef msgStr = JSStringCreateWithCFString((CFStringRef)[nsErr localizedDescription]);
        JSValueRef msg = JSValueMakeString(ctx, msgStr);
        JSStringRelease(msgStr);
        
        JSValueRef code = JSValueMakeNumber(ctx, [nsErr code]);
        
        JSStringRef propName = JSStringCreateWithUTF8CString("name");
        JSObjectSetProperty(ctx, obj, propName, name, kJSPropertyAttributeReadOnly|kJSPropertyAttributeDontDelete, ex);
        JSStringRelease(propName);
        
        propName = JSStringCreateWithUTF8CString("message");
        JSObjectSetProperty(ctx, obj, propName, msg, kJSPropertyAttributeReadOnly|kJSPropertyAttributeDontDelete, ex);
        JSStringRelease(propName);
        
        propName = JSStringCreateWithUTF8CString("code");
        JSObjectSetProperty(ctx, obj, propName, code, kJSPropertyAttributeReadOnly|kJSPropertyAttributeDontDelete, ex);
        JSStringRelease(propName);
    }
    
    return obj;
}

bool TDJSValueIsInstanceOfClass(JSContextRef ctx, JSValueRef value, char *className, JSValueRef* ex) {
    JSObjectRef globalObj = JSContextGetGlobalObject(ctx);
    JSStringRef classNameStr = JSStringCreateWithUTF8CString(className);
    JSObjectRef constr = (JSObjectRef)JSObjectGetProperty(ctx, globalObj, classNameStr, ex);
    JSStringRelease(classNameStr);
    
    return JSValueIsInstanceOfConstructor(ctx, value, constr, NULL);
}

JSValueRef TDEvaluateScript(JSGlobalContextRef ctx, NSString *script, NSString *sourceURLString, NSString **outErrMsg) {
    JSValueRef result = NULL;
    
    // get context
    if (!ctx) {
        ctx = JSGlobalContextCreate(NULL);
    }
    
    JSStringRef scriptStr = JSStringCreateWithCFString((CFStringRef)script);
    
    // setup source url string
    JSStringRef sourceURLStr = NULL;
    if ([sourceURLString length]) {
        sourceURLStr = JSStringCreateWithCFString((CFStringRef)sourceURLString);
    }
    
    // check syntax
    JSValueRef e = NULL;
    JSCheckScriptSyntax(ctx, scriptStr, sourceURLStr, 0, &e);
    
    // if syntax error...
    if (e) {
        if (outErrMsg) {
            NSString *msg = TDJSValueGetNSString(ctx, e, NULL);
            *outErrMsg = [NSString stringWithFormat:NSLocalizedString(@"JavaScript syntax error:\n\n%@", @""), msg];
            NSLog(@"%@", *outErrMsg);
        }
        goto done;
    }
    
    // eval the script
    result = JSEvaluateScript(ctx, scriptStr, NULL, sourceURLStr, 0, &e);
    if (e) {
        if (outErrMsg) {
            NSString *msg = TDJSValueGetNSString(ctx, e, NULL);
            *outErrMsg = [NSString stringWithFormat:NSLocalizedString(@"JavaScript runtime error:\n\n%@", @""), msg];
            NSLog(@"%@", *outErrMsg);
        }
        goto done;
    }
    
    // memory management
done:
    if (scriptStr) JSStringRelease(scriptStr);
    if (sourceURLStr) JSStringRelease(sourceURLStr);
            
    return result;
}

BOOL TDBooleanForScript(JSGlobalContextRef ctx, NSString *script, NSString *sourceURLString, NSString **outErrMsg) {
    // wrap source in boolean cast
    NSString *fmt = @"(function(){return Boolean(%@)})();";
    script = [NSString stringWithFormat:fmt, script];
    
    JSValueRef res = TDEvaluateScript(ctx, script, sourceURLString, outErrMsg);
    
    // convert result to boolean
    BOOL result = NO;
    if (res) {
        result = JSValueToBoolean(ctx, res);
    }

    return result;
}


