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

@implementation NetworkIface
@end

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

struct myData_s {
    XCUIDevice *device;
    NSMutableDictionary *dict;
    XCUIApplication *app;
    XCUIApplication *systemApp;
    NSDictionary *types;
    char *action;
    NSArray *typeMap;
    XCUIApplication *sbApp;
    NngThread *nngServer;
};
typedef struct myData_s myData;

// Common attributes of element snapshot items: horizontalSizeClass,enabled,elementType,frame,title,verticalSizeClass,identifier,label,hasFocus,selected,children

void dictToStr( myData *my, NSDictionary *dict, NSMutableString *str, int depth ) {
    NSString *spaces     = [@"" stringByPaddingToLength:depth withString:@"  " startingAtIndex:0];
    long elementType     = [dict[@"elementType"] integerValue];
    NSString *ident      = dict[@"identifier"];
    NSArray *children    = dict[@"children"];
    unsigned long cCount = [children count];
    
    NSString *typeStr    = my->typeMap[ elementType ];
    [str appendFormat:@"%@<el type=\"%@\"", spaces, typeStr ];
    if( [ident length] != 0 ) [str appendFormat:@" id=\"%@\"", ident ];
  
    NSString *label = dict[@"label"];
    if( [label length] ) [str appendFormat:@" label=\"%@\"", label];
  
    NSString *title = dict[@"title"];
    if( [title length] ) [str appendFormat:@" title=\"%@\"", title];
  
    NSDictionary *rect = [dict objectForKey:@"frame"];
    [str appendFormat:@" x=%.0f y=%.0f w=%.0f h=%.0f",
       [rect[@"X"]     floatValue], [rect[@"Y"]      floatValue],
       [rect[@"Width"] floatValue], [rect[@"Height"] floatValue]];
   
    if( !cCount ) [str appendFormat:@"/>\n" ];
    else [str appendFormat:@">\n" ];
    
    for( unsigned long i = 0; i < [children count]; i++) {
        NSObject *child = [children objectAtIndex:i];
        dictToStr( my, (NSDictionary *)child, str, depth+2 );
    }
  
    if( cCount ) [str appendFormat:@"%@</el>\n", spaces ];
}

