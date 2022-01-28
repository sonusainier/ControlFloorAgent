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

#import <UIKit/UIDevice.h>

@class NSString, XCUIRemote, XCUISiriService;
@protocol XCTSignpostListener, XCUIAccessibilityInterface, XCUIApplicationAutomationSessionProviding, XCUIApplicationManaging, XCUIApplicationMonitor, XCUIDeviceAutomationModeInterface, XCUIDeviceDiagnostics, XCUIDeviceEventAndStateInterface, XCUIEventSynthesizing, XCUIInterruptionMonitoring, XCUIResetAuthorizationStatusOfProtectedResourcesInterface, XCUIScreenDataSource, XCUIXcodeApplicationManaging;


@protocol XCUIAccessibilityInterface;
@protocol XCUIXcodeApplicationManaging;

@interface XCUIDevice ()

@property(readonly) id <XCTSignpostListener> signpostListener;

+ (id)localDevice;
+ (void)setLocalDevice:(id)arg1;
+ (XCUIDevice *)sharedDevice;
- (NSUInteger)_setModifiers:(NSUInteger)arg1 merge:(BOOL)arg2 beginPersistentState:(BOOL)arg3 description:(id)arg4;
- (void)_setOrientation:(NSInteger)arg1;
- (void)_silentPressButton:(NSInteger)arg1;
- (id)accessibilityInterface;
- (NSInteger)appearanceMode;
- (id)applicationAutomationSessionProvider;
- (id)applicationMonitor;
- (void)attachLocalizableStringsData;
- (id)automationModeInterface;
- (BOOL)configuredForUITesting;
- (id)deviceEventAndStateInterface;
- (id)diagnosticAttachmentsForError:(id)arg1;
- (id)diagnosticsProvider;
- (BOOL)enableAutomationMode:(id *)arg1;
- (id)eventSynthesizer;
- (void)holdHomeButtonForDuration:(double)arg1;
- (id)initLocalDeviceWithPlatform:(NSInteger)arg1;
- (id)initWithDiagnosticProvider:(id)arg1;
- (id)interruptionMonitor;
- (BOOL)isLocal;
- (BOOL)isSimulatorDevice;
- (id)mainScreen;
- (id)mainScreenOrError:(id *)arg1;
- (id)makeDiagnosticScreenshotAttachmentForDevice;
- (BOOL)performDeviceEvent:(id)arg1 error:(id *)arg2;
- (void)performWithKeyModifiers:(XCUIKeyModifierFlags)flags block:(XCT_NOESCAPE void (^)(void))block;
- (NSInteger)platform;
- (id)platformApplicationManager;
- (BOOL)playBackHIDEventRecordingFromURL:(id)arg1 error:(id *)arg2;
- (void)pressLockButton;
- (id)remote;
- (void)remoteAutomationSessionDidDisconnect:(id)arg1;
- (id)resetAuthorizationStatusInterface;
- (void)rotateDigitalCrown:(double)arg1 velocity:(double)arg2;
- (void)rotateDigitalCrownByDelta:(double)arg1;
- (void)rotateDigitalCrownByDelta:(double)arg1 withVelocity:(double)arg2;
- (id)screenDataSource;
- (id)screenWithDisplayID:(NSInteger)arg1 orError:(id *)arg2;
- (id)screens;
- (id)screensOrError:(id *)arg1;
- (void)setAppearanceMode:(NSInteger)arg1;
- (id)spindumpAttachmentForProcessID:(NSInteger)arg1 error:(id *)arg2;
- (BOOL)startHIDEventRecordingWithError:(id *)arg1;
- (BOOL)stopHIDEventRecordingAndSavetoURL:(id)arg1 error:(id *)arg2;
- (BOOL)supportsPressureInteraction;
- (id)uniqueIdentifier;
- (id)xcodeApplicationManager;

@end
