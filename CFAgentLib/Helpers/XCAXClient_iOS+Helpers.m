#import "XCAXClient_iOS+Helpers.h"
#import "XCUIApplicationProcessTracker-Protocol.h"
#import "XCUIDevice.h"
#import "XCElementSnapshot.h"

@implementation XCAXClient_iOS (Helpers)

+ (instancetype)sharedClient {
  static XCAXClient_iOS *client = nil;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    client = [XCUIDevice.sharedDevice accessibilityInterface];
  });
  return client;
}

// Weirdly it is okay to cast XCUIApplicationProcess to XCUIApplication. :|
- (XCUIApplicationProcess*) appProcessWithPID:(NSInteger)pid {
  id <XCUIApplicationProcessTracker> processTracker = self.applicationProcessTracker;
  return [processTracker applicationProcessWithPID:(int)pid];
}

- (XCElementSnapshot *)cf_elSnapshot:(XCAccessibilityElement *)el
                         attributes:(NSArray<NSString *> *)atts
                           maxDepth:(NSNumber *)maxDepth
                              error:(NSError **)error
{
  NSMutableDictionary *parameters = [self defaultParameters].mutableCopy;
  parameters[@"maxDepth"] = maxDepth;

  XCElementSnapshot *snapshot = [self requestSnapshotForElement:el
                                                     attributes:atts
                                                     parameters:parameters
                                                          error:error];
  return [snapshot valueForKey:@"_rootElementSnapshot"] ?: snapshot;
}

@end
