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

@class NSArray, XCUITransformParameters;

__attribute__((visibility("hidden")))
@interface XCUIPointTransformationRequest : NSObject
{
    XCUITransformParameters *_transformParameters;
    CGPoint _point;
}

@property(readonly) NSArray *axParameterRepresentation;
@property(readonly) CGPoint point;
@property(readonly) XCUITransformParameters *transformParameters;

+ (id)pointTransformationRequestWithPoint:(CGPoint)arg1 parameters:(id)arg2;

@end

