/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "XCUIApplication+FBHelpers.h"

//#import "XCElementSnapshot.h"
//#import "FBElementTypeTransformer.h"
//#import "FBKeyboard.h"
//#import "FBLogger.h"
#import "FBMacros.h"
#import "FBMathUtils.h"
//#import "FBActiveAppDetectionPoint.h"
#import "FBXCodeCompatibility.h"
//#import "FBXPath.h"
#import "FBXCTestDaemonsProxy.h"
#import "FBXCAXClientProxy.h"
#import "XCAccessibilityElement.h"
//#import "XCElementSnapshot+FBHelpers.h"
#import "XCUIDevice+FBHelpers.h"
//#import "XCUIElement+FBCaching.h"
//#import "XCUIElement+FBIsVisible.h"
//#import "XCUIElement+FBUtilities.h"
//#import "XCUIElement+FBWebDriverAttributes.h"
#import "XCTestManager_ManagerInterface-Protocol.h"
#import "XCTestPrivateSymbols.h"
#import "XCTRunnerDaemonSession.h"

const static NSTimeInterval FBMinimumAppSwitchWait = 3.0;
static NSString* const FBUnknownBundleId = @"unknown";


@implementation XCUIApplication (FBHelpers)

/*+ (NSArray<NSDictionary<NSString *, id> *> *)fb_activeAppsInfo
{
  return [self fb_appsInfoWithAxElements:[FBXCAXClientProxy.sharedClient activeApplications]];
}*/

/*- (BOOL)fb_deactivateWithDuration:(NSTimeInterval)duration error:(NSError **)error
{
  if(![[XCUIDevice sharedDevice] fb_goToHomescreenWithError:error]) {
    return NO;
  }
  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:MAX(duration, FBMinimumAppSwitchWait)]];
  [self fb_activate];
  return YES;
}*/

/*- (NSString *)fb_descriptionRepresentation
{
  NSMutableArray<NSString *> *childrenDescriptions = [NSMutableArray array];
  for (XCUIElement *child in [self.fb_query childrenMatchingType:XCUIElementTypeAny].allElementsBoundByAccessibilityElement) {
    [childrenDescriptions addObject:child.debugDescription];
  }
  // debugDescription property of XCUIApplication instance shows descendants addresses in memory
  // instead of the actual information about them, however the representation works properly
  // for all descendant elements
  return (0 == childrenDescriptions.count) ? self.debugDescription : [childrenDescriptions componentsJoinedByString:@"\n\n"];
}*/

/*- (XCUIElement *)fb_activeElement
{
  return [[[self.fb_query descendantsMatchingType:XCUIElementTypeAny]
           matchingPredicate:[NSPredicate predicateWithFormat:@"hasKeyboardFocus == YES"]]
          fb_firstMatch];
}*/

#if TARGET_OS_TV
- (XCUIElement *)fb_focusedElement
{
  return [[[self.fb_query descendantsMatchingType:XCUIElementTypeAny]
           matchingPredicate:[NSPredicate predicateWithFormat:@"hasFocus == true"]]
          fb_firstMatch];
}
#endif

+ (NSInteger)fb_testmanagerdVersion
{
  static dispatch_once_t getTestmanagerdVersion;
  static NSInteger testmanagerdVersion;
  dispatch_once(&getTestmanagerdVersion, ^{
    id<XCTestManager_ManagerInterface> proxy = [FBXCTestDaemonsProxy testRunnerProxy];
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [proxy _XCT_exchangeProtocolVersion:testmanagerdVersion reply:^(unsigned long long code) {
      testmanagerdVersion = (NSInteger) code;
      dispatch_semaphore_signal(sem);
    }];
    dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)));
  });
  return testmanagerdVersion;
}

/*- (BOOL)fb_resetAuthorizationStatusForResource:(long long)resourceId error:(NSError **)error
{
  SEL selector = NSSelectorFromString(@"resetAuthorizationStatusForResource:");
  if (![self respondsToSelector:selector]) {
    return [[[FBErrorBuilder builder]
             withDescription:@"'resetAuthorizationStatusForResource' API is only supported for Xcode SDK 11.4 and later"]
            buildError:error];
  }
  NSMethodSignature *signature = [self methodSignatureForSelector:selector];
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
  [invocation setSelector:selector];
  [invocation setArgument:&resourceId atIndex:2]; // 0 and 1 are reserved
  [invocation invokeWithTarget:self];
  return YES;
}*/

@end
