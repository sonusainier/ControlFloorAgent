// Copyright (c) 2015, Facebook Inc.
// All rights reserved.
// BSD license - See LICENSE

#import <XCTest/XCTest.h>
#import "XCSynthesizedEventRecord.h"
#import "XCElementSnapshot.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XCTestManager_ManagerInterface;

/**
 Temporary class used to abstract interactions with TestManager daemon between Xcode 8.2.1 and Xcode 8.3-beta
 */
@interface XCTestDaemonsProxy : NSObject

+ (id<XCTestManager_ManagerInterface>)testRunnerProxy;

@end

NS_ASSUME_NONNULL_END
