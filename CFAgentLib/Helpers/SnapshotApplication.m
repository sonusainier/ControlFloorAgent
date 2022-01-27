#import "SnapshotApplication.h"
#import "XCElementSnapshot-TreeManagement.h"
#import "XCElementSnapshot+Helpers.h"
#import "XCUIApplicationProcessTracker-Protocol.h"
#import "CFA.h"

@implementation SnapshotApplication

- (instancetype) init:(id<XCUIElementSnapshotApplication>)app {
    self = [super init];
    self.app = app;
    return self;
}

- (SnapFindElResult *) findEl:(NSString *)name withTypeStr:(NSString *)type {
    NSArray *types = nil;
    if( type != nil && ![type isEqual:@"any"] ) {
        types = @[ @([CFA typeNum:type]) ];
    }
    return [self findEl:name withTypes:types];
}

- (SnapFindElResult *) findEl:(NSString *)name withTypes:(NSArray *)types {
    NSError *serror = nil;
    XCElementSnapshot *snapshot = (XCElementSnapshot *) [self.app snapshotWithError:&serror];
    if( serror != nil ) {
        NSLog( @"err:%@", serror );
        return nil;
    }
    
    return [snapshot findEl:name withType:types];
}

@end
