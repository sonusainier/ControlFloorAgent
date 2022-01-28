#import "XCUIApplication.h"
#import "XCUIApplicationProcess.h"
#import "XCUIApplicationProcessTracker-Protocol.h"
#import "SnapshotApplication.h"

@interface XCUIApplication (Helpers)

+ (XCUIApplicationProcess*) appProcessWithPID:(NSInteger)pid;
+ (SnapshotApplication *) snapshotAppWithPID:(NSInteger)pid;
+ (SnapshotApplication *) systemSnapshotApp;

@end
