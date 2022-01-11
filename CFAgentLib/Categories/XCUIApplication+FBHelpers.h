/**
 * Copyright (c) 2015, Facebook Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

@class XCElementSnapshot;
@class XCAccessibilityElement;

NS_ASSUME_NONNULL_BEGIN

@interface XCUIApplication (FBHelpers)

#if TARGET_OS_TV
/**
 Returns the element, which currently focused.
 */
- (nullable XCUIElement *)fb_focusedElement;
#endif

/**
 The version of testmanagerd process  which is running on the device.

 Potentially, we can handle processes based on this version instead of iOS versions,
 iOS 10.1 -> 6
 iOS 11.0.1 -> 18
 iOS 11.4 -> 22
 iOS 12.1, 12.4 -> 26
 iOS 13.0, 13.4.1 -> 28

 tvOS 13.3 -> 28

 @return The version of testmanagerd
 */
+ (NSInteger)fb_testmanagerdVersion;

@end

NS_ASSUME_NONNULL_END
