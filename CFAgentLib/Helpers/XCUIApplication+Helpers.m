#import "XCUIApplication+Helpers.h"
#import "XCAXClientproxy.h"
@implementation XCUIApplication (Helpers)

+ (XCUIApplication*) newWithPID:(pid_t)pid {
  if( [XCUIApplication respondsToSelector:@selector(appWithPID:)] )
    return [XCUIApplication appWithPID:pid];
  if( [XCUIApplication respondsToSelector:@selector(applicationWithPID:)] )
    return [XCUIApplication applicationWithPID:pid];
  return [XCAXClientProxy.sharedClient monitoredApplicationWithProcessIdentifier:pid];
}

@end
