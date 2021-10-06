//  Copyright © 2021 DryArk LLC. All rights reserved.
//  Anti-Corruption License ( AC_LICENSE.TXT )

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
-(void)dictToStr:(NSDictionary *)dict str:(NSMutableString *)str depth:(int)depth;
-(void)dealloc;
-(void)entry:(id)param;
@property int nngPort;
@property NSArray *typeMap;
//@property FramePasser *framePasser;
@property nng_socket replySocket;
@end

NS_ASSUME_NONNULL_END


#endif /* NNGServer_h */
