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

#import "_XCTestObservationPrivate-Protocol.h"

@class NSArray, NSNumber, NSString, XCTestCasePlaceholder, XCTestRun;

@protocol _XCTestObservationInternal <_XCTestObservationPrivate>

@optional
- (void)_testCase:(XCTestRun *)arg1 didMeasureValues:(NSArray *)arg2 forPerformanceMetricID:(NSString *)arg3 name:(NSString *)arg4 unitsOfMeasurement:(NSString *)arg5 baselineName:(NSString *)arg6 baselineAverage:(NSNumber *)arg7 maxPercentRegression:(NSNumber *)arg8 maxPercentRelativeStandardDeviation:(NSNumber *)arg9 maxRegression:(NSNumber *)arg10 maxStandardDeviation:(NSNumber *)arg11 file:(NSString *)arg12 line:(NSUInteger)arg13 polarity:(NSInteger)arg14;
- (void)testCasePlaceholder:(XCTestCasePlaceholder *)arg1 isUnavailableWithReason:(NSString *)arg2;
@end

