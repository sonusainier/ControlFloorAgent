//
//  XCUIDevice+CFHelpers.h
//  Copyright © 2021 DryArk LLC. All rights reserved.
//  Anti-Corruption License ( AC_LICENSE.TXT )
//

#ifndef XCUIDevice_CFHelpers_h
#define XCUIDevice_CFHelpers_h

#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface XCUIDevice (CFHelpers)

- (void)cf_tap:(CGFloat)x
  y:(CGFloat)y;

- (void)cf_swipe:(CGFloat)x1
  y1:(CGFloat)y1 x2:(CGFloat)x2 y2:(CGFloat)y2 delay:(CGFloat)delay;

- (void)cf_keyEvent:(id) keyId
  modifierFlags:(unsigned long long) modifierFlags;

- (BOOL)cf_iohid:(unsigned int)page
                               usage:(unsigned int)usage
                               type:(unsigned int)type
                            duration:(NSTimeInterval)duration
           error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END


#endif /* XCUIDevice_CFHelpers_h */
