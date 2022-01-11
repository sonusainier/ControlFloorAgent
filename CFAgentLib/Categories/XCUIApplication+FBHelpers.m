// Copyright (c) 2015, Facebook Inc.
// All rights reserved.
// BSD license - See LICENSE

#import "XCUIApplication+FBHelpers.h"
#import "VersionMacros.h"
#import "XCTestDaemonsProxy.h"
#import "XCAXClientProxy.h"
#import "XCAccessibilityElement.h"
#import "XCUIDevice+FBHelpers.h"
#import "XCTestManager_ManagerInterface-Protocol.h"
#import "XCTestPrivateSymbols.h"
#import "XCTRunnerDaemonSession.h"

static NSString* const FBUnknownBundleId = @"unknown";

@implementation XCUIApplication (FBHelpers)

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
    id<XCTestManager_ManagerInterface> proxy = [XCTestDaemonsProxy testRunnerProxy];
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [proxy _XCT_exchangeProtocolVersion:testmanagerdVersion reply:^(unsigned long long code) {
      testmanagerdVersion = (NSInteger) code;
      dispatch_semaphore_signal(sem);
    }];
    dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)));
  });
  return testmanagerdVersion;
}

@end
