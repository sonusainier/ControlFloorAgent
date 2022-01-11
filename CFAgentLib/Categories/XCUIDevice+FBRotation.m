// Copyright (c) 2015, Facebook Inc.
// All rights reserved.
// BSD license - See LICENSE

#import "XCUIDevice+FBRotation.h"

# if !TARGET_OS_TV

@implementation XCUIDevice (FBRotation)

- (NSDictionary *)fb_rotationMapping
{
    static NSDictionary *rotationMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rotationMap =
        @{
          @(UIDeviceOrientationUnknown) : @{@"x" : @(-1), @"y" : @(-1), @"z" : @(-1)},
          @(UIDeviceOrientationPortrait) : @{@"x" : @(0), @"y" : @(0), @"z" : @(0)},
          @(UIDeviceOrientationPortraitUpsideDown) : @{@"x" : @(0), @"y" : @(0), @"z" : @(180)},
          @(UIDeviceOrientationLandscapeLeft) : @{@"x" : @(0), @"y" : @(0), @"z" : @(270)},
          @(UIDeviceOrientationLandscapeRight) : @{@"x" : @(0), @"y" : @(0), @"z" : @(90)},
          @(UIDeviceOrientationFaceUp) : @{@"x" : @(90), @"y" : @(0), @"z" : @(0)},
          @(UIDeviceOrientationFaceDown) : @{@"x" : @(270), @"y" : @(0), @"z" : @(0)},
          };
    });
    return rotationMap;
}

@end
#endif
