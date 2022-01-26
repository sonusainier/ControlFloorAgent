#import "XCElementSnapshot.h"

@interface SnapFindElResult : NSObject
@property (nonatomic, strong) XCElementSnapshot *el;
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@end

@interface XCElementSnapshot (Helpers)

- (NSMutableString *) asJson;
- (NSMutableString *) asStringViaDict;
- (SnapFindElResult *) findEl:(NSString *)ident withType:(NSArray *)types;

@end
