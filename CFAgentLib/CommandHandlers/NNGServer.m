//  Copyright © 2021 DryArk LLC. All rights reserved.
//  Cooperative License ( LICENSE_DRYARK )
#import "NNGServer.h"
#import "XCElementSnapshot-TreeManagement.h"
#import "XCUIDevice+Helpers.h"
#import "XCUIDevice+Helpers.h"
#import "XCPointerEventPath.h"
#import "XCSynthesizedEventRecord.h"
#import "XCUIApplication.h"
#import "XCUIDevice+Helpers.h"
#import <objc/runtime.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "XCTestDriver.h"
#import "XCTRunnerDaemonSession.h"
#import "XCUIApplication+Helpers.h"
#import "XCTMessagingChannel_RunnerToDaemon-Protocol.h"
#import "XCAXClient_iOS+Helpers.h"
#import "XCAccessibilityElement.h"
#import "CFA.h"
#import "XCElementSnapshot+Helpers.h"
#import "SnapshotApplication.h"
#import "VersionMacros.h"
//#import "XCUIElementQuery.h"

@implementation NetworkIface
@end

@interface NSObject (Private)
- (NSString *) _methodDescription;
@end

@implementation NngThread

-(NngThread *) init:(int)nngPort {
    self = [super init];
    _nngPort = nngPort;
    return self;
}

struct myData_s {
    XCUIDevice *device;
    NSMutableDictionary *dict;
    XCUIApplication *app;
    SnapshotApplication *systemApp;
    char *action;
    XCUIApplication *sbApp;
    NngThread *nngServer;
};
typedef struct myData_s myData;

NSString *createKey(void) {
    NSString *keyCharSet = @"abcdefghijklmnopqrstuvwxyz0123456789";
    int setLength = (int) [keyCharSet length];
  
    NSMutableString *key = [NSMutableString stringWithCapacity: 5];
    for( int i=0; i<5; i++ ) {
        [key appendFormat: @"%C", [keyCharSet characterAtIndex: arc4random_uniform(setLength)]];
    }
    return key;
}

NSString *handlePing( myData *my, node_hash *root ) {
    return @"pong";
}

NSString *handleTap( myData *my, node_hash *root ) {
    int x = node_hash__get_int( root, "x", 1 );
    int y = node_hash__get_int( root, "y", 1 );
    [my->device cf_tap:x y:y];
    return @"ok";
}

NSString *handleDoubletap( myData *my, node_hash *root ) {
    int x = node_hash__get_int( root, "x", 1 );
    int y = node_hash__get_int( root, "y", 1 );
    [my->device cf_doubletap:my->app x:x y:y];
    return @"ok";
}

NSString *handleMouseDown( myData *my, node_hash *root ) {
    int x = node_hash__get_int( root, "x", 1 );
    int y = node_hash__get_int( root, "y", 1 );
    [my->device cf_mouseDown:x y:y];
    return @"ok";
}

NSString *handleMouseUp( myData *my, node_hash *root ) {
    int x = node_hash__get_int( root, "x", 1 );
    int y = node_hash__get_int( root, "y", 1 );
    [my->device cf_mouseUp:x y:y];
    return @"ok";
}

NSString *handleTapFirm( myData *my, node_hash *root ) {
    int x = node_hash__get_int( root, "x", 1 );
    int y = node_hash__get_int( root, "y", 1 );
    double pressure = node_hash__get_double( root, "pressure", 8 );
    [my->device cf_tapFirm:x y:y pressure:(CGFloat)pressure];
    return @"ok";
}

NSString *handleTapTime( myData *my, node_hash *root ) {
    int x = node_hash__get_int( root, "x", 1 );
    int y = node_hash__get_int( root, "y", 1 );
    double forTime = node_hash__get_double( root, "time", 4 );
    [my->device cf_tapTime:x y:y time:(CGFloat)forTime];
    [NSThread sleepForTimeInterval:forTime];
    return @"ok";
}
            
