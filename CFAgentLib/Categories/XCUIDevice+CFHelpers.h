//
//  XCUIDevice+CFHelpers.h
//  Copyright © 2021 DryArk LLC. All rights reserved.
//  Anti-Corruption License ( AC_LICENSE.TXT )
//

#ifndef XCUIDevice_CFHelpers_h
#define XCUIDevice_CFHelpers_h

#import <XCTest/XCTest.h>
#import "XCPointerEventPath.h"

NS_ASSUME_NONNULL_BEGIN

@interface XCUIDevice (CFHelpers)

@property (readonly) id accessibilityInterface;

- (void)runEventPath:(XCPointerEventPath*)path;

- (void)cf_tap:(CGFloat)x
  y:(CGFloat)y;

- (void)cf_mouseDown:(CGFloat)x
  y:(CGFloat)y;

- (void)cf_mouseUp:(CGFloat)x
  y:(CGFloat)y;

- (void)cf_tapTime:(CGFloat)x
  y:(CGFloat) y
  time:(CGFloat) time;

- (void)cf_tapFirm:(CGFloat)x
  y:(CGFloat) y
  pressure:(CGFloat) pressure;

- (void)cf_swipe:(CGFloat)x1
  y1:(CGFloat)y1 x2:(CGFloat)x2 y2:(CGFloat)y2 delay:(CGFloat)delay;

- (void)cf_keyEvent:(id) keyId
  modifierFlags:(unsigned long long) modifierFlags;

- (BOOL)cf_iohid:(unsigned int)page
                               usage:(unsigned int)usage
                               type:(unsigned int)type
                            duration:(NSTimeInterval)duration
           error:(NSError **)error;

- (void)cf_holdHomeButtonForDuration:(CGFloat)dur;

@end

NS_ASSUME_NONNULL_END


#endif /* XCUIDevice_CFHelpers_h */
