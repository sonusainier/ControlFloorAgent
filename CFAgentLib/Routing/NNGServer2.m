//  Copyright © 2021 DryArk LLC. All rights reserved.
//  Anti-Corruption License ( AC_LICENSE.TXT )

#import "NNGServer2.h"
#import "FBLogger.h"
#import "XCUIDevice+FBHelpers.h"
#import "XCUIDevice+CFHelpers.h"
#import "FBXCTestDaemonsProxy.h"
#import "XCTestManager_ManagerInterface-Protocol.h"
#import "XCUIScreen.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <objc/runtime.h>
#import "FBMacros.h"

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
        [FBLogger logFmt:@"xxr error bindind on 127.0.0.1 : %d - %d", _nngPort, listen_error ];
    }
    [FBLogger logFmt:@"NNG2 Ready"];
    XCUIDevice *device = XCUIDevice.sharedDevice;
  
    CIContext *context = [CIContext contextWithOptions:@{
        kCIContextWorkingFormat: @(kCIFormatRGBAf),
        kCIContextUseSoftwareRenderer: @NO
    }];
    XCUIScreen *screen = [XCUIScreen mainScreen];
    NSDictionary *jpegOptions = @{(NSString *)kCGImageDestinationLossyCompressionQuality:[NSNumber numberWithFloat:(float)0.8]};
    CGColorSpaceRef colorSpace = nil;
    CGAffineTransform resizeTransform;
    bool transformSet = false;
  
    id<XCTestManager_ManagerInterface> proxy = [FBXCTestDaemonsProxy testRunnerProxy];
  
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
                [FBLogger logFmt:@"nng req %.*s", msgLen, msg ];
                char buffer[20];
                char *action = "";
                
                if( msg[0] == '{' ) {
                    int err;
                    root = parse( msg, msgLen, NULL, &err );
                    jnode *actionJnode = node_hash__get( root, "action", 6 );
                    if( actionJnode && actionJnode->type == 2 ) {
                        node_str *actionStrNode = (node_str *) actionJnode;
                        action = buffer;
                        sprintf(buffer,"%.*s",actionStrNode->len,actionStrNode->str);
                    }
                }
                
                int alen = strlen( action );
                if( !strncmp( action, "done", 4 ) ) break;
                else if( !strncmp( action, "ping", 4 ) ) {
                    respText = "pong";
                }
                else if( !strncmp( action, "tap", 3 ) && alen == 3 ) {
                    int x = node_hash__get_int( root, "x", 1 );
                    int y = node_hash__get_int( root, "y", 1 );
                    [device cf_tap:x y:y];
                    respText = "ok";
                }
                else if( !strncmp( action, "tapFirm" , 7 ) ) {
                    int x = node_hash__get_int( root, "x", 1 );
                    int y = node_hash__get_int( root, "y", 1 );
                    double pressure = node_hash__get_double( root, "pressure", 8 );
                    [device cf_tapFirm:x y:y pressure:pressure];
                    respText = "ok";
                }
                else if( !strncmp( action, "tapTime" , 7 ) ) {
                    int x = node_hash__get_int( root, "x", 1 );
                    int y = node_hash__get_int( root, "y", 1 );
                    double forTime = node_hash__get_double( root, "time", 4 );
                    [device cf_tapTime:x y:y time:forTime];
                    respText = "ok";
                }
                else if( !strncmp( action, "swipe", 5 ) ) {
                    int x1 = node_hash__get_int( root, "x1", 2 );
                    int y1 = node_hash__get_int( root, "y1", 2 );
                    int x2 = node_hash__get_int( root, "x2", 2 );
                    int y2 = node_hash__get_int( root, "y2", 2 );
                    double delay = node_hash__get_double( root, "delay", 5 );
                    [FBLogger logFmt:@"swipe x1:%d y1:%d x2:%d y2:%d delay:%f",x1,y1,x2,y2,delay];
                    [device cf_swipe:x1 y1:y1 x2:x2 y2:y2 delay:delay];
                    respText = "ok";
                }
                else if( !strncmp( action, "iohid", 5 ) ) {
                    int page        = node_hash__get_int( root, "page", 4 );
                    int usage       = node_hash__get_int( root, "usage", 5 );
                    //int value       = node_hash__get_str( root, "value", 5 );
                    double duration = node_hash__get_double( root, "duration", 8 );
                    
                    NSError *error;
                    [device
                     fb_performIOHIDEventWithPage:page
                     usage:usage
                     duration:duration
                     error:&error];
                    //if( error != nil ) [FBLogger logFmt:@"error %@", error];
                    
                    respText = "ok";
                }
                else if( !strncmp( action, "button", 6 ) ) {
                    NSError *error;
                    char *name = node_hash__get_str( root, "name", 4 );
                    NSString *name2 = [NSString stringWithUTF8String:name];
                    [device fb_pressButton:name2 error:&error];
                    free( name );
                    respText = "ok";
                }
                else if( !strncmp( action, "isLocked", 8 ) ) {
                    bool locked = device.fb_isScreenLocked;
                    respText = locked ? "{\"locked\":true}" : "{\"locked\":false}";
                }
                else if( !strncmp( action, "lock", 4 ) ) {
                    NSError *error;
                    bool success = [device fb_lockScreen:&error];
                    respText = success ? "{\"success\":true}" : "{\"success\":false}";
                }
                else if( !strncmp( action, "unlock", 6 ) ) {
                    NSError *error;
                    bool success = [device fb_unlockScreen:&error];
                    respText = success ? "{\"success\":true}" : "{\"success\":false}";
                }
                else if( !strncmp( action, "status", 6 ) ) {
                    respText = "{sessionId:\"fakesession\"}";
                }
                // Doesn't work...
                else if( !strncmp( action, "keyMod", 6 ) ) {
                    char *key = node_hash__get_str( root, "key", 3 );
                    NSString *key2 = [NSString stringWithUTF8String:key];
                    
                    [XCUIDevice.sharedDevice
                      cf_keyEvent:key2
                      modifierFlags:XCUIKeyModifierShift];
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
                    
                    __block NSData *imgData = nil;
                    unsigned int displayID = [screen displayID];
                    if (is15plus) {
                        XCUIScreenshot *shot = [screen screenshot];
                        imgData = [shot PNGRepresentation];
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
                    }
                    
                    @autoreleasepool {
                        CIImage *cImage = [CIImage imageWithData:imgData];
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
                [FBLogger logFmt:@"sending err :%d", sendErr ];
                nng_msg_free( respN );
            }
            
            if( respTextA ) free( respTextA );
        }
    }
    
    nng_close( _replySocket );
}

@end
