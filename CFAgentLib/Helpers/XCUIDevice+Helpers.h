// Copyright (c) 2015, Facebook Inc. All rights reserved.
// BSD license - See LICENSE

#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface XCUIDevice (Helpers)

// Returns device current wifi ip4 address
- (nullable NSString *)fb_wifiIPAddress;

// Return YES on success, NO on failure
- (BOOL)fb_pressButton:(NSString *)buttonName;

@end

NS_ASSUME_NONNULL_END
