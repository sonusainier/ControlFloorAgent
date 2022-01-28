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

#import "XCTNSPredicateExpectationObject-Protocol.h"
#import "XCUIElementAttributes-Protocol.h"
#import "XCUIElementAttributesPrivate-Protocol.h"
#import "XCUIElementSnapshotProviding-Protocol.h"
#import "XCUIElementTypeQueryProvider-Protocol.h"
#import "XCUIElementTypeQueryProvider_Private-Protocol.h"
#import "XCUIScreenshotProviding-Protocol.h"

@class NSString, XCElementSnapshot, XCTLocalizableStringInfo, XCUIApplication, XCUICoordinate, XCUIElementQuery, XCUIScreen;
@protocol XCUIDevice;

@interface XCUIElement () <XCUIScreenshotProviding, XCUIElementSnapshotProviding, XCTNSPredicateExpectationObject, XCUIElementAttributesPrivate, XCUIElementTypeQueryProvider_Private, XCUIElementAttributes, XCUIElementTypeQueryProvider>

@property(readonly, nonatomic) XCUIApplication *application;
@property(readonly) BOOL bannerNotificationIsSticky;
@property(readonly, copy) XCUIElementQuery *bannerNotifications;
@property(readonly, copy) NSString *compactDescription;
@property(readonly) id <XCUIDevice> device;
@property(readonly) NSInteger displayID;
@property(readonly, copy) XCUIElement *elementBoundByAccessibilityElement;
@property(readonly, copy) XCUIElement *excludingNonModalElements;
@property(readonly) BOOL hasBannerNotificationIsStickyAttribute;
@property(readonly) BOOL hasKeyboardFocus;
@property(readonly) BOOL hasUIInterruptions;
@property(readonly, copy) XCUICoordinate *hitPointCoordinate;
@property(readonly, copy) XCUIElement *includingNonModalElements;
@property(readonly, nonatomic) NSInteger interfaceOrientation;
@property(readonly) BOOL isTopLevelTouchBarElement;
@property(readonly) BOOL isTouchBarElement;
@property(retain) XCElementSnapshot *lastSnapshot;
@property(readonly, copy) XCTLocalizableStringInfo *localizableStringInfo;
@property(readonly) double normalizedSliderPosition;
@property(readonly) XCUIElementQuery *query;
@property BOOL safeQueryResolutionEnabled;
@property(readonly) XCUIScreen *screen;

