// Copyright (C) 2021 Dry Ark LLC
// Cooperative License ( LICENSE_DRYARK )

#import "NNGServer2.h"
#import "XCUIDevice+FBHelpers.h"
#import "XCUIDevice+CFHelpers.h"
#import "XCTestDaemonsProxy.h"
#import "XCTestManager_ManagerInterface-Protocol.h"
#import "XCUIScreen.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <objc/runtime.h>
#import "VersionMacros.h"

@implementation NngThread2

-(NngThread2 *) init:(int)nngPort {
    self = [super init];
    _nngPort = nngPort;
    return self;
}

-(void) dealloc {
}

-(void) entry:(id)param {
    nng_rep_open(&_replySocket);
    
    char addr2[50];
    sprintf( addr2, "tcp://127.0.0.1:%d", _nngPort );
    nng_setopt_int( _replySocket, NNG_OPT_SENDBUF, 100000);
    int listen_error = nng_listen( _replySocket, addr2, NULL, 0);
    if( listen_error != 0 ) {
        NSLog( @"xxr error bindind on 127.0.0.1 : %d - %d", _nngPort, listen_error );
    }
    NSLog( @"NNG2 Ready" );
    XCUIDevice *device = XCUIDevice.sharedDevice;
  
    CIContext *context = [CIContext contextWithOptions:@{
        kCIContextWorkingFormat: @(kCIFormatRGBAf),
        kCIContextUseSoftwareRenderer: @NO
    }];
    XCUIScreen *screen = [XCUIScreen mainScreen];
    NSDictionary *jpegOptions = @{(NSString *)kCGImageDestinationLossyCompressionQuality:[NSNumber numberWithFloat:(float)0.8]};
    CGColorSpaceRef colorSpace = nil;
    CGAffineTransform resizeTransform = CGAffineTransformMakeScale( 1, 1 );
    bool transformSet = false;
  
    id<XCTestManager_ManagerInterface> proxy = [XCTestDaemonsProxy testRunnerProxy];
  
    bool is15plus = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.0");
  
    ujsonin_init();
    while( 1 ) {
        nng_msg *nmsg = NULL;
        nng_recvmsg( _replySocket, &nmsg, 0 );
        if( nmsg ) {
            const char *respText = NULL;
            char *respTextA = NULL;
            unsigned long long respLen = 0;
            node_hash *root = NULL;
            int msgLen = (int) nng_msg_len( nmsg );
            if( msgLen > 0 ) {
                char *msg = (char *) nng_msg_body( nmsg );
                //msg = strdup( msg );
                NSLog( @"nng req %.*s", msgLen, msg );
                char buffer[20];
                char *action = "";
                
                if( msg[0] == '{' ) {
                    int err;
                    root = parse( msg, msgLen, NULL, &err );
                    jnode *actionJnode = node_hash__get( root, "action", 6 );
                    if( actionJnode && actionJnode->type == 2 ) {
                        node_str *actionStrNode = (node_str *) actionJnode;
                        action = buffer;
                        sprintf(buffer,"%.*s",(int)actionStrNode->len,actionStrNode->str);
                    }
                }
                
                long alen = strlen( action );
                if( !strncmp( action, "done", 4 ) ) break;
                else if( !strncmp( action, "ping", 4 ) ) {
                    respText = "pong";
                }
                else if( !strncmp( action, "screenshot", 10 ) && alen == 10 ) {
                    @autoreleasepool {
                        CGImageRef cgImage = [[screen screenshot] image].CGImage;
                        CIImage *cImage = [[CIImage alloc] initWithCGImage:cgImage];
                        
                        if( !transformSet ) {
                            transformSet = true;
                            CGSize size = cImage.extent.size;
                            //CGFloat width = size.width;
                            CGFloat height = size.height;
                            CGFloat destH = 848;
                            CGFloat scale = destH / height;
                            resizeTransform = CGAffineTransformMakeScale( scale, scale );
                        }
                        cImage = [cImage imageByApplyingTransform:resizeTransform];
                        if( colorSpace == nil ) colorSpace = cImage.colorSpace;
                        NSData *jpegData = [context
                                            JPEGRepresentationOfImage:cImage
                                            colorSpace:colorSpace
                                            options:jpegOptions];
                        respTextA = malloc( jpegData.length );
                        memcpy( respTextA, jpegData.bytes, jpegData.length );
                        cImage = nil;
                        cgImage = nil;
                        respLen = jpegData.length;
                        jpegData = nil;
                      
                    }
                }
                else if( !strncmp( action, "screenshot2", 11 ) && alen == 11 ) {
                    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                    
                    @autoreleasepool {
                        __block NSData *imgData = nil;
                        unsigned int displayID = [screen displayID];
                        CIImage *cImage;
                        if (is15plus) {
                            XCUIScreenshot *shot = [screen screenshot];
                            imgData = [shot PNGRepresentation];
                            cImage = [CIImage imageWithData:imgData];
                            //CGImageRef cgImage = [shot image].CGImage;
                            //cImage = [[CIImage alloc] initWithCGImage:cgImage];
                        } else {
                            [proxy _XCT_requestScreenshotOfScreenWithID:displayID
                                                         withRect:CGRectNull
                                                              uti:(__bridge id)kUTTypeJPEG
                                               compressionQuality:0.8
                                                        withReply:^(NSData *data, NSError *error) {
                                if( error != nil ) return;
                                    imgData = data;
                                    dispatch_semaphore_signal(semaphore);
                                }];
                            dispatch_semaphore_wait(semaphore,dispatch_time(DISPATCH_TIME_NOW,NSEC_PER_SEC));
                            cImage = [CIImage imageWithData:imgData];
                        }
                     
                        imgData = nil;
                        if( !transformSet ) {
                            transformSet = true;
                            CGSize size = cImage.extent.size;
                            //CGFloat width = size.width;
                            CGFloat height = size.height;
                            CGFloat destH = 848;
                            CGFloat scale = destH / height;
                            resizeTransform = CGAffineTransformMakeScale( scale, scale );
                        }
                        cImage = [cImage imageByApplyingTransform:resizeTransform];
                        if( colorSpace == nil ) colorSpace = cImage.colorSpace;
                        
                        NSData *jpegData = [context
                                            JPEGRepresentationOfImage:cImage
                                            colorSpace:colorSpace
                                            options:jpegOptions];
                        respTextA = malloc( jpegData.length );
                        memcpy( respTextA, jpegData.bytes, jpegData.length );
                        cImage = nil;
                        respLen = jpegData.length;
                        jpegData = nil;
                    }
                }
            }
            else NSLog(@"xxr empty message");
            if( root ) node_hash__delete( root );
            nng_msg_free( nmsg );
            
            nng_msg *respN;
            nng_msg_alloc(&respN, 0);
            
            if( respTextA ) respText = respTextA;
            //[FBLogger logFmt:@"sending back :%s", respText ];
            if( respText ) nng_msg_append( respN, respText, respLen ? respLen : strlen( respText ) );
            int sendErr = nng_sendmsg( _replySocket, respN, 0 );
            if( sendErr ) {
                NSLog( @"sending err :%d", sendErr );
                nng_msg_free( respN );
            }
            
            if( respTextA ) free( respTextA );
        }
    }
    
    nng_close( _replySocket );
}

@end
