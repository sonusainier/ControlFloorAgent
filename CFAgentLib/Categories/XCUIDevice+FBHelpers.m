/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "XCUIDevice+FBHelpers.h"

#import <arpa/inet.h>
#import <ifaddrs.h>
#include <notify.h>
#import <objc/runtime.h>

#import "FBErrorBuilder.h"
#import "FBImageUtils.h"
#import "FBMacros.h"
#import "FBMathUtils.h"
#import "FBScreenshot.h"
#import "FBXCodeCompatibility.h"
#import "XCUIDevice.h"
#import "XCDeviceEvent.h"
#import "FBXCAXClientProxy.h"
#import "XCPointerEventPath.h"

static const NSTimeInterval FBHomeButtonCoolOffTime = 1.;
static const NSTimeInterval FBScreenLockTimeout = 5.;

@implementation XCUIDevice (FBHelpers)

static bool fb_isLocked;

+ (void)load
{
  [self fb_registerAppforDetectLockState];
}

+ (void)fb_registerAppforDetectLockState
{
  int notify_token;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
  notify_register_dispatch("com.apple.springboard.lockstate", &notify_token, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(int token) {
    uint64_t state = UINT64_MAX;
    notify_get_state(token, &state);
    fb_isLocked = state != 0;
  });
#pragma clang diagnostic pop
}

- (BOOL)fb_goToHomescreenWithError:(NSError **)error
{
  return [FBApplication fb_switchToSystemApplicationWithError:error];
}

- (BOOL)fb_lockScreen:(NSError **)error
{
  if (fb_isLocked) {
    return YES;
  }
  [self pressLockButton];
  return [[[[FBRunLoopSpinner new]
            timeout:FBScreenLockTimeout]
           timeoutErrorMessage:@"Timed out while waiting until the screen gets locked"]
          spinUntilTrue:^BOOL{
            return fb_isLocked;
          } error:error];
}

- (BOOL)fb_isScreenLocked
{
  return fb_isLocked;
}

- (BOOL)fb_unlockScreen:(NSError **)error
{
  if (!fb_isLocked) {
    return YES;
  }
  [self pressButton:XCUIDeviceButtonHome];
  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:FBHomeButtonCoolOffTime]];
#if !TARGET_OS_TV
  if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
    [[FBApplication fb_activeApplication] swipeRight];
  } else {
    [self pressButton:XCUIDeviceButtonHome];
  }
#else
  [self pressButton:XCUIDeviceButtonHome];
#endif
  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:FBHomeButtonCoolOffTime]];
  return [[[[FBRunLoopSpinner new]
            timeout:FBScreenLockTimeout]
           timeoutErrorMessage:@"Timed out while waiting until the screen gets unlocked"]
          spinUntilTrue:^BOOL{
            return !fb_isLocked;
          } error:error];
}

- (NSData *)fb_screenshotWithError:(NSError*__autoreleasing*)error
{
  return [FBScreenshot takeInOriginalResolutionWithQuality:FBConfiguration.screenshotQuality
                                                     error:error];
}

- (BOOL)fb_fingerTouchShouldMatch:(BOOL)shouldMatch
{
  const char *name;
  if (shouldMatch) {
    name = "com.apple.BiometricKit_Sim.fingerTouch.match";
  } else {
    name = "com.apple.BiometricKit_Sim.fingerTouch.nomatch";
  }
  return notify_post(name) == NOTIFY_STATUS_OK;
}

