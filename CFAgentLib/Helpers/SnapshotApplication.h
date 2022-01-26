#import <Foundation/Foundation.h>
#import "XCElementSnapshot-TreeManagement.h"
#import "XCElementSnapshot+Helpers.h"

@interface SnapshotApplication : NSObject

- (instancetype) init:(id<XCUIElementSnapshotApplication>)app;
- (SnapFindElResult *) findEl:(NSString *)name withTypes:(NSArray *)types;
- (SnapFindElResult *) findEl:(NSString *)name withTypeStr:(NSString *)type;

@property (nonatomic, strong) id<XCUIElementSnapshotApplication> app;

@end
