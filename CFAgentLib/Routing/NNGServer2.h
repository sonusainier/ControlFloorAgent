//  Copyright © 2021 DryArk LLC. All rights reserved.
//  Anti-Corruption License ( AC_LICENSE.TXT )

#ifndef NNGServer2_h
#define NNGServer2_h

#import <Foundation/Foundation.h>
#include "../../nng/nng.h"
#include "../../nng/protocol/pipeline0/push.h"
#include "../../nng/protocol/pipeline0/pull.h"
#include "../../nng/protocol/reqrep0/rep.h"
#include "../../nng/protocol/reqrep0/req.h"
#include "../../ujsonin/ujsonin.h"

NS_ASSUME_NONNULL_BEGIN

@interface NngThread2 : NSObject
-(NngThread2 *)init:(int)nngPort;
-(void)dealloc;
-(void)entry:(id)param;
@property int nngPort;
@property nng_socket replySocket;
@end

NS_ASSUME_NONNULL_END


#endif /* NNGServer2_h */
