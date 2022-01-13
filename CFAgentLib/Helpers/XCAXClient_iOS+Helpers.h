#import "XCAXClient_iOS.h"

@interface XCAXClient_iOS (Helpers)

+ (instancetype) sharedClient;
- (XCUIApplicationProcess*) appProcessWithPID:(NSInteger)pid;
- (XCElementSnapshot *)cf_elSnapshot:(XCAccessibilityElement *)el
                         attributes:(NSArray<NSString *> *)atts
                           maxDepth:(NSNumber *)maxDepth
                              error:(NSError **)error;

@end
