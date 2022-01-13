#import "XCTRunnerDaemonSession+Helpers.h"
#import "XCUIApplication.h"
@implementation XCTRunnerDaemonSession (Helpers)

- (XCUIApplication *) appWithPID:(NSInteger)pid {
  __block XCUIApplicationSpecifier *specifier;
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);
  [self requestApplicationSpecifierForPID:pid
                                    reply:
      ^(XCUIApplicationSpecifier *specifier2, NSError *error) {
          specifier = specifier2;
          dispatch_semaphore_signal(sem);
      }
  ];
  dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)));
  XCUIApplication *app = [XCUIApplication init];
  return [app initWithApplicationSpecifier:app
                                    device:[XCUIDevice sharedDevice]];
}

@end
