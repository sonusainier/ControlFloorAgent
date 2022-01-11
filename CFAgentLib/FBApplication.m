// Copyright (c) 2015, Facebook Inc. All rights reserved.
// BSD license - See LICENSE

#import "FBApplication.h"
#import "VersionMacros.h"
#import "XCAccessibilityElement.h"
#import "XCUIApplication.h"
#import "XCUIApplicationImpl.h"
#import "XCUIApplicationProcess.h"
#import "XCUIElement.h"
#import "XCUIElementQuery.h"
#import "XCAXClientProxy.h"

@interface FBApplication ()
@end

@implementation FBApplication

/*+ (NSArray<FBApplication *> *)fb_activeApplications {
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

+ (instancetype)appWithPID:(pid_t)processID {
  if ([NSProcessInfo processInfo].processIdentifier == processID) {
    return nil;
  }
  return [super appWithPID:processID];
}

+ (instancetype)applicationWithPID:(pid_t)processID {
  if ([NSProcessInfo processInfo].processIdentifier == processID) {
    return nil;
  }
  if ([XCAXClientProxy.sharedClient hasProcessTracker]) {
    return (FBApplication *)[XCAXClientProxy.sharedClient monitoredApplicationWithProcessIdentifier:processID];
  }
  return  [super applicationWithPID:processID];
}

@end
