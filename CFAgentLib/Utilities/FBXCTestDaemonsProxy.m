/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBXCTestDaemonsProxy.h"

#import <objc/runtime.h>

#import "FBConfiguration.h"
#import "FBLogger.h"
#import "FBRunLoopSpinner.h"
#import "XCTestDriver.h"
#import "XCTRunnerDaemonSession.h"
#import "XCUIApplication.h"
#import "XCUIDevice.h"
#import "FBXCAXClientProxy.h"

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
  if ([FBConfiguration shouldUseSingletonTestManager]) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      [FBLogger logFmt:@"Using singleton test manager"];
      proxy = [self.class retrieveTestRunnerProxy];
    });
  } else {
    [FBLogger logFmt:@"Using general test manager"];
    proxy = [self.class retrieveTestRunnerProxy];
  }
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

#if !TARGET_OS_TV
+ (UIInterfaceOrientation)orientationWithApplication:(XCUIApplication *)application
{
  if (nil == FBXCTRunnerDaemonSessionClass ||
      [[FBXCTRunnerDaemonSessionClass sharedSession] useLegacyEventCoordinateTransformationPath]) {
    return application.interfaceOrientation;
  }
  return UIInterfaceOrientationPortrait;
}
#endif

+ (XCAccessibilityElement *)requestElementAtPoint:(CGPoint)point
{
  __block XCAccessibilityElement *returnEl = nil;
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);
  //[[FBXCTRunnerDaemonSessionClass sharedSession] requestElementAtPoint:point reply:^(XCUIElement *el, NSError *error) {
  [[self testRunnerProxy] _XCT_requestElementAtPoint:point reply:^(XCAccessibilityElement *el, NSError *error) {
    if (nil == error) {
      returnEl = el;
    }
    dispatch_semaphore_signal(sem);
  }];
  dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)));
  return returnEl;
}

+ (XCElementSnapshot *)snapshotForElement:(XCAccessibilityElement *)el
                               attributes:(NSArray *)atts
                               parameters:(NSDictionary *)params {
  /*__block XCElementSnapshot *returnSnap = nil;
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);
  //[[FBXCTRunnerDaemonSessionClass sharedSession] requestElementAtPoint:point reply:^(XCUIElement *el, NSError *error) {
  [[self testRunnerProxy] _XCT_snapshotForElement:el
                                       attributes:atts
                                       parameters:params
                                            reply:^(XCElementSnapshot *snap, NSError *error) {
    if (nil == error) {
      returnSnap = snap;
    }
    dispatch_semaphore_signal(sem);
  }];
  dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)));
  return returnSnap;*/
  NSError *err;
  XCElementSnapshot *snapshot = [FBXCAXClientProxy.sharedClient snapshotForElement:el
                                                                        attributes:atts
                                                                          maxDepth:@4
                                                                             error:&err];
  return snapshot;
}

+ (BOOL)synthesizeEventWithRecord:(XCSynthesizedEventRecord *)record error:(NSError *__autoreleasing*)error
{
  __block BOOL didSucceed = NO;
  [FBRunLoopSpinner spinUntilCompletion:^(void(^completion)(void)){
    void (^errorHandler)(NSError *) = ^(NSError *invokeError) {
      if (error) {
        *error = invokeError;
      }
      didSucceed = (invokeError == nil);
      completion();
    };
    
    if (nil == FBXCTRunnerDaemonSessionClass) {
      [[self testRunnerProxy] _XCT_synthesizeEvent:record completion:errorHandler];
    } else {
      XCEventGeneratorHandler handlerBlock = ^(XCSynthesizedEventRecord *innerRecord, NSError *invokeError) {
        errorHandler(invokeError);
      };
      if ([XCUIDevice.sharedDevice respondsToSelector:@selector(eventSynthesizer)]) {
        [[XCUIDevice.sharedDevice eventSynthesizer] synthesizeEvent:record completion:(id)^(BOOL result, NSError *invokeError) {
          handlerBlock(record, invokeError);
        }];
      } else {
        [[FBXCTRunnerDaemonSessionClass sharedSession] synthesizeEvent:record completion:^(NSError *invokeError){
          handlerBlock(record, invokeError);
        }];
      }
    }
  }];
  return didSucceed;
}

@end
