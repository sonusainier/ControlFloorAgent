// Copyright (c) 2015, Facebook Inc.
// All rights reserved.
// BSD license - See LICENSE

#import <CFAgentLib/XCUIApplication.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBApplication : XCUIApplication

/**
 Constructor used to get the system application (e.g. Springboard on iOS)
 */
//+ (instancetype)fb_systemApplication;

/**
 Retrieves the list of all currently active applications
 */
//+ (NSArray<FBApplication *> *)fb_activeApplications;

@end

NS_ASSUME_NONNULL_END
