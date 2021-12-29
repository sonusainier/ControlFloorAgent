// Copyright (C) 2021 Dry Ark LLC
// Cooperative License ( LICENSE_DRYARK )

#ifndef NNGServer_h
#define NNGServer_h

#import <Foundation/Foundation.h>
#include "../../nng/nng.h"
#include "../../nng/protocol/pipeline0/push.h"
#include "../../nng/protocol/pipeline0/pull.h"
#include "../../nng/protocol/reqrep0/rep.h"
#include "../../nng/protocol/reqrep0/req.h"
#include "../../ujsonin/ujsonin.h"

NS_ASSUME_NONNULL_BEGIN

@interface NngThread : NSObject
-(NngThread *)init:(int)nngPort;// framePasser:(id)framePasser;
-(void)dealloc;
-(void)entry:(id)param;
@property int nngPort;
@property NSArray *typeMap;
//@property FramePasser *framePasser;
@property nng_socket replySocket;
@end

NS_ASSUME_NONNULL_END


#endif /* NNGServer_h */
