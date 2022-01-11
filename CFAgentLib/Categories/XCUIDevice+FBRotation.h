// Copyright (c) 2015, Facebook Inc.
// All rights reserved.
// BSD license - See LICENSE

#import <XCTest/XCTest.h>
#import <CFAgentLib/FBApplication.h>

NS_ASSUME_NONNULL_BEGIN

#if !TARGET_OS_TV
@interface XCUIDevice (FBRotation)

/*! The UIDeviceOrientation to rotation mappings */
@property (strong, nonatomic, readonly) NSDictionary *fb_rotationMapping;

@end
#endif

NS_ASSUME_NONNULL_END
