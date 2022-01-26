#import "XCUIApplication.h"
#import "XCUIApplicationProcess.h"
#import "XCUIApplicationProcessTracker-Protocol.h"
@interface XCUIApplication (Helpers)

+ (XCUIApplicationProcess*) appProcessWithPID:(NSInteger)pid;
+ (id<XCUIElementSnapshotApplication>) snapshotAppWithPID:(NSInteger)pid;
@end
