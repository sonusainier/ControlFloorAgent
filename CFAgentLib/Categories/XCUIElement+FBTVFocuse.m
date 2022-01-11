// Copyright (c) 2018, Facebook Inc.
// All rights reserved.
// BSD license - See LICENSE

#import "XCUIElement+FBTVFocuse.h"
#import <XCTest/XCUIRemote.h>
#import "FBApplication.h"

#if TARGET_OS_TV

int const MAX_ITERATIONS_COUNT = 100;

@implementation XCUIElement (FBTVFocuse)

- (BOOL)fb_setFocusWithError:(NSError**) error
{
  [FBApplication.fb_activeApplication fb_waitUntilStableWithTimeout:FBConfiguration.animationCoolOffTimeout];

  if (!self.wdEnabled) {
    if (error) {
      *error = [[FBErrorBuilder.builder withDescription:
                 [NSString stringWithFormat:@"'%@' element cannot be focused because it is disabled", self.description]] build];
    }
    return NO;
  }

  FBTVNavigationTracker *tracker = [FBTVNavigationTracker trackerWithTargetElement:self];
  for (int i = 0; i < MAX_ITERATIONS_COUNT; i++) {
    // Here hasFocus works so far. Maybe, it is because it is handled by `XCUIRemote`...
    if (self.hasFocus) {
      return YES;
    }

    if (!self.exists) {
      if (error) {
        *error = [[FBErrorBuilder.builder withDescription:
                   [NSString stringWithFormat:@"'%@' element is not reachable because it does not exist. Try to use XCUIRemote commands.", self.description]] build];
      }
      return NO;
    }

    FBTVDirection direction = tracker.directionToFocusedElement;
    if (direction != FBTVDirectionNone) {
      [[XCUIRemote sharedRemote] pressButton: (XCUIRemoteButton)direction];
    }
  }

  return NO;
}

- (BOOL)fb_selectWithError:(NSError**) error
{
  BOOL result = [self fb_setFocusWithError: error];
  if (result) {
    [[XCUIRemote sharedRemote] pressButton:XCUIRemoteButtonSelect];
  }
  return result;
}
@end

#endif