NSString *handleSwipe( myData *my, node_hash *root ) {
    int x1 = node_hash__get_int( root, "x1", 2 );
    int y1 = node_hash__get_int( root, "y1", 2 );
    int x2 = node_hash__get_int( root, "x2", 2 );
    int y2 = node_hash__get_int( root, "y2", 2 );
    double delay = node_hash__get_double( root, "delay", 5 );
    NSLog( @"swipe x1:%d y1:%d x2:%d y2:%d delay:%f",x1,y1,x2,y2,delay );
    [my->device cf_swipe:x1 y1:y1 x2:x2 y2:y2 delay:(CGFloat)delay];
    [NSThread sleepForTimeInterval:delay];
    return @"ok";
}

NSString *handleButton( myData *my, node_hash *root ) {
    NSString *name = node_hash__get_str_ns( root, "name", 4 );
    
    static NSMutableDictionary *nameMap = nil;
    static dispatch_once_t once;
    dispatch_once( &once, ^{
      nameMap = [[NSMutableDictionary alloc] initWithCapacity:3];
      [nameMap setObject:[NSNumber numberWithInt:XCUIDeviceButtonHome] forKey:@"home"];
      [nameMap setObject:[NSNumber numberWithInt:XCUIDeviceButtonVolumeUp] forKey:@"volumeup"];
      [nameMap setObject:[NSNumber numberWithInt:XCUIDeviceButtonVolumeDown] forKey:@"volumedown"];
    } );
        
    NSNumber *num = [nameMap valueForKey:name];
    [my->device pressButton:[num integerValue]];
    return @"ok";
}

NSString *handleStartBroadcastApp( myData *my, node_hash *root ) {
    [my->device cf_startBroadcastApp];
    return @"ok";
}

NSString *handleToLauncher( myData *my, node_hash *root ) {
    if( my->sbApp.state < 2 ) [my->sbApp launch];
    else                      [my->sbApp activate];
    return @"ok";
}

NSString *handleIohid( myData *my, node_hash *root ) {
    int page        = node_hash__get_int( root, "page", 4 );
    int usage       = node_hash__get_int( root, "usage", 5 );
    double duration = node_hash__get_double( root, "duration", 8 );
    char *modifier  = node_hash__get_str( root, "modifier", 8 );
    
    NSError *error;
    if( modifier ) {
        unsigned long len = strlen( modifier );
        XCUIKeyModifierFlags flags = 0;
        if( modifier[0] == 'c' && len >= 3 ) {
            if( modifier[2] == 'n' ) flags = XCUIKeyModifierControl;
            if( modifier[1] == 'm' ) flags = XCUIKeyModifierCommand;
        }
        if( modifier[0] == 'o' ) flags = XCUIKeyModifierOption;
        if( modifier[0] == 'f' ) flags = XCUIKeyModifierFunction;
        if( modifier[0] == 's' ) flags = XCUIKeyModifierShift;
        
        if( flags == 0 ) {
            NSLog( @"Invalid key modifier specified" );
        } else {
            [my->device cf_iohid_with_modifier:page
                           usage:usage
                        duration:duration
                        modifier:flags
                           error:&error];
        }
    }
    else {
        [my->device cf_iohid:page
                       usage:usage
                    duration:duration
                       error:&error];
    }
    if( error != nil ) NSLog( @"error %@", error );
    
    return @"ok";
}

NSString *handleHomeBtn( myData *my, node_hash *root ) {
    double duration = 0.1;
    [my->device cf_holdHomeButtonForDuration:duration];
    return @"ok";
}

