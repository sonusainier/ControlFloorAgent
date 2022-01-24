#import "XCTRunnerDaemonSession.h"
@interface XCTRunnerDaemonSession (Helpers)

- (XCUIApplication *) appWithPID:(NSInteger)pid;

@end
