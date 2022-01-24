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

#import "XCTTestIdentifierSet.h"

@class NSSet;

__attribute__((visibility("hidden")))
@interface _XCTTestIdentifierSet_Set : XCTTestIdentifierSet
{
    NSSet *_testIdentifiers;
}

- (id)anyTestIdentifier;
- (BOOL)containsTestIdentifier:(id)arg1;
- (NSUInteger)count;
- (NSUInteger)countByEnumeratingWithState:(CDStruct_70511ce9 *)arg1 objects:(id *)arg2 count:(NSUInteger)arg3;
- (id)initWithTestIdentifiers:(const id *)arg1 count:(NSUInteger)arg2;

@end

