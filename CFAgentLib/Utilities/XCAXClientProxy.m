// Copyright (c) 2015, Facebook Inc. All rights reserved.
// BSD license - See LICENSE_FACEBOOK_BSD
#import "XCAXClientProxy.h"
#import "XCAXClient_iOS.h"
#import "XCUIDevice.h"

static id AXClient = nil;

@implementation XCAXClientProxy

+ (instancetype)sharedClient {
  static XCAXClientProxy *instance = nil;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    instance = [[self alloc] init];
    AXClient = [XCUIDevice.sharedDevice accessibilityInterface];
  });
  return instance;
}

- (XCUIElement *)elementAtPoint:(int)x y:(int)y {
  NSError *err = nil;
  CGPoint point = CGPointMake(x,y);
  return [AXClient accessibilityElementForElementAtPoint:point error:&err];
}

- (XCElementSnapshot *)snapshotForElement:(XCAccessibilityElement *)element
                               attributes:(NSArray<NSString *> *)attributes
                                 maxDepth:(NSNumber *)maxDepth
                                    error:(NSError **)error
{
  NSMutableDictionary *parameters = nil;
  NSDictionary *defaults = ( NSDictionary * )[AXClient defaultParameters];
  parameters = defaults.mutableCopy;
  parameters[@"maxDepth"] = maxDepth;

  if ([AXClient respondsToSelector:@selector(requestSnapshotForElement:attributes:parameters:error:)]) {
    id result = [AXClient requestSnapshotForElement:element
                                         attributes:attributes
                                         parameters:[parameters copy]
                                              error:error];
    return [result valueForKey:@"_rootElementSnapshot"] ?: result;
  }
  return [AXClient snapshotForElement:element
                           attributes:attributes
                           parameters:[parameters copy]
                                error:error];
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

- (XCUIApplication *)monitoredApplicationWithProcessIdentifier:(int)pid {
  static id processTracker = nil;
  static dispatch_once_t once;
  dispatch_once( &once, ^{
    if( [AXClient respondsToSelector:@selector(applicationProcessTracker)] )
      processTracker = [AXClient applicationProcessTracker];
  } );
  if( processTracker == nil ) return nil;
  return [processTracker monitoredApplicationWithProcessIdentifier:pid];
}

@end
