// Copyright (c) 2015, Facebook Inc.
// All rights reserved.
// BSD license - See LICENSE

#import <XCTest/XCTest.h>
#import "XCElementSnapshot.h"
#import "XCAccessibilityElement.h"

NS_ASSUME_NONNULL_BEGIN

/**
 This class acts as a proxy between WDA and XCAXClient_iOS.
 Other classes are obliged to use its methods instead of directly accessing XCAXClient_iOS,
 since Apple resticted the interface of XCAXClient_iOS class since Xcode10.2
 */
@interface XCAXClientProxy : NSObject

+ (instancetype)sharedClient;

- (XCUIElement *)elementAtPoint:(int)x y:(int)y;

- (BOOL)setAXTimeout:(NSTimeInterval)timeout error:(NSError **)error;

- (NSArray<XCAccessibilityElement *> *)activeApplications;

- (XCAccessibilityElement *)systemApplication;

- (void)notifyWhenNoAnimationsAreActiveForApplication:(XCUIApplication *)application
                                                reply:(void (^)(void))reply;

- (BOOL)hasProcessTracker;

- (XCUIApplication *)monitoredApplicationWithProcessIdentifier:(int)pid;

@end

NS_ASSUME_NONNULL_END
