/**
 * Copyright (c) 2015, Facebook Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <CFAgentLib/XCUIApplication.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBApplication : XCUIApplication

/**
 Constructor used to get the system application (e.g. Springboard on iOS)
 */
+ (instancetype)fb_systemApplication;

/**
 Retrieves the list of all currently active applications
 */
+ (NSArray<FBApplication *> *)fb_activeApplications;

@end

NS_ASSUME_NONNULL_END
