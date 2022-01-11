// Copyright (c) 2015, Facebook Inc. All rights reserved.
// BSD license - See LICENSE

#import <XCTest/XCTest.h>
#import "XCElementSnapshot.h"
#import "XCAccessibilityElement.h"

NS_ASSUME_NONNULL_BEGIN

// Needed as Apple restricted XCAXClient_iOS since Xcode10.2
@interface XCAXClientProxy : NSObject

+ (instancetype)                        sharedClient;
- (BOOL)                                hasProcessTracker;
- (XCUIElement *)                       elementAtPoint:(int)x y:(int)y;
- (BOOL)                                setAXTimeout:(NSTimeInterval)timeout error:(NSError **)error;
- (NSArray<XCAccessibilityElement *> *) activeApplications;
- (XCAccessibilityElement *)            systemApplication;
- (XCUIApplication *)                   monitoredApplicationWithProcessIdentifier:(int)pid;

- (void)notifyWhenNoAnimationsAreActiveForApplication:(XCUIApplication *)application
                                                reply:(void (^)(void))reply;
@end

NS_ASSUME_NONNULL_END
