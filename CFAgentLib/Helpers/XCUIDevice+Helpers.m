// Copyright (c) 2015, Facebook Inc. All rights reserved.
// BSD license - See LICENSE

#import "XCUIDevice+Helpers.h"
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <notify.h>
#import <objc/runtime.h>
#import "VersionMacros.h"
#import "XCUIDevice.h"
#import "XCDeviceEvent.h"
#import "XCPointerEventPath.h"

@implementation XCUIDevice (Helpers)

static bool fb_isLocked;

+ (void)load {
  [self fb_registerAppforDetectLockState];
}

+ (void)fb_registerAppforDetectLockState {
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

- (BOOL)fb_isScreenLocked {
  return fb_isLocked;
}

- (NSString *)fb_wifiIPAddress {
  struct ifaddrs *interfaces = NULL;
  int success = getifaddrs(&interfaces);
  if (success != 0) {
    freeifaddrs(interfaces);
    return nil;
  }

  NSString *address = nil;
  struct ifaddrs *temp_addr = interfaces;
  while(temp_addr != NULL) {
    if(temp_addr->ifa_addr->sa_family != AF_INET) {
      temp_addr = temp_addr->ifa_next;
      continue;
    }
    NSString *interfaceName = [NSString stringWithUTF8String:temp_addr->ifa_name];
    if(![interfaceName containsString:@"en"]) {
      temp_addr = temp_addr->ifa_next;
      continue;
    }
    address = [NSString stringWithUTF8String:
        inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)
    ];
    break;
  }
  freeifaddrs(interfaces);
  return address;
}

- (BOOL)fb_pressButton:(NSString *)button {
#if TARGET_OS_TV
  NSInteger remoteButton = -1; // no remote button
  button = button.lowercaseString;
    
  // https://developer.apple.com/design/human-interface-guidelines/tvos/remote-and-controllers/remote/
  if ([button isEqualToString:@"home"]     ) remoteButton = XCUIRemoteButtonHome;      // 7
  if ([button isEqualToString:@"up"]       ) remoteButton = XCUIRemoteButtonUp;        // 0
  if ([button isEqualToString:@"down"]     ) remoteButton = XCUIRemoteButtonDown;      // 1
  if ([button isEqualToString:@"left"]     ) remoteButton = XCUIRemoteButtonLeft;      // 2
  if ([button isEqualToString:@"right"]    ) remoteButton = XCUIRemoteButtonRight;     // 3
  if ([button isEqualToString:@"menu"]     ) remoteButton = XCUIRemoteButtonMenu;      // 5
  if ([button isEqualToString:@"playpause"]) remoteButton = XCUIRemoteButtonPlayPause; // 6
  if ([button isEqualToString:@"select"]   ) remoteButton = XCUIRemoteButtonSelect;    // 4

  if (remoteButton == -1) return NO;
  [[XCUIRemote sharedRemote] pressButton:remoteButton];
  return YES;
#else
  button = button.lowercaseString;

  XCUIDeviceButton dstButton = 0;
  if ([button isEqualToString:@"home"]      ) dstButton = XCUIDeviceButtonHome;
  
#if !TARGET_OS_SIMULATOR
  if ([button isEqualToString:@"volumeup"]  ) dstButton = XCUIDeviceButtonVolumeUp;
  if ([button isEqualToString:@"volumedown"]) dstButton = XCUIDeviceButtonVolumeDown;
#endif

  if (dstButton == 0) return NO;
  [self pressButton:dstButton];
  return YES;
#endif
}


@end