NSArray *getInterfaces(void) {
    NSMutableArray *ifaces = [[NSMutableArray alloc] init];
    struct ifaddrs *ifaddrs = NULL;
    if( getifaddrs( &ifaddrs ) || ifaddrs == NULL ) {
      // TODO error
      return ifaces;
    }
    for( struct ifaddrs *iface = ifaddrs; iface; iface = iface->ifa_next ) {
      if( iface->ifa_addr && iface->ifa_addr->sa_family == AF_INET ) {
        NetworkIface *ob = [[NetworkIface alloc] init];
        struct sockaddr_in *addr_in = ( struct sockaddr_in *) iface->ifa_addr;
        ob.ipv4 = ( NSString * _Nonnull )[NSString stringWithUTF8String:inet_ntoa( addr_in->sin_addr )];
        ob.name = ( NSString * _Nonnull )[NSString stringWithUTF8String:iface->ifa_name];
        [ifaces addObject:ob];
      }
      if( iface->ifa_addr && iface->ifa_addr->sa_family == AF_INET6 ) {
        NetworkIface *ob = [[NetworkIface alloc] init];
        struct sockaddr_in6 *addr_in = ( struct sockaddr_in6 *) iface->ifa_addr;
        char *ipv6 = malloc( INET6_ADDRSTRLEN );
        inet_ntop( AF_INET6, &(addr_in->sin6_addr), ipv6, INET6_ADDRSTRLEN );
        ob.ipv4 = ( NSString * _Nonnull )[NSString stringWithUTF8String:ipv6];
        free( ipv6 );
        ob.name = ( NSString * _Nonnull )[NSString stringWithUTF8String:iface->ifa_name];
        [ifaces addObject:ob];
      }
    }
    return ifaces;
}

NSString *handleWifiIp( myData *my, node_hash *root ) {
    NSArray *ifaces = getInterfaces();
    NSString *ipv4 = nil;
    for( id ifaceId in ifaces ) {
        NetworkIface *iface = (NetworkIface *) ifaceId;
        if( [iface.name hasPrefix:@"en"] ) {
            if( iface.ipv4 != nil ) ipv4 = iface.ipv4;
        }
    }
    return ipv4;
}

NSString *handleStartLTStream( myData *my, node_hash *root, char **outVal ) {
    NSString *success = [my->device LT_startStream];
    return success;
}

NSString *handleOpenSafari( myData *my, node_hash *root, char **outVal ) {
    char *text = node_hash__get_str_escapes( root, "url", 3 );
    NSString *text2 = [NSString stringWithUTF8String:text];
    [my->device LT_openUrl:text2];
    return @"ok";
}

NSString *handleCleanBrowser( myData *my, node_hash *root, char **outVal ) {
    char *text = node_hash__get_str_escapes( root, "bid", 3 );
    NSString *text2 = [NSString stringWithUTF8String:text];
    bool success = [my->device LT_cleanBrowser:text2];
    return success ? @"{\"success\":true}" : @"{\"success\":false}";
}

NSString *handleElClick( myData *my, node_hash *root ) {
    NSString *elId = node_hash__get_str_ns( root, "id", 2 );
    
    XCUIElement *element = my->dict[elId];
    [my->dict removeObjectForKey:elId];

    if( element == nil ) {
        return @"failed to find element";
    } else {
        //if (!IOS_LESS_THAN(@"14.0")) {
            [element tap];
        /*} else {
            NSError *error;
            XCElementSnapshot *snapshot = (XCElementSnapshot *) [element snapshotWithError:&error];
            double x = snapshot.centerX;
            double y = snapshot.centerY;
            NSLog( @"tapping a %f,%f", x, y );
            [my->device cf_tap:x y:y];
        }*/
    }
    return @"ok";
}

NSString *handleElTouchAndHold( myData *my, node_hash *root ) {
    NSString *elId = node_hash__get_str_ns( root, "id", 2 );
    
    XCUIElement *element = my->dict[elId];
    [my->dict removeObjectForKey:elId];
    double forTime = node_hash__get_double( root, "time", 4 );
    [element pressForDuration:forTime];
    return @"ok";
}

