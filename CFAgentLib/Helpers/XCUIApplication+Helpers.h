#import "XCUIApplication.h"
#import "XCUIApplicationProcess.h"
@interface XCUIApplication (Helpers)

+ (XCUIApplicationProcess*) appProcessWithPID:(NSInteger)pid;

@end