void snapToJson( myData *my, XCElementSnapshot *el, NSMutableString *str, int depth, XCUIApplication *app ) {
    NSString *spaces   = [@"" stringByPaddingToLength:depth withString:@"  " startingAtIndex:0];
    long elementType   = el.elementType;
    NSString *ident    = el.identifier;
    NSString *typeStr  = my->typeMap[ elementType ];
    NSDictionary *atts = el.additionalAttributes;
    
    if( [typeStr isEqualToString:@"Other"] && [atts objectForKey:@5004] ) {
        typeStr = [atts objectForKey:@5004];
    }
  
    [str appendFormat:@"%@{ \"type\":\"%@\",", spaces, typeStr ];
    if( [ident length] != 0 ) [str appendFormat:@" \"id\":\"%@\",", ident ];

    NSString *label = el.label;
    if( [label length] ) {
      if( [label containsString:@"\""] ) {
        label = [label stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
      }
      [str appendFormat:@" \"label\":\"%@\",", label];
    }
    
    NSArray *children = el.children;
    unsigned long cCount = [children count];

    NSString *title = el.title;
    if( [title length] ) [str appendFormat:@" \"title\":\"%@\",", title];

    CGRect rect = el.frame;
    [str appendFormat:@" \"x\":%.0f, \"y\":%.0f, \"w\":%.0f, \"h\":%.0f",
      rect.origin.x, rect.origin.y,
      rect.size.width, rect.size.height];
   
    if( !cCount ) [str appendFormat:@"}\n" ];
    else          [str appendFormat:@",\"c\":[\n" ];
    
    for( unsigned long i = 0; i < cCount; i++) {
        NSObject *child = [children objectAtIndex:i];
        snapToJson( my, (XCElementSnapshot *)child, str, depth+2, app );
        if( i != ( cCount -1 ) ) [str appendFormat:@",\n" ];
    }

    if( cCount ) [str appendFormat:@"%@]}\n", spaces ];
}

void dictToJson( myData *my, NSDictionary *dict, NSMutableString *str, int depth ) {
    NSString *spaces     = [@"" stringByPaddingToLength:depth withString:@"  " startingAtIndex:0];
    long elementType     = [dict[@"elementType"] integerValue];
    NSString *ident      = dict[@"identifier"];
    NSArray *children    = dict[@"children"];
    unsigned long cCount = [children count];
    
    NSString *typeStr    = my->typeMap[ elementType ];
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
    else          [str appendFormat:@",\"c\":[\n" ];
    
    for( unsigned long i = 0; i < cCount; i++) {
        NSObject *child = [children objectAtIndex:i];
        dictToJson( my, (NSDictionary *)child, str, depth+2 );
        if( i != ( cCount -1 ) ) [str appendFormat:@",\n" ];
    }
  
    if( cCount ) [str appendFormat:@"%@]}\n", spaces ];
}

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
    char *name = node_hash__get_str( root, "name", 4 );
    NSString *name2 = [NSString stringWithUTF8String:name];
    
    static NSMutableDictionary *nameMap = nil;
    static dispatch_once_t once;
    dispatch_once( &once, ^{
      nameMap = [[NSMutableDictionary alloc] initWithCapacity:3];
      [nameMap setObject:[NSNumber numberWithInt:XCUIDeviceButtonHome] forKey:@"home"];
      [nameMap setObject:[NSNumber numberWithInt:XCUIDeviceButtonVolumeUp] forKey:@"volumeup"];
      [nameMap setObject:[NSNumber numberWithInt:XCUIDeviceButtonVolumeDown] forKey:@"volumedown"];
    } );
        
    NSNumber *num = [nameMap valueForKey:name2];
    [my->device pressButton:[num integerValue]];
    free( name );
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
    NSError *error;
    
    [my->device cf_iohid:page
                   usage:usage
                duration:duration
                   error:&error];
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
    char *elId = node_hash__get_str( root, "id", 2 );
    NSString *id2 = [NSString stringWithUTF8String:elId];
  
    XCUIElement *element = my->dict[id2];
    [my->dict removeObjectForKey:id2];
    //NSError *error = nil;
    if( element == nil ) {
        // todo error
    } else {
        //if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")) {
            [element tap];
        /*} else {
            XCElementSnapshot *snapshot = (XCElementSnapshot *) [element snapshotWithError:&error];
            int x = snapshot.frame.origin.x/2;
            int y = snapshot.frame.origin.y/2;
            NSLog( @"tapping a %d,%d", x+1, y+1 );
            [device cf_tap:x/2 y:y/2];
        }*/
        //[element fb_tapWithError:&error];
    }
    return @"ok";
}

NSString *handleElTouchAndHold( myData *my, node_hash *root ) {
    char *elId = node_hash__get_str( root, "id", 2 );
    NSString *id2 = [NSString stringWithUTF8String:elId];
  
    XCUIElement *element = my->dict[id2];
    [my->dict removeObjectForKey:id2];
    double forTime = node_hash__get_double( root, "time", 4 );
    [element pressForDuration:forTime];
    return @"ok";
}