NSString *handleElForceTouch( myData *my, node_hash *root ) {
    NSString *elId = node_hash__get_str_ns( root, "id", 2 );
    
    XCUIElement *element = my->dict[elId];
    [my->dict removeObjectForKey:elId];
    
    //double forTime = node_hash__get_double( root, "time", 4 );
    double pressure = node_hash__get_double( root, "pressure", 8 );
    if( pressure < 0 ) pressure = -pressure; // bug
    //[element pressForDuration:forTime];
    //NSError *err;
    CGRect frame = [element frame];
    CGFloat x = frame.origin.x;
    CGFloat y = frame.origin.y;
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    x += width / 2;
    y += height / 2;
    [my->device cf_tapFirm:(int)x y:(int)y pressure:pressure];
    return @"ok";
}

NSString *handleSysElPos( myData *my, node_hash *root ) {
    NSString *name = node_hash__get_str_ns( root, "id", 2 );
    NSString *type = node_hash__get_str_ns( root, "type", 4 );
    
    SnapFindElResult *result = [my->systemApp findEl:name withTypeStr:type];
    
    //NSMutableString *str = [result.el asJson];
    //[str appendFormat:@"{\nx: %f y:%f", result.x, result.y ];
    if( result == nil ) return @"";
    
    return [NSString stringWithFormat:@"{x: %.02f, y: %.02f}", result.x, result.y];
}

void elTreeToStr( XCUIElement *el, NSMutableString *str, int depth ) {
    NSString *spaces     = [@"" stringByPaddingToLength:depth withString:@"  " startingAtIndex:0];
    long elementType     = el.elementType;
    NSString *ident      = el.identifier;
    XCUIElementQuery *q = el.query;
    XCUIElementQuery *children    = [q childrenMatchingType:XCUIElementTypeAny];
    unsigned long cCount = [children count];
    
    NSString *typeStr    = [CFA typeStr:elementType];
    [str appendFormat:@"%@<el type=\"%@\"", spaces, typeStr ];
    if( [ident length] != 0 ) [str appendFormat:@" id=\"%@\"", ident ];
  
    NSString *label = el.label;
    if( [label length] ) [str appendFormat:@" label=\"%@\"", label];
  
    NSString *title = el.title;
    if( [title length] ) [str appendFormat:@" title=\"%@\"", title];
  
    CGRect rect = el.frame;
    [str appendFormat:@" \"x\":%.0f, \"y\":%.0f, \"w\":%.0f, \"h\":%.0f",
      rect.origin.x, rect.origin.y,
      rect.size.width, rect.size.height];
   
    if( !cCount ) [str appendFormat:@"/>\n" ];
    else [str appendFormat:@">\n" ];
    
    NSArray<XCUIElement *> *children2 = children.allElementsBoundByIndex;
    for( unsigned long i = 0; i < [children2 count]; i++) {
        NSObject *child = [children2 objectAtIndex:i];
        elTreeToStr( (XCUIElement *)child, str, depth+2 );
    }
  
    if( cCount ) [str appendFormat:@"%@</el>\n", spaces ];
}

NSString *handleTest( myData *my, node_hash *root ) {
    //SnapFindElResult *result = [my->systemApp findEl:name withTypeStr:type];
    SnapshotApplication *app = my->systemApp;
    XCUIElement *el = (XCUIApplication *) app.app;
    NSMutableString *str = [NSMutableString stringWithString:@""];
    
    //[str appendString:el.debugDescription];
    
    //NSString *methodStr = [el performSelector:@selector(_methodDescription) ];
    //[str appendString:methodStr];
    
    //elTreeToStr( el, str, 40 );
    NSError *error;
    XCElementSnapshot *snap = (XCElementSnapshot *) [el snapshotWithError:&error];
    
    NSString *snapMethods = [snap performSelector:@selector(_methodDescription) ];
    [str appendString:snapMethods];
    
    //XCUIElementQuery *query = [snap descendantsMatchingType:XCUIElementTypeAny];
    //[str appendString:[snap asJson]];
    
    /*NSSet *subFrames = [snap uniqueDescendantSubframes];
    for( NSValue *frame in subFrames ) {
        //NSString *methodStr = [frame performSelector:@selector(_methodDescription) ];
        //[str appendString:methodStr];
        
        const char *frameClass = [frame objCType];
        [str appendFormat:@"Class:%s\n", frameClass];
        CGRect rect = frame.CGRectValue;
        [str appendFormat:@"x:%f y:%f w:%f h:%f\n", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
        //[str appendFormat:@"Class:%@\n", NSStringFromClass( [frame class] ) ];
    }*/
    
    return str;
}

