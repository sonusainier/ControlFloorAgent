#import "XCUIApplication+Helpers.h"
#import "XCAXClient_iOS+Helpers.h"
#import "SnapshotApplication.h"
#import "XCAXClient_iOS+Helpers.h"
#import "XCAccessibilityElement.h"

@implementation XCUIApplication (Helpers)

+ ( XCUIApplicationProcess * ) appProcessWithPID:(NSInteger)pid {
  XCAXClient_iOS *axClient = XCAXClient_iOS.sharedClient;
  return [axClient appProcessWithPID:pid];
}

+ ( SnapshotApplication * ) snapshotAppWithPID:(NSInteger)pid {
  XCAXClient_iOS *axClient = XCAXClient_iOS.sharedClient;

  id<XCUIElementSnapshotApplication> snapshotApp = [axClient.applicationProcessTracker monitoredApplicationWithProcessIdentifier:pid];
  return [[SnapshotApplication alloc] init:snapshotApp];
}

+ (SnapshotApplication *) systemSnapshotApp {
  NSInteger pid = [[XCAXClient_iOS.sharedClient systemApplication] processIdentifier];
  return [XCUIApplication snapshotAppWithPID:pid];
}

@end