+ (BOOL)_dispatchEventWithEventBuilder:(CDUnknownBlockType)arg1 eventSynthesizer:(id)arg2 withSnapshot:(id)arg3 applicationSnapshot:(id)arg4 process:(id)arg5 error:(id *)arg6;
+ (BOOL)_isInvalidEventDuration:(double)arg1;
//+ (void)performWithKeyModifiers:(NSUInteger)arg1 block:(CDUnknownBlockType)arg2;
+ (id)standardAttributeNames;
- (BOOL)_allUIInterruptionsHandledForElementSnapshot:(id)arg1 error:(id *)arg2;
- (id)_childrenMatchingTypes:(id)arg1;
- (id)_clickElementSnapshot:(id)arg1 forDuration:(double)arg2 thenDragToElement:(id)arg3 withVelocity:(double)arg4 thenHoldFor:(double)arg5;
- (id)_debugDescriptionWithSnapshot:(id)arg1 noMatchesMessage:(id)arg2;
- (id)_descendantsMatchingTypes:(id)arg1;
- (void)_dispatchEvent:(id)arg1 eventBuilder:(CDUnknownBlockType)arg2;
- (BOOL)_dispatchEventWithEventBuilder:(CDUnknownBlockType)arg1 error:(id *)arg2;
- (BOOL)_focusValidForElementSnapshot:(id)arg1 error:(id *)arg2;
- (id)_highestNonWindowAncestorOfElement:(id)arg1 notSharedWithElement:(id)arg2;
- (id)_hitPointByAttemptingToScrollToVisibleSnapshot:(id)arg1 error:(id *)arg2;
- (id)_iOSSliderAdjustmentEventWithTargetPosition:(double)arg1 snapshot:(id)arg2 error:(id *)arg3;
- (id)_normalizedSliderPositionForSnapshot:(id)arg1 isVertical:(BOOL *)arg2 error:(id *)arg3;
- (id)_normalizedUISliderPositionForSnapshot:(id)arg1 isVertical:(BOOL *)arg2 error:(id *)arg3;
- (id)_pointsInFrame:(CGRect)arg1 numberOfTouches:(NSUInteger)arg2;
- (void)_pressWithPressure:(double)arg1 pressDuration:(double)arg2 holdDuration:(double)arg3 releaseDuration:(double)arg4 activityTitle:(id)arg5;
- (BOOL)_shouldDispatchEvent:(id *)arg1;
- (void)_swipe:(NSUInteger)arg1 withVelocity:(double)arg2;
- (void)_tapWithNumberOfTaps:(NSUInteger)arg1 numberOfTouches:(NSUInteger)arg2 activityTitle:(id)arg3;
- (BOOL)_waitForExistenceWithTimeout:(double)arg1;
- (BOOL)_waitForHittableWithTimeout:(double)arg1;
- (BOOL)_waitForNonExistenceWithTimeout:(double)arg1;
- (void)adjustToNormalizedSliderPosition:(double)arg1;
- (void)adjustToPickerWheelValue:(id)arg1;
//- (id)childrenMatchingType:(NSUInteger)arg1;
- (void)click;
- (void)clickForDuration:(double)arg1;
- (void)clickForDuration:(double)arg1 thenDragToElement:(id)arg2;
- (void)clickForDuration:(double)arg1 thenDragToElement:(id)arg2 withVelocity:(double)arg3 thenHoldForDuration:(double)arg4;
//- (id)coordinateWithNormalizedOffset:(CGVector)arg1;
//- (id)descendantsMatchingType:(NSUInteger)arg1;
- (void)doubleClick;
- (void)doubleTap;
- (BOOL)evaluatePredicateForExpectation:(id)arg1 debugMessage:(id *)arg2;
- (BOOL)existsNoRetry;
- (void)forcePress;
- (void)handleUIInterruptions;
- (void)hover;
- (id)initWithElementQuery:(id)arg1;
- (id)makeNonExistenceExpectation;
- (void)pinchWithScale:(double)arg1 velocity:(double)arg2;
- (void)pressForDuration:(double)arg1;
- (void)pressForDuration:(double)arg1 thenDragToElement:(id)arg2;
- (void)pressForDuration:(double)arg1 thenDragToElement:(id)arg2 withVelocity:(double)arg3 thenHoldForDuration:(double)arg4;
- (void)pressWithPressure:(double)arg1 duration:(double)arg2;
- (void)resolveOrRaiseTestFailure;
- (BOOL)resolveOrRaiseTestFailure:(BOOL)arg1 error:(id *)arg2;
- (void)rightClick;
- (void)rotate:(double)arg1 withVelocity:(double)arg2;
- (id)screenshot;
- (id)screenshotAttachment;
- (id)screenshotAttachmentWithName:(id)arg1 lifetime:(NSInteger)arg2;
- (id)screenshotWithEncoding:(id)arg1;
- (void)scrollByDeltaX:(double)arg1 deltaY:(double)arg2;
//- (nullable id<XCUIElementSnapshot>)snapshotWithError:(id *)arg1;
- (void)swipeDown;
- (void)swipeDownWithVelocity:(double)arg1;
- (void)swipeLeft;
- (void)swipeLeftWithVelocity:(double)arg1;
- (void)swipeRight;
- (void)swipeRightWithVelocity:(double)arg1;
- (void)swipeUp;
- (void)swipeUpWithVelocity:(double)arg1;
- (void)tap;
- (void)tapOrClick;
- (void)tapWithNumberOfTaps:(NSUInteger)arg1 numberOfTouches:(NSUInteger)arg2;
- (NSUInteger)traits;
- (void)tripleClick;
- (void)twoFingerTap;
//- (void)typeText:(id)arg1;
//- (void)typeKey:(NSString *)key modifierFlags:(XCUIKeyModifierFlags)flags;
//- (id)valueForAccessibilityAttribute:(id)arg1 error:(id *)arg2;
//- (id)valuesForAccessibilityAttributes:(id)arg1 error:(id *)arg2;
- (BOOL)waitForExistenceWithTimeout:(double)arg1;


@end

