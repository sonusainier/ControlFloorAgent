#import "XCUIApplication+Helpers.h"
#import "XCAXClient_iOS+Helpers.h"
@implementation XCUIApplication (Helpers)

+ ( XCUIApplicationProcess * ) appProcessWithPID:(NSInteger)pid {
  XCAXClient_iOS *axClient = XCAXClient_iOS.sharedClient;
  return [axClient appProcessWithPID:pid];
}

@end
