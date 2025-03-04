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

#import "FBApplication.h"
#import "FBXCAXClientProxy.h"
#import "FBXCodeCompatibility.h"
#import "XCTest/XCUICoordinate.h"

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

- (void)cf_doubletap:(XCUIElement *)el
  x:(CGFloat)x
  y:(CGFloat) y
{
  XCUICoordinate *base = [el coordinateWithNormalizedOffset:CGVectorMake(0, 0)];
  XCUICoordinate *coord = [base coordinateWithOffset:CGVectorMake(x, y)];
  [coord doubleTap];
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

- (NSString *)cf_startBroadcastApp
{
  FBApplication *cfapp = nil;
  XCUIApplication *cf_systemApp = nil;
  int pid = [[FBXCAXClientProxy.sharedClient systemApplication] processIdentifier];
  cf_systemApp = [FBApplication applicationWithPID:pid];
  cfapp = [ [FBApplication alloc] initWithBundleIdentifier:[NSString stringWithUTF8String:"com.LT.LTApp"]];
 
  //cfapp.fb_shouldWaitForQuiescence = false; // or nil
  cfapp.launchArguments = @[];
  cfapp.launchEnvironment = @{};
  unsigned long state = [cfapp fb_state];
  if( state < 2 ) {
    [cfapp launch];
  } else {
    [cfapp activate];
  }
   
  NSLog(@"System Version is %@",[[UIDevice currentDevice] systemVersion]);
  NSString *ver = [[UIDevice currentDevice] systemVersion];
  int os = [ver intValue];
  
  [NSThread sleepForTimeInterval:1.0];
  [cfapp.buttons[@"Broadcast Selector"] tap];
  [NSThread sleepForTimeInterval:1.0];
 
  if (os >= 14){
    [cf_systemApp.buttons[@"Start Broadcast"] tap];
    [NSThread sleepForTimeInterval:3.0];
  }
  else{
    [cfapp.staticTexts[@"Start Broadcast"] tap];
    [NSThread sleepForTimeInterval:3.0];
  }
  
  [XCUIDevice.sharedDevice pressButton: XCUIDeviceButtonHome];

  [NSThread sleepForTimeInterval:2.0];
  [cfapp terminate];
 
  return @"true";
}

@end
