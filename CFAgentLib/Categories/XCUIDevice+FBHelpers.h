// Copyright (c) 2015, Facebook Inc.
// All rights reserved.
// BSD license - See LICENSE

#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface XCUIDevice (FBHelpers)

/**
 Matches or mismatches TouchID request

 @param shouldMatch determines if TouchID should be matched
 @return YES if the operation succeeds, otherwise NO.
 */
- (BOOL)fb_fingerTouchShouldMatch:(BOOL)shouldMatch;

/**
 Returns device current wifi ip4 address
 */
- (nullable NSString *)fb_wifiIPAddress;

/**
 Presses the corresponding hardware button on the device

 @param buttonName One of the supported button names: volumeUp (real devices only), volumeDown (real device only), home
 @return YES if the button has been pressed
 */
- (BOOL)fb_pressButton:(NSString *)buttonName error:(NSError **)error;

/**
 Emulated triggering of the given low-level IOHID device event. The constants for possible events are defined
 in https://unix.superglobalmegacorp.com/xnu/newsrc/iokit/IOKit/hidsystem/IOHIDUsageTables.h.html
 Popular constants:
 - kHIDPage_Consumer = 0x0C
 - kHIDUsage_Csmr_VolumeIncrement  = 0xE9 (Volume Up)
 - kHIDUsage_Csmr_VolumeDecrement  = 0xEA (Volume Down)
 - kHIDUsage_Csmr_Menu = 0x40 (Home)
 - kHIDUsage_Csmr_Power  = 0x30 (Power)
 - kHIDUsage_Csmr_Snapshot  = 0x65 (Power + Home)

 @param page The event page identifier
 @param usage The event usage identifier (usages are defined per-page)
 @param duration The event duration in float seconds (XCTest uses 0.005 for a single press event)
 @param error If there is an error, upon return contains an NSError object that describes the problem.
 @return YES the event has successfully been triggered
 */
- (BOOL)fb_performIOHIDEventWithPage:(unsigned int)page
                               usage:(unsigned int)usage
                            duration:(NSTimeInterval)duration
                               error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
