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

#import "XCTMessagingRole_ControlSessionInitiation-Protocol.h"
#import "XCTMessagingRole_DiagnosticsCollection-Protocol.h"
#import "XCTMessagingRole_RunnerSessionInitiation-Protocol.h"
#import "XCTMessagingRole_UIRecordingControl-Protocol.h"
#import "_XCTMessaging_VoidProtocol-Protocol.h"

@protocol XCTMessagingChannel_IDEToDaemon <XCTMessagingRole_RunnerSessionInitiation, XCTMessagingRole_ControlSessionInitiation, XCTMessagingRole_UIRecordingControl, XCTMessagingRole_DiagnosticsCollection, _XCTMessaging_VoidProtocol>

@optional
- (void)__dummy_method_to_work_around_68987191;
@end

