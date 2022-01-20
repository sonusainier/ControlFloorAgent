//  Copyright © 2021 DryArk LLC. All rights reserved.
//  Cooperative License ( LICENSE_DRYARK )
#import <Foundation/Foundation.h>
#import "XCUIDevice.h"
#import "XCDeviceEvent.h"
#import "XCUIDevice+Helpers.h"
#import "XCPointerEventPath.h"
#import "XCSynthesizedEventRecord.h"
#import "XCAXClient_iOS+Helpers.h"
#import "XCAccessibilityElement.h"
#import "XCTest/XCUICoordinate.h"
#include "VersionMacros.h"
#import <XCTest/XCUIRemote.h>
#import "XCUIApplication.h"
#import "XCUIApplication+Helpers.h"
#import "XCTRunnerDaemonSession.h"

@implementation XCUIDevice (Helpers)

- (void)runEventPath:(XCPointerEventPath*)path {
  XCSynthesizedEventRecord *event = [[XCSynthesizedEventRecord alloc]
                                           initWithName:nil
                                   interfaceOrientation:0];
  [event addPointerEventPath:path];
  
  [[self eventSynthesizer] synthesizeEvent:event
                                completion:(id)^(BOOL result, NSError *invokeError) {} ];
}

- (void)runEventPaths:(XCPointerEventPath* __strong [])paths count:(int)count {
  XCSynthesizedEventRecord *event = [[XCSynthesizedEventRecord alloc]
                                           initWithName:nil
                                   interfaceOrientation:0];
  for( int i=0;i<count;i++ ) [event addPointerEventPath:paths[i]];
  
  [[self eventSynthesizer] synthesizeEvent:event
                                completion:(id)^(BOOL result, NSError *invokeError) {} ];
}

- (void)cf_tap:(CGFloat)x y:(CGFloat) y {
  XCPointerEventPath *path = [[XCPointerEventPath alloc]
                              initForTouchAtPoint:CGPointMake(x,y)
                              offset:0];
  [path liftUpAtOffset:0.05];
  [self runEventPath:path];
}

- (void)cf_doubletap:(XCUIElement *)el x:(CGFloat)x y:(CGFloat)y {
  XCUICoordinate *base = [el coordinateWithNormalizedOffset:CGVectorMake(0, 0)];
  XCUICoordinate *coord = [base coordinateWithOffset:CGVectorMake(x, y)];
  [coord doubleTap];
}

- (void)cf_mouseDown:(CGFloat)x y:(CGFloat)y {
  XCPointerEventPath *path = [[XCPointerEventPath alloc]
                                    initForMouseEventsAtLocation:CGPointMake(x,y)
                                                ];
  [path pressButton:0 atOffset:0 clickCount:1];
  [self runEventPath:path];
}

- (void)cf_mouseUp:(CGFloat)x y:(CGFloat)y {
  XCPointerEventPath *path = [[XCPointerEventPath alloc]
                                    initForMouseEventsAtLocation:CGPointMake(x,y)
                                                ];
  [path releaseButton:0 atOffset:0 clickCount:1];
  [self runEventPath:path];
}

- (void)cf_holdHomeButtonForDuration:(CGFloat)dur {
  [self holdHomeButtonForDuration:dur];
}

- (void)cf_tapTime:(CGFloat)x y:(CGFloat)y time:(CGFloat)time {
  XCPointerEventPath *path = [[XCPointerEventPath alloc]
                                    initForTouchAtPoint:CGPointMake(x,y)
                                                 offset:0];
  [path liftUpAtOffset:time];
  [self runEventPath:path];
}

- (void)cf_tapFirm:(CGFloat)x y:(CGFloat)y pressure:(CGFloat)pressure {
  XCPointerEventPath *path = [[XCPointerEventPath alloc]
                                    initForTouchAtPoint:CGPointMake(x,y)
                                                 offset:0.0];
  [path pressDownWithPressure:pressure atOffset:0];
  [path liftUpAtOffset:0.05];
  [self runEventPath:path];
}