NSString *handleGetEl( myData *my, node_hash *root ) {
    NSString *name = node_hash__get_str_ns( root, "id", 2 );
    
    NSString *type = node_hash__get_str_ns( root, "type", 4 );
    long typeNum = 0;
    if( type ) {
        typeNum = [CFA typeNum:type];
    }
  
    XCUIElementQuery *query = [my->app descendantsMatchingType:typeNum];
    XCUIElement *el = [query elementMatchingType:typeNum identifier:name];
    
    double wait = node_hash__get_double( root, "wait", 4 );
    if( wait < 0 ) {
        bool exists = [el waitForExistenceWithTimeout:wait];
        if( !exists ) el = nil;
    }
    else if( !el.exists ) el = nil;
    
    if( el == nil ) return @"";
    
    NSString *key;
    for( int i=0;i<20;i++ ) {
        key = createKey();
        if( my->dict[key] == nil ) break;
    }
    my->dict[key] = el;
    
    return key;
}

NSString *handleGetOrientation( myData *my, node_hash *root ) {
    NSInteger orientation = my->systemApp.app.interfaceOrientation;
    
    // See https://developer.apple.com/documentation/uikit/uiinterfaceorientation?language=objc
    switch( orientation ) {
        case UIInterfaceOrientationPortrait:
            return @"portrait";
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"portraitUpsideDown";
        case UIInterfaceOrientationLandscapeLeft:
            return @"landscapeLeft";
        case UIInterfaceOrientationLandscapeRight:
            return @"landscapeRight";
    }
    return [NSString stringWithFormat:@"unknown orientation:%ld", (long)orientation];
}

NSString *handleSetOrientation( myData *my, node_hash *root ) {
    NSString *o = node_hash__get_str_ns( root, "orientation", 11 );
    if( o == nil ) return @"Must pass orientation";
     
    if( [o isEqualToString:@"portrait"] ) {
        my->device.orientation = UIDeviceOrientationPortrait;
    }
    else if( [o isEqualToString:@"portraitUpsideDown"] ) {
        my->device.orientation = UIDeviceOrientationPortraitUpsideDown;
    }
    else if( [o isEqualToString:@"landscapeLeft"] ) {
        my->device.orientation = UIDeviceOrientationLandscapeLeft;
    }
    else if( [o isEqualToString:@"landscapeRight"] ) {
        my->device.orientation = UIDeviceOrientationLandscapeRight;
    } else {
        return [NSString stringWithFormat:@"unknown orientation:%@", o];
    }
    return @"ok";
}

NSString *handleAlertInfo( myData *my, node_hash *root ) {
    SnapshotApplication *app = my->systemApp;
    SnapFindElResult *alertRes = [app findEl:nil withTypeStr:@"alert"];
    XCElementSnapshot *alert = alertRes.el;
    if( alert == nil ) return @"{present:false}";
    
    NSMutableString *res = [[NSMutableString alloc] initWithString:@"{\n  present:true\n  buttons:[\n"];
    
    NSArray *types = @[ @(XCUIElementTypeButton) ];
    NSArray<XCElementSnapshot *> *buttons = [alert findEls:nil withType:types];
    
    for( XCElementSnapshot *button in buttons ) {
        [res appendFormat:@"    \"%@\"\n", button.value ?: button.label ];
    }
    [res appendString:@"  ]\n"];
    
    NSArray *textTypes = @[
        @(XCUIElementTypeTextView),
        @(XCUIElementTypeStaticText)
    ];
    NSArray<XCElementSnapshot *> *texts = [alert findEls:nil withType:textTypes];
    
    bool foundTitle = false;
    for( XCElementSnapshot *text in texts) {
        NSString *label = text.value;
        if( label == nil ) {
            if(text.elementType == XCUIElementTypeStaticText) label = text.label;
            if(text.elementType == XCUIElementTypeTextView  ) label = text.placeholderValue;
        }
        
        if( !foundTitle ) {
            foundTitle = true;
            [res appendFormat:@"  title:\"%@\"\n", label ];
        } else {
            [res appendFormat:@"  descr:\"%@\"\n", label ];
        }
    }
    [res appendString:@"}"];
    return res;
}

