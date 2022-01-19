#import "XCUIApplication+Helpers.h"
#import "XCAXClient_iOS+Helpers.h"
#import "XCUIApplicationProcessTracker-Protocol.h"
@implementation XCUIApplication (Helpers)

+ ( XCUIApplicationProcess * ) appProcessWithPID:(NSInteger)pid {
  XCAXClient_iOS *axClient = XCAXClient_iOS.sharedClient;

  XCUIApplicationProcess *appProcess = [axClient appProcessWithPID:pid];

  if( appProcess == nil ){
      id<XCUIApplicationProcessTracker> tracker = axClient.applicationProcessTracker;
      id<XCUIElementSnapshotApplication> snapshotApp = [tracker monitoredApplicationWithProcessIdentifier:pid];
      appProcess = (XCUIApplicationProcess *) snapshotApp;
  }

  return appProcess;
}

@end
