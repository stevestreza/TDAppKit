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

//
//  NSBezierPath+PXRoundedRectangleAdditions.h
//  Pixen
//
//  Created by Andy Matuschak on 7/3/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <TDAppKit/NSBezierPath+TDAdditions.h>

@implementation NSBezierPath (TDAdditions)

+ (NSBezierPath *)bezierPathWithRoundRect:(NSRect)r radius:(CGFloat)radius corners:(TDCorner)corners {
    NSBezierPath *path = [self bezierPath];
    radius = MIN(radius, 0.5f * MIN(NSWidth(r), NSHeight(r)));
    NSRect rect = NSInsetRect(r, radius, radius);
    
    if (corners & TDCornerTopLeft) {
        [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMinY(rect)) radius:radius startAngle:180.0 endAngle:270.0];
    } else {
        NSPoint cornerPoint = NSMakePoint(NSMinX(r), NSMinY(r));
        [path appendBezierPathWithPoints:&cornerPoint count:1];
    }
    
    if (corners & TDCornerTopRight) {
        [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMinY(rect)) radius:radius startAngle:270.0 endAngle:360.0];
    } else {
        NSPoint cornerPoint = NSMakePoint(NSMaxX(r), NSMinY(r));
        [path appendBezierPathWithPoints:&cornerPoint count:1];
    }
    
    if (corners & TDCornerBottomRight) {
        [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMaxY(rect)) radius:radius startAngle:0.0 endAngle:90.0];
    } else {
        NSPoint cornerPoint = NSMakePoint(NSMaxX(r), NSMaxY(r));
        [path appendBezierPathWithPoints:&cornerPoint count:1];
    }
    
    if (corners & TDCornerBottomLeft) {
        [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMaxY(rect)) radius:radius startAngle:90.0 endAngle:180.0];
    } else {
        NSPoint cornerPoint = NSMakePoint(NSMinX(r), NSMaxY(r));
        [path appendBezierPathWithPoints:&cornerPoint count:1];
    }
    
    [path closePath];
    return path;    
}


+ (NSBezierPath *)bezierPathWithRoundRect:(NSRect)r radius:(CGFloat)radius {
    return [NSBezierPath bezierPathWithRoundRect:r radius:radius corners:TDCornersAll];
}

@end