NSString *handleSiri( myData *my, node_hash *root ) {
    NSString *text = node_hash__get_str_ns( root, "text", 4 );
    [my->device.siriService activateWithVoiceRecognitionText:text];
    return @"ok";
}

NSString *handleTypeText( myData *my, node_hash *root ) {
    char *text = node_hash__get_str_escapes( root, "text", 4 );
    NSString *text2 = [NSString stringWithUTF8String:text];
    [my->app typeText: text2];
    return @"ok";
}

NSString *handleTypeKey( myData *my, node_hash *root ) {
    //char *key = node_hash__get_int( root, "key", 3 );
    
    //XCPointerEventPath *path = [[XCPointerEventPath alloc] initForTextInput];
    //[path typeKey:XCUIKeyboardKeyLeftArrow modifiers:0 atOffset:0.05];
    //[my->device runEventPath:path];
    //NSString *biNS = [NSString stringWithUTF8String:bi];
    my->app = [ [XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.mobilenotes"];
    
    [my->device cf_typeKey:my->app];
    
    return @"ok";
}

NSString *handleHasEventRecording( myData *my, node_hash *root ) {
    bool haveIt = [XCTRunnerDaemonSession.sharedSession supportsHIDEventRecording];
    if( haveIt ) return @"YES";
    return @"NO";
}

NSString *handleUpdateApplication( myData *my, node_hash *root ) {
    NSString *bi = node_hash__get_str_ns( root, "bundleId", 8 );
    my->app = [ [XCUIApplication alloc] initWithBundleIdentifier:bi];
    return @"ok";
}

NSString *handleSource( myData *my, node_hash *root ) {
    XCUIElement *el = nil;
    
    NSString *bi = node_hash__get_str_ns( root, "bi", 2 );
    if( bi ) {
        el = [ [XCUIApplication alloc] initWithBundleIdentifier:bi];
    } else {
        el = my->app;
    }
  
    int pid = node_hash__get_int( root, "pid", 3 );
    
    XCElementSnapshot *snapshot = nil;
    NSError *serror = nil;
    
    if( pid > 0 ) {
        el = (XCUIApplication *)[XCUIApplication appProcessWithPID:pid];
        //el = [XCTRunnerDaemonSession.sharedSession appWithPID:pid];
        snapshot = (XCElementSnapshot *) [el snapshotWithError:&serror];
    }
    else if( pid == -2 ) {
        snapshot = (XCElementSnapshot *) [my->systemApp.app snapshotWithError:&serror];
    }
    else {
        snapshot = (XCElementSnapshot *) [el snapshotWithError:&serror];
    }
    
    if( serror != nil ) NSLog( @"err:%@", serror );
    NSMutableString *str = nil;
    if( strlen( my->action ) > 6 ) {
        str = [snapshot asJson];
    } else {
        str = [snapshot asStringViaDict];
    }
    return str;
}

XCAccessibilityElement *requestElementAtPoint( CGPoint point ) {
    __block XCAccessibilityElement *el = nil;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    id <XCTMessagingChannel_RunnerToDaemon> proxy = [XCTRunnerDaemonSession sharedSession];
    [proxy _XCT_requestElementAtPoint:point
                           reply:
      ^(XCAccessibilityElement *el2, NSError *error) {
        if( nil == error ) el = el2;
        dispatch_semaphore_signal(sem);
      }
    ];
    dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)));
    return el;
}

