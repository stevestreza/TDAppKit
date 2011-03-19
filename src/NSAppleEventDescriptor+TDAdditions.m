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

#import <TDAppKit/NSAppleEventDescriptor+TDAdditions.h>

@interface NSObject (TDAdditions)
- (FourCharCode)scriptSuiteFourCharCode;
@end

@implementation NSAppleEventDescriptor (TDAdditions)

+ (NSAppleEventDescriptor *)descriptorForOwnProcess {
    ProcessSerialNumber selfPSN = { 0, kCurrentProcess };
    return [NSAppleEventDescriptor descriptorWithDescriptorType:typeProcessSerialNumber bytes:&selfPSN length:sizeof(selfPSN)];
}


+ (NSAppleEventDescriptor *)appleEventWithFluidiumEventID:(FourCharCode)code {
    FourCharCode appCode = 'FuSS';

    if ([NSApp respondsToSelector:@selector(scriptSuiteFourCharCode)]) {
        appCode = [NSApp scriptSuiteFourCharCode];
    }

    return [self appleEventWithClass:appCode eventID:code];
}


+ (NSAppleEventDescriptor *)appleEventWithClass:(FourCharCode)class eventID:(FourCharCode)code {
    NSAppleEventDescriptor *targetDesc = [NSAppleEventDescriptor descriptorForOwnProcess];
    return [NSAppleEventDescriptor appleEventWithEventClass:class eventID:code targetDescriptor:targetDesc returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID];
}


+ (OSErr)sendVerbFirstEventWithFluidiumEventID:(FourCharCode)code {
    NSAppleEventDescriptor *aevt = [NSAppleEventDescriptor appleEventWithFluidiumEventID:code];
    return [aevt sendToOwnProcessNoReply];
}


+ (OSErr)sendVerbFirstEventWithCoreEventID:(FourCharCode)code {
    NSAppleEventDescriptor *aevt = [NSAppleEventDescriptor appleEventWithClass:'core' eventID:code];    
    return [aevt sendToOwnProcessNoReply];
}


- (OSErr)sendToOwnProcessNoReply {
    const AppleEvent *aevt = [self aeDesc];

    OSErr err = noErr; 
    err = AESendMessage(aevt, NULL, kAENoReply|kAENeverInteract, kAEDefaultTimeout);
    return err;
}


- (OSErr)sendToOwnProcessWaitReply:(AppleEvent *)replyEvt {
    const AppleEvent *aevt = [self aeDesc];
    
    OSErr err = noErr; 
    err = AESendMessage(aevt, replyEvt, kAEWaitReply|kAENeverInteract|kAECanSwitchLayer, kAEDefaultTimeout);

    //AEDisposeDesc((AEDesc *)&aevt); // don't
    return err;
}


- (NSAppleEventDescriptor *)replyEventForSendingToOwnProcess {
    AppleEvent aeReply = {0, nil};
    [self sendToOwnProcessWaitReply:&aeReply];
    
    NSAppleEventDescriptor *reply = [[[NSAppleEventDescriptor alloc] initWithAEDescNoCopy:&aeReply] autorelease];

    //AEDisposeDesc(&aeReply); // don't
    return reply;
}


@end
