// class-dump results processed by bin/class-dump/dump.rb
//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Nov 26 2020 14:08:26).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <XCTest/XCUIElementTypes.h>
#import "CDStructures.h"
@protocol OS_dispatch_queue;
@protocol OS_xpc_object;

@class NSArray, NSDictionary, NSError, NSString;

@protocol XCTMessagingRole_UIAutomation
- (id)_XCT_didBeginInitializingForUITesting;
- (id)_XCT_getProgressForLaunch:(id)arg1;
- (id)_XCT_initializationForUITestingDidFailWithError:(NSError *)arg1;
- (id)_XCT_launchProcessWithPath:(NSString *)arg1 bundleID:(NSString *)arg2 arguments:(NSArray *)arg3 environmentVariables:(NSDictionary *)arg4;
- (id)_XCT_terminateProcess:(id)arg1;
@end

