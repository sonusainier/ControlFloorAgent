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

@class NSArray, XCAccessibilityElement, XCTCapabilities, XCTElementQuery, XCTSerializedTransportWrapper2;

@protocol XCTMessagingRole_UIAutomationProcess <NSObject>
- (void)attributesForElement:(XCAccessibilityElement *)arg1 attributes:(NSArray *)arg2 reply:(void (^)(NSDictionary *, NSError *))arg3;
- (void)exchangeCapabilities:(XCTCapabilities *)arg1 reply:(void (^)(XCTCapabilities *))arg2;
- (void)fetchMatchesForQuery:(XCTElementQuery *)arg1 reply:(void (^)(XCTElementQueryResults *, NSError *))arg2;
- (void)listenForRemoteConnectionViaSerializedTransportWrapper:(XCTSerializedTransportWrapper2 *)arg1 completion:(void (^)(void))arg2;
- (void)notifyWhenAnimationsAreIdle:(void (^)(NSError *))arg1;
- (void)notifyWhenMainRunLoopIsIdle:(void (^)(NSError *))arg1;
- (void)requestHostAppExecutableNameWithReply:(void (^)(NSString *))arg1;
- (void)setMallocStackLoggingWithMode:(NSInteger)arg1 reply:(void (^)(NSError *))arg2;
@end

