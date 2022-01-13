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

#import <objc/NSObject.h>

#import "XCTMetric-Protocol.h"
#import "XCTMetric_Private-Protocol.h"

@class MXMClockMetric, NSString;

@interface XCTClockMetric : NSObject <XCTMetric_Private, XCTMetric>
{
    NSString *_instrumentationName;
    MXMClockMetric *__underlyingMetric;
}

@property(retain, nonatomic) MXMClockMetric *_underlyingMetric;
@property(readonly, nonatomic) NSString *instrumentationName;

+ (id)monotonicTime;
+ (id)realTime;
- (void)didStartMeasuringAtTimestamp:(id)arg1;
- (void)didStopMeasuringAtTimestamp:(id)arg1;
- (id)initWithUnderlyingMetric:(id)arg1;
- (void)prepareToMeasureWithOptions:(id)arg1;
- (id)reportMeasurementsFromStartTime:(id)arg1 toEndTime:(id)arg2 error:(id *)arg3;
- (void)willBeginMeasuringAtEstimatedTimestamp:(id)arg1;


@end