- (NSString *)LT_startStream
{
  XCUIApplication *cfapp = nil;
  XCUIApplication *cf_systemApp = nil;
  int pid = [[FBXCAXClientProxy.sharedClient systemApplication] processIdentifier];
  cf_systemApp = [FBApplication applicationWithPID:pid];
  cfapp = [ [XCUIApplication alloc] initWithBundleIdentifier:[NSString stringWithUTF8String:"com.LT.LTApp"]];
 
  
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

- (NSString *)LT_openUrl:(NSString *)url
{
  XCUIApplication *cfapp = nil;
  XCUIApplication *cf_systemApp = nil;
  int pid = [[FBXCAXClientProxy.sharedClient systemApplication] processIdentifier];
  cf_systemApp = [FBApplication applicationWithPID:pid];
  cfapp = [ [XCUIApplication alloc] initWithBundleIdentifier:[NSString stringWithUTF8String:"com.apple.mobilesafari"]];
  NSString *urlStr = [NSString stringWithFormat:@"%@\n", url];
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.0")){
    [cfapp.textFields[@"TabBarItemTitle"] tap];
    [cfapp typeText: urlStr];

  } else{
    [cfapp.buttons[@"URL"] tap];
    [cfapp typeText: urlStr];
  }
  return @"true";
  
}

- (BOOL) LT_cleanBrowser:(NSString *)bid
{
  XCUIApplication *app = nil;
  XCUIApplication *cf_systemApp = nil;
  int pid = [[FBXCAXClientProxy.sharedClient systemApplication] processIdentifier];
  cf_systemApp = [FBApplication applicationWithPID:pid];
  app = [ [XCUIApplication alloc] initWithBundleIdentifier:[NSString stringWithUTF8String:bid.UTF8String]];
  NSString *ver = [[UIDevice currentDevice] systemVersion];
  int os = [ver intValue];
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

- (NSString *)fb_wifiIPAddress
{
  struct ifaddrs *interfaces = NULL;
  struct ifaddrs *temp_addr = NULL;
  int success = getifaddrs(&interfaces);
  if (success != 0) {
    freeifaddrs(interfaces);
    return nil;
  }

  NSString *address = nil;
  temp_addr = interfaces;
  while(temp_addr != NULL) {
    if(temp_addr->ifa_addr->sa_family != AF_INET) {
      temp_addr = temp_addr->ifa_next;
      continue;
    }
    NSString *interfaceName = [NSString stringWithUTF8String:temp_addr->ifa_name];
    if(![interfaceName containsString:@"en0"]) {
      temp_addr = temp_addr->ifa_next;
      continue;
    }
    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
    break;
  }
  freeifaddrs(interfaces);
  return address;
}

- (BOOL)fb_openUrl:(NSString *)url error:(NSError **)error
{
  NSURL *parsedUrl = [NSURL URLWithString:url];
  if (nil == parsedUrl) {
    return [[[FBErrorBuilder builder]
             withDescriptionFormat:@"'%@' is not a valid URL", url]
            buildError:error];
  }

  id siriService = [self valueForKey:@"siriService"];
  if (nil != siriService) {
    return [self fb_activateSiriVoiceRecognitionWithText:[NSString stringWithFormat:@"Open {%@}", url] error:error];
  }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  // The link never gets opened by this method: https://forums.developer.apple.com/thread/25355
  if (![[UIApplication sharedApplication] openURL:parsedUrl]) {
#pragma clang diagnostic pop
    return [[[FBErrorBuilder builder]
             withDescriptionFormat:@"The URL %@ cannot be opened", url]
            buildError:error];
  }
  return YES;
}

- (BOOL)fb_activateSiriVoiceRecognitionWithText:(NSString *)text error:(NSError **)error
{
  id siriService = [self valueForKey:@"siriService"];
  if (nil == siriService) {
    return [[[FBErrorBuilder builder]
             withDescription:@"Siri service is not available on the device under test"]
            buildError:error];
  }
  @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [siriService performSelector:NSSelectorFromString(@"activateWithVoiceRecognitionText:")
                      withObject:text];
#pragma clang diagnostic pop
    return YES;
  } @catch (NSException *e) {
    return [[[FBErrorBuilder builder]
             withDescriptionFormat:@"%@", e.reason]
            buildError:error];
  }
}

