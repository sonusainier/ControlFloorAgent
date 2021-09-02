//  Copyright © 2021 DryArk LLC. All rights reserved.
//  Anti-Corruption License ( AC_LICENSE.TXT )

#import "NNGServer.h"
#import "XCElementSnapshot-XCUIElementSnapshot.h"
#import "FBConfiguration.h"
#import "FBLogger.h"
#import "FBSession.h"
#import "FBAlert.h"
#import "XCUIDevice+FBHelpers.h"
#import "XCUIDevice+CFHelpers.h"
#import "XCPointerEventPath.h"
#import "XCSynthesizedEventRecord.h"
#import "FBApplication.h"
#import "XCUIElement+FBFind.h"
#import "FBElementCache.h"
#import "XCUIElement+FBTap.h"
#import "XCUIElement+FBUID.h"
#import "XCUIApplication+FBQuiescence.h"
#import "XCUIApplication+FBHelpers.h"
#import <objc/runtime.h>

@implementation NngThread

-(NngThread *) init:(int)nngPort {
    self = [super init];
        
    _nngPort = nngPort;
    
    _typeMap = @[
        @"Any", @"Other",  @"Application",  @"Group", @"Window", @"Sheet", @"Drawer", @"Alert", @"Dialog",
        @"Button", @"RadioButton", @"RadioGroup", @"CheckBox", @"DisclosureTriangle", @"PopUpButton",
        @"ComboBox", @"MenuButton", @"ToolbarButton", @"Popover", @"Keyboard", @"Key", @"NavigationBar",
        @"TabBar", @"TabGroup", @"Toolbar", @"StatusBar", @"Table", @"TableRow", @"TableColumn", @"Outline",
        @"OutlineRow", @"Browser", @"CollectionView", @"Slider", @"PageIndicator", @"ProgressIndicator",
        @"ActivityIndicator", @"SegmentedControl", @"Picker", @"PickerWheel", @"Switch", @"Toggle", @"Link",
        @"Image", @"Icon", @"SearchField", @"ScrollView", @"ScrollBar", @"StaticText", @"TextField",
        @"SecureTextField", @"DatePicker", @"TextView", @"Menu", @"MenuItem", @"MenuBar", @"MenuBarItem",
        @"Map", @"WebView", @"IncrementArrow", @"DecrementArrow", @"Timeline", @"RatingIndicator",
        @"ValueIndicator", @"SplitGroup", @"Splitter", @"RelevanceIndicator", @"ColorWell", @"HelpTag",
        @"Matte", @"DockItem", @"Ruler", @"RulerMarker", @"Grid", @"LevelIndicator", @"Cell", @"LayoutArea",
        @"LayoutItem", @"Handle", @"Stepper", @"Tab"
    ];
  
    return self;
}

-(void) dealloc {
}

-(void) dictToStr:(NSDictionary *)dict str:(NSMutableString *)str depth:(int)depth
{
    NSString *spaces = [@"" stringByPaddingToLength:depth withString:@"  " startingAtIndex:0];
    //horizontalSizeClass,enabled,elementType,frame,title,verticalSizeClass,identifier,label,hasFocus,selected,children
    long elementType = [dict[@"elementType"] integerValue];
    NSString *ident = dict[@"identifier"];
    
    NSArray *children = dict[@"children"];
    unsigned long cCount = [children count];
    
    NSString *typeStr = _typeMap[ elementType ];
    [str appendFormat:@"%@<el type=\"%@\"", spaces, typeStr ];
    if( [ident length] != 0 ) [str appendFormat:@" id=\"%@\"", ident ];
  
    NSString *label = dict[@"label"];
    if( [label length] ) [str appendFormat:@" label=\"%@\"", label];
  
    NSString *title = dict[@"title"];
    if( [title length] ) [str appendFormat:@" title=\"%@\"", title];
  
    NSDictionary *rect = [dict objectForKey:@"frame"];
    [str
     appendFormat:@" x=%.0f y=%.0f w=%.0f h=%.0f",
     [rect[@"X"]     floatValue], [rect[@"Y"]      floatValue],
     [rect[@"Width"] floatValue], [rect[@"Height"] floatValue]];
   
    if( !cCount ) [str appendFormat:@"/>\n" ];
    else [str appendFormat:@">\n" ];
    
    for( unsigned long i = 0; i < [children count]; i++) {
        NSObject *child = [children objectAtIndex:i];
        //const char *className = class_getName( [child class] );
        //[str appendFormat:@"  i:%d className:%s\n",i,className ];
        [self dictToStr:(NSDictionary *)child str:str depth:(depth+2)];
    }
  
    if( cCount ) [str appendFormat:@"%@</el>\n", spaces ];
}

