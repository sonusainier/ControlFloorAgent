// Copyright (c) 2015, Facebook Inc.
// All rights reserved.
// BSD license - See LICENSE

#import "FBApplication.h"
#import "VersionMacros.h"
//#import "FBXCodeCompatibility.h"
#import "XCTestDaemonsProxy.h"
#import "XCAccessibilityElement.h"
#import "XCUIApplication.h"
#import "XCUIApplication+FBHelpers.h"
#import "XCUIApplicationImpl.h"
#import "XCUIApplicationProcess.h"
#import "XCUIElement.h"
#import "XCUIElementQuery.h"
#import "XCAXClientProxy.h"

static const NSTimeInterval APP_STATE_CHANGE_TIMEOUT = 5.0;

@interface FBApplication ()
@end

@implementation FBApplication

/*+ (instancetype)fb_activeApplication
{
  return [self fb_activeApplicationWithDefaultBundleId:nil];
}*/

/*+ (NSArray<FBApplication *> *)fb_activeApplications
{
  NSArray<XCAccessibilityElement *> *activeApplicationElements = [XCAXClientProxy.sharedClient activeApplications];
  NSMutableArray<FBApplication *> *result = [NSMutableArray array];
  if (activeApplicationElements.count > 0) {
    for (XCAccessibilityElement *applicationElement in activeApplicationElements) {
      FBApplication *app = [FBApplication fb_applicationWithPID:applicationElement.processIdentifier];
      if (nil != app) {
        [result addObject:app];
      }
    }
  }
  return result.count > 0 ? result.copy : @[self.class.fb_systemApplication];
}*/

/*+ (instancetype)fb_systemApplication
{
  return [self fb_applicationWithPID:
   [[XCAXClientProxy.sharedClient systemApplication] processIdentifier]];
}*/

+ (instancetype)appWithPID:(pid_t)processID
{
  if ([NSProcessInfo processInfo].processIdentifier == processID) {
    return nil;
  }
  return [super appWithPID:processID];
}

+ (instancetype)applicationWithPID:(pid_t)processID
{
  if ([NSProcessInfo processInfo].processIdentifier == processID) {
    return nil;
  }
  if ([XCAXClientProxy.sharedClient hasProcessTracker]) {
    return (FBApplication *)[XCAXClientProxy.sharedClient monitoredApplicationWithProcessIdentifier:processID];
  }
  return  [super applicationWithPID:processID];
}

- (void)launch
{
  [super launch];
  //if (![self fb_waitForAppElement:APP_STATE_CHANGE_TIMEOUT]) {
    //[FBLogger logFmt:@"The application '%@' is not running in foreground after %.2f seconds", self.bundleID, APP_STATE_CHANGE_TIMEOUT];
  //}
}

- (void)terminate
{
  [super terminate];
  if (![self waitForState:XCUIApplicationStateNotRunning timeout:APP_STATE_CHANGE_TIMEOUT]) {
    //[FBLogger logFmt:@"The active application is still '%@' after %.2f seconds timeout", self.bundleID, APP_STATE_CHANGE_TIMEOUT];
  }
}

@end
