// Copyright (c) 2018, Facebook Inc.
// All rights reserved.
// BSD license - See LICENSE

#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

#if TARGET_OS_TV
@interface XCUIElement (FBTVFocuse)

/**
 Sets focus

 @param error If there is an error, upon return contains an NSError object that describes the problem.
 @return YES if the operation succeeds, otherwise NO.
 */
- (BOOL)fb_setFocusWithError:(NSError**) error;

/**
 Select a focused element

 @param error If there is an error, upon return contains an NSError object that describes the problem.
 @return YES if the operation succeeds, otherwise NO.
 */
- (BOOL)fb_selectWithError:(NSError**) error;

@end
#endif

NS_ASSUME_NONNULL_END
