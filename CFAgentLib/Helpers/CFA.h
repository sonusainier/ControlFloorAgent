#import <Foundation/Foundation.h>

@interface CFA : NSObject 

+ (NSArray *) typeMap;
+ (NSDictionary *) types;
+ (NSString *) typeStr:(long)typeNum;
+ (long) typeNum:(NSString *)typeStr;

@end
