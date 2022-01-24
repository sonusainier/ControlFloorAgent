//  Copyright © 2021 DryArk LLC. All rights reserved.
//  Cooperative License ( LICENSE_DRYARK )
#import <XCTest/XCTest.h>
#import "../CFAgentLib/CommandHandlers/NNGServer.h"
#import "../CFAgentLib/CommandHandlers/NNGServer2.h"

@interface CFAgentTests : XCTestCase
@end

@implementation CFAgentTests

- (void)testWaitForCommands
{
  NngThread2 *nngThreadInst2 = [[NngThread2 alloc] init:8102];
  [NSThread detachNewThreadSelector:@selector(entry:) toTarget:nngThreadInst2 withObject:nil];
  
  NngThread *nngThreadInst = [[NngThread alloc] init:8101];
  //[NSThread detachNewThreadSelector:@selector(entry:) toTarget:nngThreadInst withObject:nil];
  [nngThreadInst entry:self];
}

@end
