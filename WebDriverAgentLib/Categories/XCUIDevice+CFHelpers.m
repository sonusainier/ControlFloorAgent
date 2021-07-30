//
//  XCUIDevice+CFHelpers.m
//  Copyright © 2021 DryArk LLC. All rights reserved.
//  Anti-Corruption License ( AC_LICENSE.TXT )
//

#import <Foundation/Foundation.h>
#import "XCUIDevice.h"
#import "XCDeviceEvent.h"
#import "XCUIDevice+CFHelpers.h"
#import "XCPointerEventPath.h"
#import "XCSynthesizedEventRecord.h"
#import "FBXCTestDaemonsProxy.h"
#import "XCTRunnerDaemonSession.h"

@implementation XCUIDevice (CFHelpers)

- (void)cf_tap:(CGFloat)x
  y:(CGFloat) y
{
  CGPoint point = CGPointMake(x,y);
  
  XCPointerEventPath *pointerEventPath = [[XCPointerEventPath alloc] initForTouchAtPoint:point offset:0];
  [pointerEventPath liftUpAtOffset:0.05];
  
  XCSynthesizedEventRecord *eventRecord = [[XCSynthesizedEventRecord alloc] initWithName:nil interfaceOrientation:0];
  [eventRecord addPointerEventPath:pointerEventPath];
  
  [[self eventSynthesizer]
    synthesizeEvent:eventRecord
    completion:(id)^(BOOL result, NSError *invokeError) {} ];
}

- (void)cf_swipe:(CGFloat)x1
  y1:(CGFloat) y1
  x2:(CGFloat) x2
  y2:(CGFloat) y2
  delay:(CGFloat) delay
{
  CGPoint point1 = CGPointMake(x1,y1);
  CGPoint point2 = CGPointMake(x2,y2);
  
  XCPointerEventPath *pointerEventPath = [[XCPointerEventPath alloc] initForTouchAtPoint:point1 offset:0];
  [pointerEventPath moveToPoint:point2 atOffset:delay];
  [pointerEventPath liftUpAtOffset:delay];
  
  XCSynthesizedEventRecord *eventRecord = [[XCSynthesizedEventRecord alloc] initWithName:nil interfaceOrientation:0];
  [eventRecord addPointerEventPath:pointerEventPath];
  
  [[self eventSynthesizer]
    synthesizeEvent:eventRecord
    completion:(id)^(BOOL result, NSError *invokeError) {} ];
}

- (void)cf_keyEvent:(id)keyId
  modifierFlags:(unsigned long long) modifierFlags
{
  CGPoint point = CGPointMake(200,200);
  
  //XCPointerEventPath *pointerEventPath = [[XCPointerEventPath alloc] initForTouchAtPoint:point offset:0];
  
  XCPointerEventPath *pointerEventPath = [[XCPointerEventPath alloc] initForTextInput];
  //[pointerEventPath t]
  [pointerEventPath typeKey:keyId modifiers:modifierFlags atOffset:0.00];
  //[pointerEventPath typeText:keyId atOffset:0.00 typingSpeed: 10];
  
  //[pointerEventPath liftUpAtOffset:0.10];
  
  XCSynthesizedEventRecord *eventRecord = [[XCSynthesizedEventRecord alloc] initWithName:nil interfaceOrientation:0];
  [eventRecord addPointerEventPath:pointerEventPath];
  
  [[self eventSynthesizer]
    synthesizeEvent:eventRecord
    completion:(id)^(BOOL result, NSError *invokeError) {} ];
}

- (BOOL)cf_iohid:(unsigned int)page
                               usage:(unsigned int)usage
                               type:(unsigned int)type
                            duration:(NSTimeInterval)duration
                               error:(NSError **)error
{
  XCDeviceEvent *event = [XCDeviceEvent deviceEventWithPage:page
                                                      usage:usage
                                                   duration:duration];
  event.type = type;
  return [self performDeviceEvent:event error:error];
}

@end
