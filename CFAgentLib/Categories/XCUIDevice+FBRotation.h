/**
 * Copyright (c) 2015, Facebook Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>
#import <CFAgentLib/FBApplication.h>

NS_ASSUME_NONNULL_BEGIN

#if !TARGET_OS_TV
@interface XCUIDevice (FBRotation)

/*! The UIDeviceOrientation to rotation mappings */
@property (strong, nonatomic, readonly) NSDictionary *fb_rotationMapping;

@end
#endif

NS_ASSUME_NONNULL_END
