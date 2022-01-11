/**
 * Copyright (c) 2015, Facebook Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBXCTestDaemonsProxy.h"

#import <objc/runtime.h>

#import "XCTestDriver.h"
#import "XCUIApplication.h"
#import "XCUIDevice.h"
#import "FBXCAXClientProxy.h"
#import "XCTRunnerDaemonSession.h"

@implementation FBXCTestDaemonsProxy

static Class FBXCTRunnerDaemonSessionClass = nil;
static dispatch_once_t onceTestRunnerDaemonClass;
+ (void)load
{
  // XCTRunnerDaemonSession class is only available since Xcode 8.3
  dispatch_once(&onceTestRunnerDaemonClass, ^{
    FBXCTRunnerDaemonSessionClass = objc_lookUpClass("XCTRunnerDaemonSession");
  });
}

+ (id<XCTestManager_ManagerInterface>)testRunnerProxy
{
  static id<XCTestManager_ManagerInterface> proxy = nil;
  //if ([FBConfiguration shouldUseSingletonTestManager]) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      //[FBLogger logFmt:@"Using singleton test manager"];
      proxy = [self.class retrieveTestRunnerProxy];
    });
  /*} else {
    //[FBLogger logFmt:@"Using general test manager"];
    proxy = [self.class retrieveTestRunnerProxy];
  }*/
  NSAssert(proxy != NULL, @"Could not determine testRunnerProxy", proxy);
  return proxy;
}

+ (id<XCTestManager_ManagerInterface>)retrieveTestRunnerProxy
{
  if ([XCTestDriver respondsToSelector:@selector(sharedTestDriver)] &&
      [[XCTestDriver sharedTestDriver] respondsToSelector:@selector(managerProxy)]) {
    return [XCTestDriver sharedTestDriver].managerProxy;
  } else {
    return ((XCTRunnerDaemonSession *)[FBXCTRunnerDaemonSessionClass sharedSession]).daemonProxy;
  }
}

@end
