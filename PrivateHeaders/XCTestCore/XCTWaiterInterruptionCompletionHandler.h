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

@class NSMutableSet, NSSet;

__attribute__((visibility("hidden")))
@interface XCTWaiterInterruptionCompletionHandler : NSObject
{
    CDUnknownBlockType _completion;
    NSSet *_waiters;
    NSMutableSet *_finishedWaiters;
}

@property(readonly, copy) CDUnknownBlockType completion;
@property(readonly) NSMutableSet *finishedWaiters;
@property(readonly, copy) NSSet *waiters;

- (id)initWithWaiters:(id)arg1 completion:(CDUnknownBlockType)arg2;
- (BOOL)waiterDidFinishWaiting:(id)arg1;

@end

