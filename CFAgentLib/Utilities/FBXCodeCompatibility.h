/**
 * Copyright (c) 2015, Facebook Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <CFAgentLib/CFAgentLib.h>
#import "XCPointerEvent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The exception happends if one tries to call application method,
 which is not supported in the current iOS version
 */
extern NSString *const FBApplicationMethodNotSupportedException;

@interface XCUIApplication (FBCompatibility)

+ (nullable instancetype)fb_applicationWithPID:(pid_t)processID;

/**
 Get the state of the application. This method only returns reliable results on Xcode SDK 9+

 @return State value as enum item. See https://developer.apple.com/documentation/xctest/xcuiapplicationstate?language=objc for more details.
 */
- (NSUInteger)fb_state;

/**
 Terminate the application and wait until it disappears from the list of active apps
 */
- (void)fb_terminate;

@end

@interface XCUIElementQuery (FBCompatibility)

/**
 Returns single unique matching snapshot for the given query

 @param error The error instance if there was a failure while retrieveing the snapshot
 @returns The cached unqiue snapshot or nil if the element is stale
 */
- (nullable XCElementSnapshot *)fb_uniqueSnapshotWithError:(NSError **)error;

/**
 @returns YES if the element supports unique snapshots retrieval
 */
- (BOOL)fb_isUniqueSnapshotSupported;

@end


@interface XCPointerEvent (FBCompatibility)

- (BOOL)fb_areKeyEventsSupported;

@end

@interface XCUIElement (FBCompatibility)

/**
 Determines whether current iOS SDK supports non modal elements inlusion into snapshots

 @return Either YES or NO
 */
+ (BOOL)fb_supportsNonModalElementsInclusion;

@end

NS_ASSUME_NONNULL_END
