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

@class NSError, NSString, XCTestExpectation;

@interface XCTPromise : NSObject
{
    NSString *_promiseDescription;
    id _value;
    NSError *_error;
    XCTestExpectation *_expectation;
}

@property(retain) NSError *error;
@property(readonly) XCTestExpectation *expectation;
@property(readonly, copy) NSString *promiseDescription;
@property(readonly) struct atomic_flag promiseFulfilled;
@property(retain) id value;

- (void)fulfillWithError:(id)arg1;
- (void)fulfillWithValue:(id)arg1;
- (void)fulfillWithValue:(id)arg1 error:(id)arg2;
- (id)initWithDescription:(id)arg1;

@end

