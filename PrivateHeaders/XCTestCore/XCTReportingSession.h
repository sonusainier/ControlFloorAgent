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

@protocol XCTMessagingRole_TestReporting><XCTMessagingRole_ActivityReporting><_XCTMessaging_VoidProtocol, XCTReportingSessionConfiguration;

@interface XCTReportingSession : NSObject
{
    id <XCTReportingSessionConfiguration> _configuration;
    id <XCTMessagingRole_TestReporting><XCTMessagingRole_ActivityReporting><_XCTMessaging_VoidProtocol> _IDEProxy;
}

@property(readonly) id <XCTReportingSessionConfiguration> configuration;

+ (void)beginReportingSessionWithIdentifier:(id)arg1 completion:(CDUnknownBlockType)arg2;
- (void)finishWithCompletion:(CDUnknownBlockType)arg1;
- (id)initWithIDEProxy:(id)arg1 configuration:(id)arg2;
- (void)reportStarted;
- (id)reportSuiteStartedWithName:(id)arg1 atDate:(id)arg2;

@end