-(void) dictToJson:(NSDictionary *)dict str:(NSMutableString *)str depth:(int)depth
{
    NSString *spaces = [@"" stringByPaddingToLength:depth withString:@"  " startingAtIndex:0];
    //horizontalSizeClass,enabled,elementType,frame,title,verticalSizeClass,identifier,label,hasFocus,selected,children
    long elementType = [dict[@"elementType"] integerValue];
    NSString *ident = dict[@"identifier"];
    
    NSArray *children = dict[@"children"];
    unsigned long cCount = [children count];
    
    NSString *typeStr = _typeMap[ elementType ];
    [str appendFormat:@"%@{ \"type\":\"%@\",", spaces, typeStr ];
    if( [ident length] != 0 ) [str appendFormat:@" \"id\":\"%@\",", ident ];
  
    NSString *label = dict[@"label"];
    if( [label length] ) {
      if( [label containsString:@"\""] ) {
        label = [label stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
      }
      [str appendFormat:@" \"label\":\"%@\",", label];
    }
  
    NSString *title = dict[@"title"];
    if( [title length] ) [str appendFormat:@" \"title\":\"%@\",", title];
  
    NSDictionary *rect = [dict objectForKey:@"frame"];
    [str
     appendFormat:@" \"x\":%.0f, \"y\":%.0f, \"w\":%.0f, \"h\":%.0f",
     [rect[@"X"]     floatValue], [rect[@"Y"]      floatValue],
     [rect[@"Width"] floatValue], [rect[@"Height"] floatValue]];
   
    if( !cCount ) [str appendFormat:@"}\n" ];
    else [str appendFormat:@",\"c\":[\n" ];
    
    for( unsigned long i = 0; i < cCount; i++) {
        NSObject *child = [children objectAtIndex:i];
        //const char *className = class_getName( [child class] );
        //[str appendFormat:@"  i:%d className:%s\n",i,className ];
        [self dictToJson:(NSDictionary *)child str:str depth:(depth+2)];
        if( i != ( cCount -1 ) ) [str appendFormat:@",\n" ];
    }
  
    if( cCount ) [str appendFormat:@"%@]}\n", spaces ];
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
    [FBLogger logFmt:@"NNG Ready"];

    ujsonin_init();
    while( 1 ) {
        nng_msg *nmsg = NULL;
        nng_recvmsg( _replySocket, &nmsg, 0 );
        if( nmsg ) {
            const char *respText = NULL;
            char *respTextA = NULL;
            node_hash *root = NULL;
            int msgLen = (int) nng_msg_len( nmsg );
            if( msgLen > 0 ) {
                char *msg = (char *) nng_msg_body( nmsg );
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
                
                if( !strncmp( action, "done", 4 ) ) break;
                else if( !strncmp( action, "ping", 4 ) ) {
                    respText = "pong";
                }
                else if( !strncmp( action, "tap", 3 ) && strlen( action ) == 3 ) {
                    int x = node_hash__get_int( root, "x", 1 );
                    int y = node_hash__get_int( root, "y", 1 );
                    [XCUIDevice.sharedDevice cf_tap:x y:y];
                    respText = "ok";
                }
                else if( !strncmp( action, "tapFirm" , 7 ) ) {
                    int x = node_hash__get_int( root, "x", 1 );
                    int y = node_hash__get_int( root, "y", 1 );
                    double pressure = node_hash__get_double( root, "pressure", 8 );
                    [XCUIDevice.sharedDevice cf_tapFirm:x y:y pressure:pressure];
                    respText = "ok";
                }
                else if( !strncmp( action, "tapTime" , 7 ) ) {
                    int x = node_hash__get_int( root, "x", 1 );
                    int y = node_hash__get_int( root, "y", 1 );
                    double forTime = node_hash__get_double( root, "time", 4 );
                    [XCUIDevice.sharedDevice cf_tapTime:x y:y time:forTime];
                    respText = "ok";
                }
                else if( !strncmp( action, "swipe", 5 ) ) {
                    int x1 = node_hash__get_int( root, "x1", 2 );
                    int y1 = node_hash__get_int( root, "y1", 2 );
                    int x2 = node_hash__get_int( root, "x2", 2 );
                    int y2 = node_hash__get_int( root, "y2", 2 );
                    double delay = node_hash__get_double( root, "delay", 5 );
                    [FBLogger logFmt:@"swipe x1:%d y1:%d x2:%d y2:%d delay:%f", x1,y1,x2,y2,delay];
                    [XCUIDevice.sharedDevice
                     cf_swipe:x1
                     y1:y1 x2:x2 y2:y2 delay:delay];
                    respText = "ok";
                }
                else if( !strncmp( action, "iohid", 5 ) ) {
                    int page     = node_hash__get_int( root, "page", 4 );
                    int usage    = node_hash__get_int( root, "usage", 5 );
                    //int value    = node_hash__get_str( root, "value", 5 );
                    double duration = node_hash__get_double( root, "duration", 8 );
                    
                    NSError *error;
                    [XCUIDevice.sharedDevice
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
                    [XCUIDevice.sharedDevice
                     fb_pressButton:name2
                     error:&error];
                    free( name );
                    respText = "ok";
                }
                else if( !strncmp( action, "elClick", 7 ) ) {
                    FBSession *session = [FBSession activeSession];
                    //XCUIApplication *app = session.activeApplication;
                    
                    FBElementCache *elementCache = session.elementCache;
                    char *elId = node_hash__get_str( root, "id", 2 );
                    NSString *id2 = [NSString stringWithUTF8String:elId];
                  
                    XCUIElement *element = [elementCache elementForUUID:id2];
                    NSError *error = nil;
                    [element fb_tapWithError:&error];
                }
                else if( !strncmp( action, "elByName", 8 ) ) {
                    char *sid = node_hash__get_str( root, "sessionId", 9 );
                    NSString *sid2 = [NSString stringWithUTF8String:sid];
                  
                    char *name = node_hash__get_str( root, "name", 4 );
                    NSString *name2 = [NSString stringWithUTF8String:name];
                  
                    FBSession *session = [FBSession sessionWithIdentifier:sid2];
                    XCUIApplication *app = session.activeApplication;
                    
                    XCUIElement *element = [  [app
                                               fb_descendantsMatchingIdentifier:name2
                                               shouldReturnAfterFirstMatch:true]
                                            firstObject];
                    
                    //let predicate = NSPredicate(format: "identifier CONTAINS 'Cat'")
                    //let image = app.images.matching(predicate).element(boundBy: 0)
                    //XCUIElementQuery *q = app.buttons;
                    //XCUIElement *element = [q elementBoundByIndex:0 ];
                  
                    [session.elementCache storeElement:element];
                  
                    NSString *elId = element.fb_uid;
                    const char *eid = [elId UTF8String];
                    if( eid ) {
                        [FBLogger logFmt:@"getElement id:%s", eid];
                        respTextA = strdup( eid );
                    }
                }
                else if( !strncmp( action, "alertInfo", 9 ) ) {
                    FBSession *session = [FBSession activeSession];
                    FBAlert *alert = [FBAlert alertWithApplication:session.activeApplication];
                    
                    if(!alert.isPresent) {
                        respText = "{present:false}";
                    } else {
                        NSString *res = @"{\n  present:true\n  buttons:[\n";
                        NSString *alertText = alert.text;
                        NSArray *labels = alert.buttonLabels;
                        
                        for( unsigned long i = 0; i < [labels count]; i++) {
                            NSString *label = [labels objectAtIndex:i];
                            res = [res stringByAppendingFormat:@"    \"%@\"\n", label ];
                        }
                        alertText = [alertText stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
                        res = [res stringByAppendingFormat:@"]\n  alert:\"%@\"\n]\n}", alertText];
                      
                        respTextA = strdup( [res UTF8String] );
                    }
                }
                else if( !strncmp( action, "status", 6 ) ) {
                    NSString *sessionId = [FBSession activeSession].identifier ?: nil;
                    if( sessionId == nil ) {
                        respText = "{sessionId:\"\"}";
                    } else {
                        const char *sid = [sessionId UTF8String];
                        [FBLogger logFmt:@"status sid:%s", sid ];
                        respTextA = strdup( sid );
                    }
                }
                else if( !strncmp( action, "typeText", 8 ) ) {
                    char *text = node_hash__get_str( root, "text", 4 );
                    NSString *text2 = [NSString stringWithUTF8String:text];
                    FBSession *session = [FBSession activeSession];
                    XCUIApplication *app = session.activeApplication;
                    [app typeText: text2];
                }
                // Doesn't work...
                else if( !strncmp( action, "keyMod", 6 ) ) {
                    char *key = node_hash__get_str( root, "key", 3 );
                    NSString *key2 = [NSString stringWithUTF8String:key];
                    
                    [XCUIDevice.sharedDevice
                      cf_keyEvent:key2
                      modifierFlags:XCUIKeyModifierShift];
                }
                else if( !strncmp( action, "updateApplication", 17 ) ) {
                    FBSession *session = [FBSession activeSession];
                  
                    char *bi = node_hash__get_str( root, "bundleId", 8 );
                    FBApplication *app = [  [FBApplication alloc]
                                          initPrivateWithPath:nil
                                          bundleID:[NSString stringWithUTF8String:bi]];
                    [session setApplication:app];
                }
                else if( !strncmp( action, "source", 6 ) ) {
                    //application.fb_xmlRepresentation
                    
                    FBSession *session = [FBSession activeSession];
                    XCUIApplication *app = session.activeApplication;
                    //NSString *src = app.fb_xmlRepresentation;
                    XCUIElement *el = app;
                  
                    NSError *error = nil;
                    XCElementSnapshot *snapshot = (XCElementSnapshot *) [el snapshotWithError:&error];
                    if( error != nil ) [FBLogger logFmt:@"err:%@", error ];
                    NSDictionary *dict = [snapshot dictionaryRepresentation];
                    NSMutableString *str = [NSMutableString stringWithString:@""];
                    if( strlen( action ) > 6 ) {
                        [self dictToJson:dict str:str depth: 0];
                    } else {
                        [self dictToStr:dict str:str depth: 0];
                    }
                    //char buffer[1000];
                    //NSArray *keys = [dict allKeys];
                    /*for( int i = 0; i < [keys count]; i++) {
                        NSString *el = [keys objectAtIndex:i];
                        [FBLogger logFmt:@"el:%s", el ];
                    }*/
                    //NSString *keysStr = [keys componentsJoinedByString:@","];
                    respTextA = strdup( [str UTF8String] );
                }
                else if( !strncmp( action, "windowSize", 10 ) ) {
                    FBSession *session = [FBSession activeSession];
                    XCUIApplication *app = session.activeApplication;
                    CGRect frame = CGRectIntegral( app.frame );
                    
                    char output[100];
                    sprintf(output,"{width:%d,height:%d}",(int)frame.size.width,(int)frame.size.height);
                    respText = output;
                }
                else if( !strncmp( action, "createSession", 13 ) ) {
                    //NSDictionary<NSString *, id> *requirements;
                    //NSError *error;
                    
                    [FBConfiguration setShouldUseTestManagerForVisibilityDetection:true];
                    [FBConfiguration setShouldUseCompactResponses:false];
                    
                    //[FBConfiguration setElementResponseAttributes:elementResponseAttributes];
                    [FBConfiguration setShouldUseSingletonTestManager:true];
                    [FBConfiguration disableScreenshots];
                    
                    //[FBConfiguration setShouldTerminateApp:false];
                    
                    //NSNumber *delay = requirements[@"eventloopIdleDelaySec"];
                    //[XCUIApplicationProcessDelay setEventLoopHasIdledDelay:[delay doubleValue]];
                    //[XCUIApplicationProcessDelay disableEventLoopDelay];
                  
                    //FBConfiguration.waitForIdleTimeout = 0.2;
                    
                    char *bundleID = node_hash__get_str( root, "bundleId", 8 );
                    FBApplication *app = nil;
                                      
                    if( strlen(bundleID) ) {
                      app = [  [FBApplication alloc]
                             initPrivateWithPath:nil
                             bundleID:[NSString stringWithUTF8String:bundleID]];
                      app.fb_shouldWaitForQuiescence = true; // or nil
                      app.launchArguments = @[];
                      app.launchEnvironment = @{};
                      [app launch];
                      
                      if( app.processID == 0 ) {
                        // todo
                      }
                    }
                    
                    //[FBSession initWithApplication:app
                    //            defaultAlertAction:(id)requirements[DEFAULT_ALERT_ACTION]];
                    [FBSession initWithApplication:app];
                    
                    NSString *sessionId = [FBSession activeSession].identifier;
                    const char *sid = [sessionId UTF8String];
                    [FBLogger logFmt:@"createSession sid:%s", sid ];
                    respTextA = strdup( sid );
                }
            }
            else NSLog(@"xxr empty message");
            if( root ) node_hash__delete( root );
            nng_msg_free( nmsg );
            
            nng_msg *respN;
            nng_msg_alloc(&respN, 0);
            
            if( respTextA ) respText = respTextA;
            [FBLogger logFmt:@"sending back :%s", respText ];
            if( respText ) nng_msg_append( respN, respText, strlen( respText ) );
            int sendErr = nng_sendmsg( _replySocket, respN, 0 );
            if( sendErr ) [FBLogger logFmt:@"sending err :%d", sendErr ];

            nng_msg_free( respN );
            if( respTextA ) free( respTextA );
        }
    }
    
    nng_close( _replySocket );
}

@end
