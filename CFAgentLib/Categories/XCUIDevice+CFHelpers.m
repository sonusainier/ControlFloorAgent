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

- (void)runEventPath:(XCPointerEventPath*)path
{
  XCSynthesizedEventRecord *event = [[XCSynthesizedEventRecord alloc]
                                     initWithName:nil
                                     interfaceOrientation:0];
  //XCSynthesizedEventRecord *event = [[XCSynthesizedEventRecord alloc] init];
  [event addPointerEventPath:path];
  
  [[self eventSynthesizer]
    synthesizeEvent:event
    completion:(id)^(BOOL result, NSError *invokeError) {} ];
}

- (void)cf_tap:(CGFloat)x
  y:(CGFloat) y
{
  XCPointerEventPath *path = [[XCPointerEventPath alloc]
                              initForTouchAtPoint:CGPointMake(x,y)
                              offset:0];
  [path liftUpAtOffset:0.05];
  [self runEventPath:path];
}

- (void)cf_mouseDown:(CGFloat)x
  y:(CGFloat) y
{
  XCPointerEventPath *path = [[XCPointerEventPath alloc]
                              initForMouseAtPoint:CGPointMake(x,y)
                              offset:0];
  [path pressButton:0 atOffset:0];
  [self runEventPath:path];
}

- (void)cf_mouseUp:(CGFloat)x
  y:(CGFloat) y
{
  XCPointerEventPath *path = [[XCPointerEventPath alloc]
                              initForMouseAtPoint:CGPointMake(x,y)
                              offset:0];
  [path releaseButton:0 atOffset:0];
  [self runEventPath:path];
}

- (void)cf_holdHomeButtonForDuration:(CGFloat)dur
{
  [self holdHomeButtonForDuration:dur];
}

- (void)cf_tapTime:(CGFloat)x
  y:(CGFloat) y
  time:(CGFloat) time
{
  XCPointerEventPath *path = [[XCPointerEventPath alloc]
                              initForTouchAtPoint:CGPointMake(x,y)
                              offset:0];
  [path liftUpAtOffset:time];
  [self runEventPath:path];
}

- (void)cf_tapFirm:(CGFloat)x
  y:(CGFloat) y
  pressure:(CGFloat) pressure
{
  XCPointerEventPath *path = [[XCPointerEventPath alloc]
                              initForTouchAtPoint:CGPointMake(x,y)
                              offset:0.0];
  [path pressDownWithPressure:pressure atOffset:0];
  [path liftUpAtOffset:0.05];
  [self runEventPath:path];
}

- (void)cf_swipe:(CGFloat)x1
  y1:(CGFloat) y1
  x2:(CGFloat) x2
  y2:(CGFloat) y2
  delay:(CGFloat) delay
{
  XCPointerEventPath *path = [[XCPointerEventPath alloc]
                              initForTouchAtPoint:CGPointMake(x1,y1)
                              offset:0];
  [path moveToPoint:CGPointMake(x2,y2) atOffset:delay];
  [path liftUpAtOffset:delay];
  [self runEventPath:path];
}

- (void)cf_keyEvent:(id)keyId
  modifierFlags:(unsigned long long) modifierFlags
{
  XCPointerEventPath *path = [[XCPointerEventPath alloc] initForTextInput];
  [path typeKey:keyId modifiers:modifierFlags atOffset:0.00];
  [self runEventPath:path];
}

- (BOOL)cf_iohid:(unsigned int)page
                               usage:(unsigned int)usage
                               type:(unsigned int)type
                            duration:(NSTimeInterval)duration
                               error:(NSError **)error
{
  XCDeviceEvent *event = [XCDeviceEvent
                          deviceEventWithPage:page
                          usage:usage
                          duration:duration];
  event.type = type;
  return [self performDeviceEvent:event error:error];
}

@end
