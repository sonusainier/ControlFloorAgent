//  Copyright © 2021 DryArk LLC. All rights reserved.
//  Cooperative License ( LICENSE_DRYARK )
#import <Foundation/Foundation.h>
#include "../../nng/nng.h"
#include "../../nng/protocol/reqrep0/rep.h"
#include "../../nng/protocol/reqrep0/req.h"
#include "../../ujsonin/ujsonin.h"

@interface NngThread2 : NSObject
-(NngThread2 *)init:(int)nngPort;
-(void)entry:(id)param;
@property int nngPort;
@property nng_socket replySocket;
@end
