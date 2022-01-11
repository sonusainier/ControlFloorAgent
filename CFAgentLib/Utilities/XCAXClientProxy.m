// Copyright (c) 2015, Facebook Inc. All rights reserved.
// BSD license - See LICENSE

#import "XCAXClientProxy.h"
#import <objc/runtime.h>
#import "XCAXClient_iOS.h"
#import "XCUIDevice.h"

static id AXClient = nil;

@implementation XCAXClient_iOS (CFAgent)

+ (void)load {
  /*static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      Class class = [self class];

      SEL originalSelector = @selector(defaultParameters);
      SEL swizzledSelector = @selector(fb_getParametersForElementSnapshot);

      Method originalMethod = class_getInstanceMethod(class, originalSelector);
      Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

      BOOL didAddMethod =
          class_addMethod(class,
              originalSelector,
              method_getImplementation(swizzledMethod),
              method_getTypeEncoding(swizzledMethod));

      if (didAddMethod) {
          class_replaceMethod(class,
              swizzledSelector,
              method_getImplementation(originalMethod),
              method_getTypeEncoding(originalMethod));
      } else {
          method_exchangeImplementations(originalMethod, swizzledMethod);
      }
  });*/
}

@end

@implementation XCAXClientProxy

+ (instancetype)sharedClient {
  static XCAXClientProxy *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
    if ([XCAXClient_iOS.class respondsToSelector:@selector(sharedClient)]) {
      AXClient = [XCAXClient_iOS sharedClient];
    } else {
      AXClient = [XCUIDevice.sharedDevice accessibilityInterface];
    }
  });
  return instance;
}

- (XCUIElement *)elementAtPoint:(int)x y:(int)y {
  NSError *err = nil;
  CGPoint point = CGPointMake(x,y);
  //FBAXClient = [XCAXClient_iOS sharedClient];
  //XCUIRemoteAccessibilityInterface *remote = [FBAXClient remoteAccessibilityInterface];
  
  return [AXClient accessibilityElementForElementAtPoint:point error:&err];
  //return [FBAXClient requestElementAtPoint:point];// error:(id *)&err];
}

- (BOOL)setAXTimeout:(NSTimeInterval)timeout error:(NSError **)error {
  return [AXClient _setAXTimeout:timeout error:error];
}

- (NSArray<XCAccessibilityElement *> *)activeApplications {
  return [AXClient activeApplications];
}

- (XCAccessibilityElement *)systemApplication {
  return [AXClient systemApplication];
}

- (void)notifyWhenNoAnimationsAreActiveForApplication:(XCUIApplication *)application
                                                reply:(void (^)(void))reply
{
  [AXClient notifyWhenNoAnimationsAreActiveForApplication:application reply:reply];
}

- (BOOL)hasProcessTracker {
  static BOOL hasTracker;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    hasTracker = [AXClient respondsToSelector:@selector(applicationProcessTracker)];
  });
  return hasTracker;
}

- (XCUIApplication *)monitoredApplicationWithProcessIdentifier:(int)pid {
  return [[AXClient applicationProcessTracker] monitoredApplicationWithProcessIdentifier:pid];
}

@end