XCElementSnapshot *snapshotForElement(
    XCAccessibilityElement *el,
    NSArray *atts,
    NSDictionary *params
) {
    NSError *err;
    XCAXClient_iOS *axClient = XCAXClient_iOS.sharedClient;
    XCElementSnapshot *snapshot = [axClient cf_elSnapshot:el
                                  attributes:atts
                                    maxDepth:@20
                                       error:&err];
    return snapshot;
}

NSString *handleElementAtPoint( myData *my, node_hash *root ) {
    int x = node_hash__get_int( root, "x", 1 );
    int y = node_hash__get_int( root, "y", 1 );
    int json = node_hash__get_int( root, "json", 4 );
    //int nopid = node_hash__get_int( root, "nopid", 5 );
    int top = node_hash__get_int( root, "top", 3 );

    CGPoint point = CGPointMake(x,y);
    XCAccessibilityElement *el = requestElementAtPoint( point );
    XCElementSnapshot *snap = snapshotForElement( el, nil, nil );
  
    if( top != -1 ) {
        while( snap.parent != nil ) snap = snap.parent;
        snap = snap.rootElement;
    }
    
    NSMutableString *str = nil;
  
    //if( nopid == -1 ) [str appendFormat:@"Pid:%ld", (long)el.processIdentifier];
    
    if( json != -1 ) str = [snap asJson];
    else             str = [snap asStringViaDict];

    return str;
}

NSString *handleElPos( myData *my, node_hash *root ) {
    NSString *elId = node_hash__get_str_ns( root, "id", 2 );
    
    XCUIElement *element = my->dict[elId];
    CGRect frame = [element frame];
    int x = (int) frame.origin.x;
    int y = (int) frame.origin.y;
    int width  = (int) frame.size.width;
    int height = (int) frame.size.height;
    return [NSString stringWithFormat:@"{x:%d,y:%d,w:%d,h:%d}", x, y, width, height];
}

NSString *handleNslog( myData *my, node_hash *root ) {
    NSString *msg = node_hash__get_str_ns( root, "msg", 3 );
    NSLog( @"%@", msg );
    return @"ok";
}

NSString *handleWindowSize( myData *my, node_hash *root ) {
    CGRect frame = CGRectIntegral( my->systemApp.app.frame );
    return [NSString stringWithFormat:@"{width:%d,height:%d}",
            (int)frame.size.width,
            (int)frame.size.height];
}

NSString *handleLaunchApp( myData *my, node_hash *root ) {
    NSString *bundleID = node_hash__get_str_ns( root, "bundleId", 8 );
    
    my->app = [ [XCUIApplication alloc] initWithBundleIdentifier:bundleID];
    //my->app.launchArguments = @[];
    //my->app.launchEnvironment = @{};
    [my->app launch];
    
    if( my->app.processID == 0 ) return @"NOK";
    return @"OK";
}

NSString *handleActiveApps( myData *my, node_hash *root ) {
    NSArray<XCAccessibilityElement *> *apps = [XCAXClient_iOS.sharedClient activeApplications];
    
    NSMutableString *ids = [[NSMutableString alloc] init];
    for( XCAccessibilityElement *app in apps ) {
        NSInteger pid = app.processIdentifier;
        [ids appendFormat:@"%ld,", (long)pid ];
    }
    return ids;
}

NSArray<NSString*> *FBStandardAttributeNames(void) {
    return [XCElementSnapshot sanitizedElementSnapshotHierarchyAttributesForAttributes:nil isMacOS:NO];
}

NSString *handleElByPid( myData *my, node_hash *root ) {
    int pid = node_hash__get_int( root, "pid", 3 );
    int json = node_hash__get_int( root, "json", 4 );
    XCAccessibilityElement *el = [XCAccessibilityElement elementWithProcessIdentifier:pid];
    
    NSArray *standardAttributes = FBStandardAttributeNames();
  
    XCElementSnapshot *snap = snapshotForElement( el, standardAttributes, nil );
    
    if( json != -1 ) return [snap asJson];
    else             return [snap asStringViaDict];
}

