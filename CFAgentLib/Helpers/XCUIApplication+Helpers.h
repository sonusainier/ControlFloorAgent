#import "XCUIApplication.h"

@interface XCUIApplication (Helpers)

+ (XCUIApplication*) newWithPID:(pid_t)pid;

@end
