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

- (BOOL)cf_iohid_with_modifier:(unsigned int)page
           usage:(unsigned int)usage
        duration:(NSTimeInterval)duration
        modifier:(XCUIKeyModifierFlags)flags
           error:(NSError **)errorOut
{
  XCDeviceEvent *event = [XCDeviceEvent deviceEventWithPage:page usage:usage duration:duration];
  __block bool success;
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);
  
  __block NSError *error2 = nil;
  [self performWithKeyModifiers:flags block:^{
    NSError *error = nil;
    success = [self performDeviceEvent:event error:&error];
    if( error != nil ) error2 = error;
    dispatch_semaphore_signal(sem);
  }];
  dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)));
  if( errorOut != nil ) *errorOut = error2;
  return success;
}

- (void)cf_typeKey:(XCUIApplication *)app
{
    XCUIKeyModifierFlags flags = XCUIKeyModifierShift;
    //XCUIElement *sys = (XCUIElement *) my->systemApp;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [self performWithKeyModifiers:flags block:^{
      [app typeText:@"a"];
      dispatch_semaphore_signal(sem);
    }];
    dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)));
}

- (NSString *)cf_startBroadcastApp {
  XCAXClient_iOS *axClient = XCAXClient_iOS.sharedClient;
  NSInteger pid = [[axClient systemApplication] processIdentifier];
  
  XCUIApplication *systemApp = (XCUIApplication *)[XCUIApplication appProcessWithPID:pid];
  //XCUIApplication *systemApp = [XCTRunnerDaemonSession.sharedSession appWithPID:pid];
  
  XCUIApplication *app = [ [XCUIApplication alloc] initWithBundleIdentifier:@"com.LT.LTApp"];
  
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


//LT Changes Start

- (NSString *)LT_startStream
{
  XCAXClient_iOS *axClient = XCAXClient_iOS.sharedClient;
  NSInteger pid = [[axClient systemApplication] processIdentifier];
  
  XCUIApplication *systemApp = (XCUIApplication *)[XCUIApplication appProcessWithPID:pid];
  //XCUIApplication *systemApp = [XCTRunnerDaemonSession.sharedSession appWithPID:pid];
  
  XCUIApplication *app = [ [XCUIApplication alloc] initWithBundleIdentifier:@"com.LT.LTApp"];
  if( app.state < 2 )   [app launch];
  else                  [app activate];
  NSString *ver = [[UIDevice currentDevice] systemVersion];
  int os = [ver intValue];
  [NSThread sleepForTimeInterval:1.0];
  
  [app.buttons[@"Broadcast Selector"] tap];
  [NSThread sleepForTimeInterval:1.0];
 
  if( os >= 14) {
    [systemApp.buttons[@"Start Broadcast"] tap];
    [NSThread sleepForTimeInterval:3.0];
  }
  else{
    [app.staticTexts[@"Start Broadcast"] tap];
    [NSThread sleepForTimeInterval:3.0];
  }
  
  [XCUIDevice.sharedDevice pressButton: XCUIDeviceButtonHome];
  [NSThread sleepForTimeInterval:2.0];
  
  [app terminate];
 
  return @"true";
}

- (NSString *)LT_openUrl:(NSString *)url
{
  XCUIApplication *app = [ [XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.mobilesafari"];
  if( app.state < 2 )   [app launch];
  else                  [app activate];
  NSString *urlStr = [NSString stringWithFormat:@"%@\n", url];
  if (IOS_GREATER_THAN_OR_EQUAL_TO(@"15.0")){
    if (app.textFields[@"TabBarItemTitle"].exists){
      [app.textFields[@"TabBarItemTitle"] tap];
    }
    else{
      if (app.buttons[@"UnifiedTabBarItemView?isSelected=true"].exists){
        [app.buttons[@"UnifiedTabBarItemView?isSelected=true"] tap];
      }
    }
    [app typeText: urlStr];
    
  } else{
    if (app.buttons[@"URL"].exists){
      [app.buttons[@"URL"] tap];
      [app typeText: urlStr];
    }
  }
  return @"true";
  
}

- (BOOL) LT_cleanBrowser:(NSString *)bid
{
  XCUIApplication *app = [ [XCUIApplication alloc] initWithBundleIdentifier:[NSString stringWithUTF8String:bid.UTF8String]];
  if ([bid isEqualToString:@"com.apple.Preferences"]){
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
          if(!app.tables.cells.staticTexts[@"Sign in to your iPad"].exists){
              if(app.tables.cells.staticTexts[@"APPLE_ACCOUNT"].exists){
                [app.tables.cells.staticTexts[@"APPLE_ACCOUNT"] tap];
                [NSThread sleepForTimeInterval:1.0];
              if(app.staticTexts[@"Sign Out"].exists)
              {
                [app.staticTexts[@"Sign Out"] tap];
              }
                [NSThread sleepForTimeInterval:1.0];
              }
          }
        }else{
          if(!app.tables.cells.staticTexts[@"Sign in to your iPhone"].exists){
              if(app.tables.cells.staticTexts[@"APPLE_ACCOUNT"].exists){
                [app.tables.cells.staticTexts[@"APPLE_ACCOUNT"] tap];
                [NSThread sleepForTimeInterval:1.0];
              if(app.staticTexts[@"Sign Out"].exists)
              {
                [app.staticTexts[@"Sign Out"] tap];
              }
                [NSThread sleepForTimeInterval:1.0];
              }
          }
        }
        if(app.tables.cells.staticTexts[@"Off"].exists){
          [app.tables.cells.staticTexts[@"Wi-Fi"] tap];
          XCUIElement *mySwitch = app.switches[@"Wi-Fi"];
          if (![(NSString *)mySwitch.value isEqualToString:@"1"])
                  [mySwitch tap];
          if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
            [app.buttons[@"Settings"] tap];
            }
        }
        [NSThread sleepForTimeInterval:0.5];
        
        if(app.tables.cells.staticTexts[@"Safari"].exists){
          [NSThread sleepForTimeInterval:0.5];
          [app.tables.cells.staticTexts[@"Safari"] tap];
          [NSThread sleepForTimeInterval:0.5];
          XCUIElement *mySwitch = app.switches[@"Block Pop-ups"];
          if ([(NSString *)mySwitch.value isEqualToString:@"1"])
                  [mySwitch tap];
            if(app.staticTexts[@"Clear History and Website Data"].exists)
            {
                [app.staticTexts[@"Clear History and Website Data"] tap];
              [NSThread sleepForTimeInterval:1.0];
                if(app.buttons[@"Clear"].exists){
                    [app.buttons[@"Clear"] tap];
                }
                else{
                    [app.buttons[@"Clear History and Data"] tap];
                }
            
            }
          [NSThread sleepForTimeInterval:1.0];
            if(app.staticTexts[@"Advanced"].exists){
                [app.staticTexts[@"Advanced"] tap];
                if(app.staticTexts[@"Experimental Features"].exists){
                  [app.staticTexts[@"Experimental Features"] tap];
                    if(app.staticTexts[@"NSURLSession WebSocket"].exists){
                      XCUIElement *NsWsSwitch = app.switches[@"NSURLSession WebSocket"];
                      if (![(NSString *)NsWsSwitch.value isEqualToString:@"1"])
                              [NsWsSwitch tap];
                    }
                 }
            }
        }
  }
  else if ([bid isEqualToString:@"com.google.chrome.ios"]){
    if(app.buttons[@"Accept and Continue"].exists){
            NSLog(@"Chrome on Welcome screen");
          }
          else if (app/*@START_MENU_TOKEN@*/.buttons[@"kToolbarStackButtonIdentifier"]/*[[".windows[\"0\"]",".buttons[\"Show Tabs\"]",".buttons[\"kToolbarStackButtonIdentifier\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.exists){
            [app/*@START_MENU_TOKEN@*/.buttons[@"kToolbarStackButtonIdentifier"]/*[[".windows[\"0\"]",".buttons[\"Show Tabs\"]",".buttons[\"kToolbarStackButtonIdentifier\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/ tap];
          
            XCUIElement *toolbarToolbarsQuery = app/*@START_MENU_TOKEN@*/.toolbars[@"Toolbar"]/*[[".windows[@\"0\"].toolbars[@\"Toolbar\"]",".toolbars[@\"Toolbar\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/;
            if(toolbarToolbarsQuery/*@START_MENU_TOKEN@*/.buttons[@"TabGridIncognitoTabsPageButtonIdentifier"]/*[[".buttons[\"Incognito Tabs\"]",".buttons[\"TabGridIncognitoTabsPageButtonIdentifier\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists){
              [toolbarToolbarsQuery/*@START_MENU_TOKEN@*/.buttons[@"TabGridIncognitoTabsPageButtonIdentifier"]/*[[".buttons[\"Incognito Tabs\"]",".buttons[\"TabGridIncognitoTabsPageButtonIdentifier\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap ];
              if(app.buttons[@"Edit"].exists){
                [app.buttons[@"Edit"] tap ];
                  if(app.buttons[@"Close All Tabs"].exists){
                  [app.buttons[@"Close All Tabs"] tap];
                  }
              }else{
                [toolbarToolbarsQuery/*@START_MENU_TOKEN@*/.buttons[@"TabGridCloseAllButtonIdentifier"]/*[[".buttons[\"Close All\"]",".buttons[\"TabGridCloseAllButtonIdentifier\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
              }
          }
            if(toolbarToolbarsQuery/*@START_MENU_TOKEN@*/.buttons[@"TabGridRegularTabsPageButtonIdentifier"]/*[[".buttons[\"Open Tabs\"]",".buttons[\"TabGridRegularTabsPageButtonIdentifier\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists){
              [toolbarToolbarsQuery/*@START_MENU_TOKEN@*/.buttons[@"TabGridRegularTabsPageButtonIdentifier"]/*[[".buttons[\"Open Tabs\"]",".buttons[\"TabGridRegularTabsPageButtonIdentifier\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
              [NSThread sleepForTimeInterval:0.5];
              if(app.buttons[@"Edit"].exists){
                [app.buttons[@"Edit"] tap ];
                if(app.buttons[@"Close All Tabs"].exists){
                  [app.buttons[@"Close All Tabs"] tap];
                  }
              }else{
                [toolbarToolbarsQuery.buttons[@"TabGridCloseAllButtonIdentifier"] tap];
              }
          }
          
            [app.buttons[@"Create new tab."] tap ];
            [app/*@START_MENU_TOKEN@*/.buttons[@"kToolbarToolsMenuButtonIdentifier"]/*[[".windows[\"0\"]",".buttons[\"Menu\"]",".buttons[\"kToolbarToolsMenuButtonIdentifier\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/tap];
            [app/*@START_MENU_TOKEN@*/.tables[@"kPopupMenuToolsMenuTableViewId"].staticTexts[@"History"]/*[[".windows[\"0\"].tables[\"kPopupMenuToolsMenuTableViewId\"]",".cells[\"History\"].staticTexts[\"History\"]",".cells[\"kToolsMenuHistoryId\"].staticTexts[\"History\"]",".staticTexts[\"History\"]",".tables[\"kPopupMenuToolsMenuTableViewId\"]"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/ tap];
          
            XCUIElement *toolbar = app/*@START_MENU_TOKEN@*/.toolbars[@"Toolbar"]/*[[".windows[\"0\"].toolbars[\"Toolbar\"]",".toolbars[\"Toolbar\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/;
            [toolbar/*@START_MENU_TOKEN@*/.buttons[@"kHistoryToolbarClearBrowsingButtonIdentifier"]/*[[".buttons[\"Clear Browsing Data…\"]",".buttons[\"kHistoryToolbarClearBrowsingButtonIdentifier\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
            //[app.tables[@"kClearBrowsingDataViewAccessibilityIdentifier"].staticTexts[@"All Time"] tap]
            [app.tables[@"kClearBrowsingDataViewAccessibilityIdentifier"].staticTexts[@"Time Range"] tap ];
            [app/*@START_MENU_TOKEN@*/.tables.staticTexts[@"All Time"]/*[[".windows[\"0\"].tables",".cells[\"All Time\"].staticTexts[\"All Time\"]",".staticTexts[\"All Time\"]",".tables"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/ tap];
            [app/*@START_MENU_TOKEN@*/.navigationBars[@"Time Range"]/*[[".windows[\"0\"].navigationBars[\"Time Range\"]",".navigationBars[\"Time Range\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons[@"Clear Browsing Data"] tap];
            [toolbar/*@START_MENU_TOKEN@*/.buttons[@"kClearBrowsingDataButtonIdentifier"]/*[[".buttons[\"Clear Browsing Data\"]",".buttons[\"kClearBrowsingDataButtonIdentifier\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
            [NSThread sleepForTimeInterval:1.0];
            [app/*@START_MENU_TOKEN@*/.sheets[@"The items you selected will be removed."]/*[[".windows[\"0\"].sheets[\"The items you selected will be removed.\"]",".sheets[\"The items you selected will be removed.\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.otherElements.buttons[@"Clear Browsing Data"] tap];
            //[app/*@START_MENU_TOKEN@*/.sheets[@"The items you selected will be removed."]/*[[".windows[@\"0\"].sheets[@\"The items you selected will be removed.\"]",".sheets[@\"The items you selected will be removed.\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.scrollViews.otherElements.buttons[@"Clear Browsing Data"] tap];
            [app/*@START_MENU_TOKEN@*/.navigationBars[@"Clear Browsing Data"].buttons[@"kSettingsDoneButtonId"]/*[[".windows[\"0\"].navigationBars[\"Clear Browsing Data\"]",".buttons[\"Done\"]",".buttons[\"kSettingsDoneButtonId\"]",".navigationBars[\"Clear Browsing Data\"]"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/ tap];
            [app/*@START_MENU_TOKEN@*/.navigationBars[@"History"].buttons[@"kHistoryNavigationControllerDoneButtonIdentifier"]/*[[".windows[\"0\"].navigationBars[\"History\"]",".buttons[\"Done\"]",".buttons[\"kHistoryNavigationControllerDoneButtonIdentifier\"]",".navigationBars[\"History\"]"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/ tap];
          }
  }
  else{
    return false;
  }
  
  
  return true;
  
}

//LT Changes End

@end