NSString *handleElForceTouch( myData *my, node_hash *root ) {
    char *elId = node_hash__get_str( root, "id", 2 );
    NSString *id2 = [NSString stringWithUTF8String:elId];
  
    XCUIElement *element = my->dict[id2];
    [my->dict removeObjectForKey:id2];
    
    //double forTime = node_hash__get_double( root, "time", 4 );
    double pressure = node_hash__get_double( root, "pressure", 8 );
    if( pressure < 0 ) pressure = -pressure; // bug
    //[element pressForDuration:forTime];
    //NSError *err;
    //[element fb_forceTouchWithPressure:pressure duration:forTime error:&err];
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

NSString *handleGetEl( myData *my, node_hash *root ) {
    char *name = node_hash__get_str( root, "id", 2 );
    NSString *name2 = [NSString stringWithUTF8String:name];
    
    char *type = node_hash__get_str( root, "type", 4 );
    int typeNum = 0;
    if( type ) {
        NSString *type2 = [NSString stringWithUTF8String:type];
        id typeNumNS = my->types[ type2 ];
        if( typeNumNS ) typeNum = [typeNumNS intValue];
    }
    
    double wait = node_hash__get_double( root, "wait", 4 );
  
    XCUIElement *el = nil;
    
    if( node_hash__get( root, "system", 6 ) ) {
        XCUIElementQuery *query = [my->systemApp descendantsMatchingType:typeNum];
        el = [query elementMatchingType:typeNum identifier:name2];
    }
    else {
        XCUIElementQuery *query = [my->app descendantsMatchingType:typeNum];
        el = [query elementMatchingType:typeNum identifier:name2];
    }
  
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
    NSInteger orientation = my->systemApp.interfaceOrientation;
    
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
    char *orientation = node_hash__get_str( root, "orientation", 11 );
    if( !orientation ) return @"Must pass orientation";
    NSString *o = [NSString stringWithUTF8String:orientation];
     
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
    XCUIElementQuery *query = [my->app descendantsMatchingType:XCUIElementTypeAlert];
    XCUIElement *el = [query element];
    if( el == nil || !el.exists ) return @"{present:false}";
    
    NSString *res = @"{\n  present:true\n  buttons:[\n";
    
    NSArray<XCUIElement *> *buttons =
        [el descendantsMatchingType:XCUIElementTypeButton].allElementsBoundByIndex;
    
    for( unsigned long i = 0; i < [buttons count]; i++) {
        XCUIElement *button = [buttons objectAtIndex:i];
        res = [res stringByAppendingFormat:@"    \"%@\"\n", button.value ?: button.label ];
    }
    
    NSPredicate *alertDescrPredicate = [NSPredicate predicateWithFormat:@"elementType IN {%lu,%lu}",
        XCUIElementTypeTextView, XCUIElementTypeStaticText];
    NSArray<XCUIElement *> *descriptions = [
        [el descendantsMatchingType:XCUIElementTypeAny]
        matchingPredicate:alertDescrPredicate
    ].allElementsBoundByIndex;
    NSString *alertText = nil;
    for( unsigned long i = 0; i < [descriptions count]; i++) {
        XCUIElement *descr = [descriptions objectAtIndex:i];
        NSString *label = descr.value;
        if( label == nil ) {
            if(descr.elementType == XCUIElementTypeStaticText) label = descr.label;
            if(descr.elementType == XCUIElementTypeTextView  ) label = descr.placeholderValue;
        }
        
        res = [res stringByAppendingFormat:@"    \"%@\"\n", label ];
    }
    
    return [res stringByAppendingFormat:@"]\n  alert:\"%@\"\n]\n}", alertText];
}

/*NSString *handleIsLocked( myData *my, node_hash *root ) {
    bool locked = my->device.fb_isScreenLocked;
    return locked ? @"{\"locked\":true}" : @"{\"locked\":false}";
}

NSString *handleLock( myData *my, node_hash *root ) {
    NSError *error;
    bool success = [my->device fb_lockScreen:&error];
    return success ? @"{\"success\":true}" : @"{\"success\":false}";
}

NSString *handleUnlock( myData *my, node_hash *root ) {
    NSError *error;
    bool success = [my->device fb_unlockScreen:&error];
    return success ? @"{\"success\":true}" : @"{\"success\":false}";
}*/

NSString *handleSiri( myData *my, node_hash *root ) {
    char *text = node_hash__get_str( root, "text", 4 );
    NSString *text2 = [NSString stringWithUTF8String:text];
    [my->device.siriService activateWithVoiceRecognitionText:text2];
    return @"ok";
}

NSString *handleTypeText( myData *my, node_hash *root ) {
    char *text = node_hash__get_str_escapes( root, "text", 4 );
    NSString *text2 = [NSString stringWithUTF8String:text];
    [my->app typeText: text2];
    return @"ok";
}

NSString *handleUpdateApplication( myData *my, node_hash *root ) {
    char *bi = node_hash__get_str( root, "bundleId", 8 );
    NSString *biNS = [NSString stringWithUTF8String:bi];
    my->app = [ [XCUIApplication alloc] initWithBundleIdentifier:biNS];
    return @"ok";
}

NSString *handleSource( myData *my, node_hash *root ) {
    XCUIElement *el = nil;
    
    char *bi = node_hash__get_str( root, "bi", 2 );
    if( bi ) {
        NSString *bi2 = [NSString stringWithUTF8String:bi];
        el = [ [XCUIApplication alloc] initWithBundleIdentifier:bi2];
    } else {
        el = my->app;
    }
  
    int pid = node_hash__get_int( root, "pid", 3 );
    if( pid != -1 ) {
        el = (XCUIApplication *)[XCUIApplication appProcessWithPID:pid];
        //el = [XCTRunnerDaemonSession.sharedSession appWithPID:pid];
    }
    
    NSError *serror = nil;
    XCElementSnapshot *snapshot = (XCElementSnapshot *) [el snapshotWithError:&serror];
    if( serror != nil ) NSLog( @"err:%@", serror );
    NSDictionary *sdict = [snapshot dictionaryRepresentation];
    NSMutableString *str = [NSMutableString stringWithString:@""];
    if( strlen( my->action ) > 6 ) {
        dictToJson( my, sdict, str, 0 );
    } else {
        dictToStr( my, sdict, str, 0 );
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

XCElementSnapshot *snapshotForElement( XCAccessibilityElement *el,
                                  NSArray *atts,
                                  NSDictionary *params )
{
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
    int nopid = node_hash__get_int( root, "nopid", 5 );
    int top = node_hash__get_int( root, "top", 3 );

    CGPoint point = CGPointMake(x,y);
    XCAccessibilityElement *el = requestElementAtPoint( point );
    XCElementSnapshot *snap = snapshotForElement( el, nil, nil );
  
    if( top != -1 ) {
        while( snap.parent != nil ) snap = snap.parent;
        snap = snap.rootElement;
    }
    
    NSMutableString *str = [NSMutableString stringWithString:@""];
  
  if( nopid == -1 ) [str appendFormat:@"Pid:%ld", (long)el.processIdentifier];
    
    if( json != -1 ) {
        snapToJson( my, snap, str, 0, my->app );
    } else {
        NSDictionary *sdict = [snap dictionaryRepresentation];
        dictToStr( my, sdict, str, 0 );
    }
    return str;
}

NSString *handleElPos( myData *my, node_hash *root ) {
    char *elId = node_hash__get_str( root, "id", 2 );
    NSString *id2 = [NSString stringWithUTF8String:elId];
  
    XCUIElement *element = my->dict[id2];
    CGRect frame = [element frame];
    int x = (int) frame.origin.x;
    int y = (int) frame.origin.y;
    int width  = (int) frame.size.width;
    int height = (int) frame.size.height;
    return [NSString stringWithFormat:@"{x:%d,y:%d,w:%d,h:%d}", x, y, width, height];
}

NSString *handleNslog( myData *my, node_hash *root ) {
    char *msg = node_hash__get_str( root, "msg", 3 );
    NSString *msg2 = [NSString stringWithUTF8String:msg];
    NSLog( @"%@", msg2 );
    return @"ok";
}

NSString *handleWindowSize( myData *my, node_hash *root ) {
    CGRect frame = CGRectIntegral( my->systemApp.frame );
    return [NSString stringWithFormat:@"{width:%d,height:%d}",
            (int)frame.size.width,
            (int)frame.size.height];
}

NSString *handleLaunchApp( myData *my, node_hash *root ) {
    char *bundleID = node_hash__get_str( root, "bundleId", 8 );
    
    NSInteger pid = [[XCAXClient_iOS.sharedClient systemApplication] processIdentifier];
    my->systemApp = (XCUIApplication *)[XCUIApplication appProcessWithPID:pid];
    //my->systemApp = [XCTRunnerDaemonSession.sharedSession appWithPID:pid];

    NSString *biNS = [NSString stringWithUTF8String:bundleID];
    my->app = [ [XCUIApplication alloc] initWithBundleIdentifier:biNS];
    //my->app.launchArguments = @[];
    //my->app.launchEnvironment = @{};
    [my->app launch];
    
    if( my->app.processID == 0 ) return @"NOK";
    return @"OK";
}

NSString *handleActiveApps( myData *my, node_hash *root ) {
    NSArray<XCAccessibilityElement *> *apps = [XCAXClient_iOS.sharedClient activeApplications];
    
    NSMutableString *ids = [[NSMutableString alloc] init];
    for( unsigned long i=0;i<[apps count];i++ ) {
        XCAccessibilityElement *app = [apps objectAtIndex:i];
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
    
    NSMutableString *str = [NSMutableString stringWithString:@""];
    
    if( json != -1 ) {
        snapToJson( my, snap, str, 0, my->app );
    } else {
        NSDictionary *sdict = [snap dictionaryRepresentation];
        
        dictToStr( my, sdict, str, 0 );
    }
    return str;
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

    NSDictionary *types = [[NSDictionary alloc] initWithObjectsAndKeys:
                             [NSNumber numberWithInt:XCUIElementTypeActivityIndicator],@"activityIndicator",
                             [NSNumber numberWithInt:XCUIElementTypeAlert],@"alert",
                             [NSNumber numberWithInt:XCUIElementTypeAny],@"any",
                             [NSNumber numberWithInt:XCUIElementTypeApplication],@"application",
                             [NSNumber numberWithInt:XCUIElementTypeBrowser],@"browser",
                             [NSNumber numberWithInt:XCUIElementTypeButton],@"button",
                             [NSNumber numberWithInt:XCUIElementTypeCell],@"cell",
                             [NSNumber numberWithInt:XCUIElementTypeCheckBox],@"checkBox",
                             [NSNumber numberWithInt:XCUIElementTypeCollectionView],@"collectionView",
                             [NSNumber numberWithInt:XCUIElementTypeColorWell],@"colorWell",
                             [NSNumber numberWithInt:XCUIElementTypeComboBox],@"comboBox",
                             [NSNumber numberWithInt:XCUIElementTypeDatePicker],@"datePicker",
                             [NSNumber numberWithInt:XCUIElementTypeDecrementArrow],@"decrementArrow",
                             [NSNumber numberWithInt:XCUIElementTypeDialog],@"dialog",
                             [NSNumber numberWithInt:XCUIElementTypeDisclosureTriangle],@"disclosureTriangle",
                             [NSNumber numberWithInt:XCUIElementTypeDockItem],@"dockItem",
                             [NSNumber numberWithInt:XCUIElementTypeDrawer],@"drawer",
                             [NSNumber numberWithInt:XCUIElementTypeGrid],@"grid",
                             [NSNumber numberWithInt:XCUIElementTypeGroup],@"group",
                             [NSNumber numberWithInt:XCUIElementTypeHandle],@"handle",
                             [NSNumber numberWithInt:XCUIElementTypeHelpTag],@"helpTag",
                             [NSNumber numberWithInt:XCUIElementTypeIcon],@"icon",
                             [NSNumber numberWithInt:XCUIElementTypeImage],@"image",
                             [NSNumber numberWithInt:XCUIElementTypeIncrementArrow],@"incrementArrow",
                             [NSNumber numberWithInt:XCUIElementTypeKey],@"key",
                             [NSNumber numberWithInt:XCUIElementTypeKeyboard],@"keyboard",
                             [NSNumber numberWithInt:XCUIElementTypeLayoutArea],@"layoutArea",
                             [NSNumber numberWithInt:XCUIElementTypeLayoutItem],@"layoutItem",
                             [NSNumber numberWithInt:XCUIElementTypeLevelIndicator],@"levelIndicator",
                             [NSNumber numberWithInt:XCUIElementTypeLink],@"link",
                             [NSNumber numberWithInt:XCUIElementTypeMap],@"map",
                             [NSNumber numberWithInt:XCUIElementTypeMatte],@"matte",
                             [NSNumber numberWithInt:XCUIElementTypeMenu],@"menu",
                             [NSNumber numberWithInt:XCUIElementTypeMenuBar],@"menuBar",
                             [NSNumber numberWithInt:XCUIElementTypeMenuBarItem],@"menuBarItem",
                             [NSNumber numberWithInt:XCUIElementTypeMenuButton],@"menuButton",
                             [NSNumber numberWithInt:XCUIElementTypeMenuItem],@"menuItem",
                             [NSNumber numberWithInt:XCUIElementTypeNavigationBar],@"navigationBar",
                             [NSNumber numberWithInt:XCUIElementTypeOther],@"other",
                             [NSNumber numberWithInt:XCUIElementTypeOutline],@"outline",
                             [NSNumber numberWithInt:XCUIElementTypeOutlineRow],@"outlineRow",
                             [NSNumber numberWithInt:XCUIElementTypePageIndicator],@"pageIndicator",
                             [NSNumber numberWithInt:XCUIElementTypePicker],@"picker",
                             [NSNumber numberWithInt:XCUIElementTypePickerWheel],@"pickerWheel",
                             [NSNumber numberWithInt:XCUIElementTypePopUpButton],@"popUpButton",
                             [NSNumber numberWithInt:XCUIElementTypePopover],@"popover",
                             [NSNumber numberWithInt:XCUIElementTypeProgressIndicator],@"progressIndicator",
                             [NSNumber numberWithInt:XCUIElementTypeRadioButton],@"radioButton",
                             [NSNumber numberWithInt:XCUIElementTypeRadioGroup],@"radioGroup",
                             [NSNumber numberWithInt:XCUIElementTypeRatingIndicator],@"ratingIndicator",
                             [NSNumber numberWithInt:XCUIElementTypeRelevanceIndicator],@"relevanceIndicator",
                             [NSNumber numberWithInt:XCUIElementTypeRuler],@"ruler",
                             [NSNumber numberWithInt:XCUIElementTypeRulerMarker],@"rulerMarker",
                             [NSNumber numberWithInt:XCUIElementTypeScrollBar],@"scrollBar",
                             [NSNumber numberWithInt:XCUIElementTypeScrollView],@"scrollView",
                             [NSNumber numberWithInt:XCUIElementTypeSearchField],@"searchField",
                             [NSNumber numberWithInt:XCUIElementTypeSecureTextField],@"secureTextField",
                             [NSNumber numberWithInt:XCUIElementTypeSegmentedControl],@"segmentedControl",
                             [NSNumber numberWithInt:XCUIElementTypeSheet],@"sheet",
                             [NSNumber numberWithInt:XCUIElementTypeSlider],@"slider",
                             [NSNumber numberWithInt:XCUIElementTypeSplitGroup],@"splitGroup",
                             [NSNumber numberWithInt:XCUIElementTypeSplitter],@"splitter",
                             [NSNumber numberWithInt:XCUIElementTypeStaticText],@"staticText",
                             [NSNumber numberWithInt:XCUIElementTypeStatusBar],@"statusBar",
                             [NSNumber numberWithInt:XCUIElementTypeStatusItem],@"statusItem",
                             [NSNumber numberWithInt:XCUIElementTypeStepper],@"stepper",
                             [NSNumber numberWithInt:XCUIElementTypeSwitch],@"switch",
                             [NSNumber numberWithInt:XCUIElementTypeTab],@"tab",
                             [NSNumber numberWithInt:XCUIElementTypeTabBar],@"tabBar",
                             [NSNumber numberWithInt:XCUIElementTypeTabGroup],@"tabGroup",
                             [NSNumber numberWithInt:XCUIElementTypeTable],@"table",
                             [NSNumber numberWithInt:XCUIElementTypeTableColumn],@"tableColumn",
                             [NSNumber numberWithInt:XCUIElementTypeTableRow],@"tableRow",
                             [NSNumber numberWithInt:XCUIElementTypeTextField],@"textField",
                             [NSNumber numberWithInt:XCUIElementTypeTextView],@"textView",
                             [NSNumber numberWithInt:XCUIElementTypeTimeline],@"timeline",
                             [NSNumber numberWithInt:XCUIElementTypeToggle],@"toggle",
                             [NSNumber numberWithInt:XCUIElementTypeToolbar],@"toolbar",
                             [NSNumber numberWithInt:XCUIElementTypeToolbarButton],@"toolbarButton",
                             [NSNumber numberWithInt:XCUIElementTypeValueIndicator],@"valueIndicator",
                             [NSNumber numberWithInt:XCUIElementTypeWebView],@"webView",
                             [NSNumber numberWithInt:XCUIElementTypeWindow],@"window",
                             [NSNumber numberWithInt:XCUIElementTypeTouchBar],@"touchBar",
                           nil
    ];
  
    XCUIApplication *app = nil;
    
    XCUIApplication *systemApp = nil;
    NSInteger pid = [[XCAXClient_iOS.sharedClient systemApplication] processIdentifier];
    systemApp = (XCUIApplication *)[XCUIApplication appProcessWithPID:pid];
    //systemApp = [XCTRunnerDaemonSession.sharedSession appWithPID:pid];
        
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:10];
    XCUIDevice *device = XCUIDevice.sharedDevice;
  
    XCUIApplication *sbApp = [ [XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
    
    NSMutableDictionary *cmdFuncs = [[NSMutableDictionary alloc] initWithCapacity:10];
   
    #define CHANDLE(name,name2) cmdFuncs[@#name] = [NSValue valueWithPointer:(const void * _Nullable)&handle ## name2 ];
    CHANDLE(activeApps,ActiveApps);
    CHANDLE(alertInfo,AlertInfo);
    CHANDLE(button,Button);
    CHANDLE(launchApp,LaunchApp);
    //CHANDLE(elByName,ElByName);
    //CHANDLE(elByPid,ElByPid);
    CHANDLE(elClick,ElClick);
    CHANDLE(elForceTouch,ElForceTouch);
    CHANDLE(elPos,ElPos);
    CHANDLE(elTouchAndHold,ElTouchAndHold);
    //CHANDLE(elementAtPoint,ElementAtPoint);
    CHANDLE(getEl,GetEl);
    CHANDLE(getOrientation,GetOrientation);
    CHANDLE(setOrientation,SetOrientation);
    CHANDLE(homeBtn,HomeBtn);
    CHANDLE(iohid,Iohid);
    //CHANDLE(isLocked,IsLocked);
    //CHANDLE(lock,Lock);
    CHANDLE(mouseDown,MouseDown);
    CHANDLE(mouseUp,MouseUp);
    CHANDLE(nslog,Nslog);
    CHANDLE(ping,Ping);
    CHANDLE(siri,Siri);
    CHANDLE(source,Source);
    CHANDLE(sourceJson,Source);
    CHANDLE(startBroadcastApp,StartBroadcastApp);
    CHANDLE(swipe,Swipe);
    CHANDLE(tap,Tap);
    CHANDLE(doubletap,Doubletap);
    CHANDLE(tapFirm,TapFirm);
    CHANDLE(tapTime,TapTime);
    CHANDLE(toLauncher,ToLauncher);
    CHANDLE(typeText,TypeText);
    //CHANDLE(unlock,Unlock);
    CHANDLE(updateApplication,UpdateApplication);
    CHANDLE(wifiIp,WifiIp);
    CHANDLE(restart,StartLTStream);
    CHANDLE(launchsafariurl,OpenSafari);
    CHANDLE(cleanbrowser,CleanBrowser);
    CHANDLE(windowSize,WindowSize);
   
    myData data;
    data.device = device;
    data.dict = dict;
    data.app = app;
    data.systemApp = systemApp;
    data.typeMap = _typeMap;
    data.sbApp = sbApp;
    data.types = types;
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