- (void)cf_fingerPaste:(CGFloat)x y:(CGFloat)y {
  CGFloat time = 0.1;
  
  XCPointerEventPath *paths[3] = { nil, nil, nil };
  
  paths[0] = [[XCPointerEventPath alloc] initForTouchAtPoint:CGPointMake(x,y) offset:0];
  [paths[0] liftUpAtOffset:time];
  
  paths[1] = [[XCPointerEventPath alloc] initForTouchAtPoint:CGPointMake(x-10,y) offset:0];
  [paths[1] moveToPoint:CGPointMake(x-20,y) atOffset:time];
  [paths[1] liftUpAtOffset:time];
  
  paths[2] = [[XCPointerEventPath alloc] initForTouchAtPoint:CGPointMake(x+10,y) offset:0];
  [paths[2] moveToPoint:CGPointMake(x+20,y) atOffset:time];
  [paths[2] liftUpAtOffset:time];
  
  [self runEventPaths:paths count:3];
}

- (void)cf_swipe:(CGFloat)x1 y1:(CGFloat)y1 x2:(CGFloat)x2 y2:(CGFloat)y2 delay:(CGFloat)delay {
  XCPointerEventPath *path = [[XCPointerEventPath alloc]
                                    initForTouchAtPoint:CGPointMake(x1,y1)
                                                 offset:0];
  [path moveToPoint:CGPointMake(x2,y2) atOffset:delay];
  [path liftUpAtOffset:delay];
  [self runEventPath:path];
}

#if TARGET_OS_TV
// See https://developer.apple.com/documentation/xctest/xcuiremotebutton?language=objc
- (void)cf_remotePressButton:(NSUInteger)button {
  XCUIRemote *remote = [XCUIRemote sharedRemote];
  [remote pressButton:button];
}

- (void)cf_remotePressButton:(NSUInteger)button forDuration:(CGFloat)dur {
  XCUIRemote *remote = [XCUIRemote sharedRemote];
  [remote pressButton:button forDuration:dur];
}
#endif

// See https://unix.superglobalmegacorp.com/xnu/newsrc/iokit/IOKit/hidsystem/IOHIDUsageTables.h.html
- (BOOL)cf_iohid:(unsigned int)page
           usage:(unsigned int)usage
        duration:(NSTimeInterval)duration
           error:(NSError **)error
{
  XCDeviceEvent *event = [XCDeviceEvent deviceEventWithPage:page usage:usage duration:duration];
  return [self performDeviceEvent:event error:error];
}

- (NSString *)cf_startBroadcastApp {
  XCAXClient_iOS *axClient = XCAXClient_iOS.sharedClient;
  NSInteger pid = [[axClient systemApplication] processIdentifier];
  
  XCUIApplication *systemApp = (XCUIApplication *)[XCUIApplication appProcessWithPID:pid];
  //XCUIApplication *systemApp = [XCTRunnerDaemonSession.sharedSession appWithPID:pid];
  
  XCUIApplication *app = [ [XCUIApplication alloc] initWithBundleIdentifier:@"com.dryark.vidstream"];
  
  if( app.state < 2 )   [app launch];
  else                  [app activate];
  [NSThread sleepForTimeInterval:1.0];
  
  [app.buttons[@"Broadcast Selector"] tap];
  [NSThread sleepForTimeInterval:1.0];
 
  if( !IOS_LESS_THAN( @"14.0" ) ) [systemApp.buttons[@"Start Broadcast"] tap];
  else                            [app.staticTexts[@"Start Broadcast"] tap];
  [NSThread sleepForTimeInterval:3.0];
  
  [XCUIDevice.sharedDevice pressButton: XCUIDeviceButtonHome];
  [NSThread sleepForTimeInterval:2.0];
  
  [app terminate];
 
  return @"true";
}

@end
