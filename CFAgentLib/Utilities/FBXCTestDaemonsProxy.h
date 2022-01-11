/**
 * Copyright (c) 2015, Facebook Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>
#import "XCSynthesizedEventRecord.h"
#import "XCElementSnapshot.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XCTestManager_ManagerInterface;

/**
 Temporary class used to abstract interactions with TestManager daemon between Xcode 8.2.1 and Xcode 8.3-beta
 */
@interface FBXCTestDaemonsProxy : NSObject

+ (id<XCTestManager_ManagerInterface>)testRunnerProxy;

@end

NS_ASSUME_NONNULL_END
