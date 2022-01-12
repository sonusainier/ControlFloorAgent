// Copyright (c) 2015, Facebook Inc. All rights reserved.
// BSD license - See LICENSE_FACEBOOK_BSD

#import <XCTest/XCTest.h>
#import "XCElementSnapshot.h"
#import "XCAccessibilityElement.h"

@interface XCAXClientProxy : NSObject

+ (instancetype)                        sharedClient;
- (XCUIElement *)                       elementAtPoint:(int)x y:(int)y;
- (BOOL)                                setAXTimeout:(NSTimeInterval)timeout error:(NSError **)error;
- (NSArray<XCAccessibilityElement *> *) activeApplications;
- (XCAccessibilityElement *)            systemApplication;
- (XCUIApplication *)                   monitoredApplicationWithProcessIdentifier:(int)pid;

- (XCElementSnapshot *)snapshotForElement:(XCAccessibilityElement *)element
                               attributes:(NSArray<NSString *> *)attributes
                                 maxDepth:(NSNumber *)maxDepth
                                    error:(NSError **)error;

- (void)notifyWhenNoAnimationsAreActiveForApplication:(XCUIApplication *)application
                                                reply:(void (^)(void))reply;
@end
