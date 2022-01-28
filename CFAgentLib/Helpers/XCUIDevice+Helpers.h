//  Copyright © 2021 DryArk LLC. All rights reserved.
//  Cooperative License ( LICENSE_DRYARK )
#pragma once

#import <XCTest/XCTest.h>
#import "XCPointerEventPath.h"

@interface XCUIDevice (Helpers)

@property (readonly) id accessibilityInterface;

- (void)runEventPath:(XCPointerEventPath*)path;
- (void)cf_tap:(CGFloat)x y:(CGFloat)y;
- (void)cf_doubletap:(XCUIElement *)el x:(CGFloat)x y:(CGFloat)y;
- (void)cf_mouseDown:(CGFloat)x y:(CGFloat)y;
- (void)cf_mouseUp:(CGFloat)x y:(CGFloat)y;
- (void)cf_tapTime:(CGFloat)x y:(CGFloat)y time:(CGFloat)time;
- (void)cf_tapFirm:(CGFloat)x y:(CGFloat)y pressure:(CGFloat)pressure;
- (void)cf_swipe:(CGFloat)x1 y1:(CGFloat)y1 x2:(CGFloat)x2 y2:(CGFloat)y2 delay:(CGFloat)delay;
- (void)cf_holdHomeButtonForDuration:(CGFloat)dur;
#if TARGET_OS_TV
- (void)cf_remotePressButton:(NSUInteger)button;
- (void)cf_remotePressButton:(NSUInteger)button forDuration:(CGFloat)dur;
#endif
- (BOOL)cf_iohid:(unsigned int)page
                               usage:(unsigned int)usage
                            duration:(NSTimeInterval)duration
                               error:(NSError **)error;
- (BOOL)cf_iohid_with_modifier:(unsigned int)page
           usage:(unsigned int)usage
        duration:(NSTimeInterval)duration
        modifier:(XCUIKeyModifierFlags)flags
           error:(NSError **)error;
- (NSString *)cf_startBroadcastApp;

- (void)cf_typeKey:(XCUIApplication *)app;


//LT Changes Start
/**
 Start extension with bundle ID
 */
- (NSString *)LT_startStream;

/**
 Open URL in Browser
 */
- (NSString *)LT_openUrl:(NSString *)url;

/**
 Clean Safari Data
 */
- (BOOL)LT_cleanBrowser:(NSString *)bid;

//LT Changes End
@end