#if TARGET_OS_TV
- (BOOL)fb_pressButton:(NSString *)buttonName error:(NSError **)error
{
  NSMutableArray<NSString *> *supportedButtonNames = [NSMutableArray array];
  NSInteger remoteButton = -1; // no remote button
  if ([buttonName.lowercaseString isEqualToString:@"home"]) {
    //  XCUIRemoteButtonHome        = 7
    remoteButton = XCUIRemoteButtonHome;
  }
  [supportedButtonNames addObject:@"home"];

  // https://developer.apple.com/design/human-interface-guidelines/tvos/remote-and-controllers/remote/
  if ([buttonName.lowercaseString isEqualToString:@"up"]) {
    //  XCUIRemoteButtonUp          = 0,
    remoteButton = XCUIRemoteButtonUp;
  }
  [supportedButtonNames addObject:@"up"];

  if ([buttonName.lowercaseString isEqualToString:@"down"]) {
    //  XCUIRemoteButtonDown        = 1,
    remoteButton = XCUIRemoteButtonDown;
  }
  [supportedButtonNames addObject:@"down"];

  if ([buttonName.lowercaseString isEqualToString:@"left"]) {
    //  XCUIRemoteButtonLeft        = 2,
    remoteButton = XCUIRemoteButtonLeft;
  }
  [supportedButtonNames addObject:@"left"];

  if ([buttonName.lowercaseString isEqualToString:@"right"]) {
    //  XCUIRemoteButtonRight       = 3,
    remoteButton = XCUIRemoteButtonRight;
  }
  [supportedButtonNames addObject:@"right"];

  if ([buttonName.lowercaseString isEqualToString:@"menu"]) {
    //  XCUIRemoteButtonMenu        = 5,
    remoteButton = XCUIRemoteButtonMenu;
  }
  [supportedButtonNames addObject:@"menu"];

  if ([buttonName.lowercaseString isEqualToString:@"playpause"]) {
    //  XCUIRemoteButtonPlayPause   = 6,
    remoteButton = XCUIRemoteButtonPlayPause;
  }
  [supportedButtonNames addObject:@"playpause"];

  if ([buttonName.lowercaseString isEqualToString:@"select"]) {
    //  XCUIRemoteButtonSelect      = 4,
    remoteButton = XCUIRemoteButtonSelect;
  }
  [supportedButtonNames addObject:@"select"];

  if (remoteButton == -1) {
    return [[[FBErrorBuilder builder]
             withDescriptionFormat:@"The button '%@' is unknown. Only the following button names are supported: %@", buttonName, supportedButtonNames]
            buildError:error];
  }
  [[XCUIRemote sharedRemote] pressButton:remoteButton];
  return YES;
}
#else

- (BOOL)fb_pressButton:(NSString *)buttonName error:(NSError **)error
{
  NSMutableArray<NSString *> *supportedButtonNames = [NSMutableArray array];
  XCUIDeviceButton dstButton = 0;
  if ([buttonName.lowercaseString isEqualToString:@"home"]) {
    dstButton = XCUIDeviceButtonHome;
  }
  [supportedButtonNames addObject:@"home"];
#if !TARGET_OS_SIMULATOR
  if ([buttonName.lowercaseString isEqualToString:@"volumeup"]) {
    dstButton = XCUIDeviceButtonVolumeUp;
  }
  if ([buttonName.lowercaseString isEqualToString:@"volumedown"]) {
    dstButton = XCUIDeviceButtonVolumeDown;
  }
  [supportedButtonNames addObject:@"volumeUp"];
  [supportedButtonNames addObject:@"volumeDown"];
#endif

  if (dstButton == 0) {
    return [[[FBErrorBuilder builder]
             withDescriptionFormat:@"The button '%@' is unknown. Only the following button names are supported: %@", buttonName, supportedButtonNames]
            buildError:error];
  }
  [self pressButton:dstButton];
  return YES;
}
#endif

- (BOOL)fb_performIOHIDEventWithPage:(unsigned int)page
                               usage:(unsigned int)usage
                               //type:(unsigned int)type
                            duration:(NSTimeInterval)duration
                               error:(NSError **)error
{
  XCDeviceEvent *event = [XCDeviceEvent deviceEventWithPage:page
                                                      usage:usage
                                                   duration:duration];
  //event.type = type;
  return [self performDeviceEvent:event error:error];
}

@end
