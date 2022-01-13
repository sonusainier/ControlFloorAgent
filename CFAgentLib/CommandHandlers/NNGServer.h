// Copyright (C) 2021 Dry Ark LLC
// Cooperative License ( LICENSE_DRYARK )
#import <Foundation/Foundation.h>
#include "../../nng/nng.h"
#include "../../nng/protocol/reqrep0/rep.h"
#include "../../nng/protocol/reqrep0/req.h"
#include "../../ujsonin/ujsonin.h"

@interface NngThread : NSObject
-(NngThread *)init:(int)nngPort;
-(void)entry:(id)param;
@property int nngPort;
@property NSArray *typeMap;
@property nng_socket replySocket;
@end

@interface NetworkIface : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *ipv4;
@property (nonatomic, strong) NSString *ipv6;
@end