-(void) entry:(id)param {
    nng_rep_open(&_replySocket);
    
    char addr2[50];
    sprintf( addr2, "tcp://127.0.0.1:%d", _nngPort );
    nng_setopt_int( _replySocket, NNG_OPT_SENDBUF, 100000);
    int listen_error = nng_listen( _replySocket, addr2, NULL, 0);
    if( listen_error != 0 ) {
        NSLog( @"xxr error bindind on * : %d - %d", _nngPort, listen_error );
    }
    NSLog( @"NNG Ready on port %d", _nngPort );

    XCUIApplication *app = nil;
    
    SnapshotApplication *systemApp = [XCUIApplication systemSnapshotApp];
    
    XCUIDevice *device = XCUIDevice.sharedDevice;
    
    /*__block XCUIApplicationSpecifier *systemSpecifier;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [XCTRunnerDaemonSession.sharedSession requestApplicationSpecifierForPID:pid reply:^(XCUIApplicationSpecifier *specifier, NSError *err) {
            systemSpecifier = specifier;
            dispatch_semaphore_signal(sem);
        }
    ];
    dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)));
    systemApp = [[XCUIApplication alloc] initWithApplicationSpecifier:systemSpecifier device:device];*/
        
    //systemApp = [ [XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
    //systemApp = (XCUIApplication *)[systemApp firstMatch];
    
    //systemApp = [XCTRunnerDaemonSession.sharedSession appWithPID:pid];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:10];
      
    XCUIApplication *sbApp = [ [XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
    
    NSMutableDictionary *cmdFuncs = [[NSMutableDictionary alloc] initWithCapacity:10];
   
    #include "CommandList.h"
   
    myData data;
    data.device = device;
    data.dict = dict;
    data.app = app;
    data.systemApp = systemApp;
    data.sbApp = sbApp;
    data.nngServer = self;
    
    ujsonin_init();
    while( 1 ) {
        nng_msg *nmsg = NULL;
        nng_recvmsg( _replySocket, &nmsg, 0 );
        if( nmsg ) {
            NSString *respString = nil;
            node_hash *root = NULL;
            int msgLen = (int) nng_msg_len( nmsg );
            if( msgLen > 0 ) {
                char *msg = (char *) nng_msg_body( nmsg );
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
                
                if( !strncmp( action, "done", 4 ) ) break;
                
                NSString *actionNs = [[NSString alloc]
                                          initWithBytes:action
                                                 length:strlen(action)
                                               encoding:NSASCIIStringEncoding];
                
                NSValue *funcValue = cmdFuncs[actionNs];
                if( funcValue != nil ) {
                    void *funcPtr = [funcValue pointerValue];
                    NSString * (*func)(myData *, node_hash *root) =
                              ( NSString * (*)(myData *, node_hash *root) ) funcPtr;
                    data.action = action;
                    respString = func( &data, root );
                } else {
                    NSLog( @"unhandled acton %@", actionNs );
                }
            }
            else NSLog(@"xxr empty message");
            if( root ) node_hash__delete( root );
            nng_msg_free( nmsg );
            
            nng_msg *respN;
            nng_msg_alloc(&respN, 0);
            
            if( respString != nil ) {
                unsigned long length = [respString length];
                nng_msg_append( respN, [respString UTF8String], length );
                NSLog( @"sending back:%@", respString );
            } else {
                nng_msg_append( respN, "ok", 2 );
            }
            
            int sendErr = nng_sendmsg( _replySocket, respN, 0 );
            if( sendErr ) {
                NSLog( @"sending err :%d", sendErr );
                nng_msg_free( respN );
            }
        }
    }
    
    nng_close( _replySocket );
}

@end
