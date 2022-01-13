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

#import "XCTTestScheduler-Protocol.h"

@class NSMutableArray, NSMutableSet, XCTTestIdentifierSet;
@protocol OS_dispatch_queue, XCTTestSchedulerDelegate;

@interface XCTFixedPriorityTestScheduler : NSObject <XCTTestScheduler>
{
    BOOL _hasStarted;
    NSObject<OS_dispatch_queue> *_workerQueue;
    id <XCTTestSchedulerDelegate> _delegate;
    NSObject<OS_dispatch_queue> *_delegateQueue;
    NSObject<OS_dispatch_queue> *_queue;
    NSMutableArray *_undispatchedTestIdentifierGroups;
    XCTTestIdentifierSet *_testIdentifiersToSkip;
    NSMutableSet *_inFlightWorkers;
    CDUnknownBlockType _prioritizer;
    NSMutableSet *_queuedWorkers;
}

@property __weak id <XCTTestSchedulerDelegate> delegate;
@property(retain) NSObject<OS_dispatch_queue> *delegateQueue;
@property BOOL hasStarted;
@property(readonly) NSMutableSet *inFlightWorkers;
@property(readonly) CDUnknownBlockType prioritizer;
@property(readonly) NSObject<OS_dispatch_queue> *queue;
@property(readonly) NSMutableSet *queuedWorkers;
@property(retain) XCTTestIdentifierSet *testIdentifiersToSkip;
@property(retain) NSMutableArray *undispatchedTestIdentifierGroups;
@property(retain) NSObject<OS_dispatch_queue> *workerQueue;

+ (CDUnknownBlockType)classBasedLPTPrioritizerForClassTimes:(id)arg1 fallbackExecutionOrdering:(NSInteger)arg2;
- (id)initWithPrioritizer:(CDUnknownBlockType)arg1;
- (void)startWithTestIdentifiersToRun:(id)arg1 testIdentifiersToSkip:(id)arg2;
- (void)workerDidBecomeAvailable:(id)arg1;

@end

