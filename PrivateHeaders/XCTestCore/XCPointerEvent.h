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



@interface XCPointerEvent : NSObject <NSSecureCoding>
{
    BOOL _mergeModifierFlagsWithCurrentFlags;
    BOOL _shouldRedact;
    NSUInteger _eventType;
    NSUInteger _buttonType;
    double _pressure;
    NSUInteger _gestureStage;
    double _offset;
    double _duration;
    NSInteger _verticalLineScroll;
    NSUInteger _clickCount;
    NSUInteger _keyModifierFlags;
    NSString *_key;
    NSString *_string;
    NSUInteger _typingSpeed;
    NSUInteger _keyCode;
    NSUInteger _keyPhase;
    NSUInteger _gesturePhase;
    NSUInteger _deviceID;
    CGPoint _coordinate;
    CGPoint _destination;
    CGVector _deltaVector;
}

@property NSUInteger buttonType;
@property NSUInteger clickCount;
@property CGPoint coordinate;
@property CGVector deltaVector;
@property CGPoint destination;
@property NSUInteger deviceID;
@property double duration;
@property NSUInteger eventType;
@property NSUInteger gesturePhase;
@property NSUInteger gestureStage;
@property(copy) NSString *key;
@property NSUInteger keyCode;
@property NSUInteger keyModifierFlags;
@property NSUInteger keyPhase;
@property BOOL mergeModifierFlagsWithCurrentFlags;
@property double offset;
@property double pressure;
@property BOOL shouldRedact;
@property(copy) NSString *string;
@property NSUInteger typingSpeed;
@property NSInteger verticalLineScroll;

+ (id)dragEventWithCoordinate:(CGPoint)arg1 destination:(CGPoint)arg2 offset:(double)arg3 duration:(double)arg4;
+ (id)eventWithType:(NSUInteger)arg1 buttonType:(NSUInteger)arg2 coordinate:(CGPoint)arg3 offset:(double)arg4 clickCount:(NSUInteger)arg5;
+ (id)eventWithType:(NSUInteger)arg1 buttonType:(NSUInteger)arg2 coordinate:(CGPoint)arg3 offset:(double)arg4 duration:(double)arg5 clickCount:(NSUInteger)arg6;
+ (id)eventWithType:(NSUInteger)arg1 buttonType:(NSUInteger)arg2 coordinate:(CGPoint)arg3 pressure:(double)arg4 gestureStage:(double)arg5 offset:(double)arg6 duration:(double)arg7 clickCount:(NSUInteger)arg8 gesturePhase:(NSUInteger)arg9;
+ (id)eventWithType:(NSUInteger)arg1 buttonType:(NSUInteger)arg2 coordinate:(CGPoint)arg3 pressure:(double)arg4 offset:(double)arg5 duration:(double)arg6 clickCount:(NSUInteger)arg7;
+ (id)gestureSwipeEventWithDeltaVector:(CGVector)arg1 offset:(double)arg2 duration:(double)arg3 phase:(NSUInteger)arg4;
+ (id)keyboardEventForKeyCode:(NSUInteger)arg1 keyPhase:(NSUInteger)arg2 modifierFlags:(NSUInteger)arg3 offset:(double)arg4;
+ (id)keyboardEventForKeyCode:(NSUInteger)arg1 keyPhase:(NSUInteger)arg2 modifierFlags:(NSUInteger)arg3 offset:(double)arg4 shouldRedact:(BOOL)arg5;
+ (id)moveEventWithStartPoint:(CGPoint)arg1 destination:(CGPoint)arg2 offset:(double)arg3 duration:(double)arg4;
+ (CDUnknownBlockType)offsetComparator;
+ (id)scrollEventAtPoint:(CGPoint)arg1 lines:(NSInteger)arg2 offset:(double)arg3;
+ (id)scrollEventWithDeltaVector:(CGVector)arg1 offset:(double)arg2 duration:(double)arg3;
+ (id)textEventForKey:(id)arg1 withModifierFlags:(NSUInteger)arg2 offset:(double)arg3;
+ (id)textEventForModifierFlags:(NSUInteger)arg1 mergeWithCurrent:(BOOL)arg2 offset:(double)arg3;
+ (id)textEventForString:(id)arg1 offset:(double)arg2 typingSpeed:(NSUInteger)arg3;
+ (id)textEventForString:(id)arg1 offset:(double)arg2 typingSpeed:(NSUInteger)arg3 shouldRedact:(BOOL)arg4;

@end

