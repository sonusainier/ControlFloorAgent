#import "XCElementSnapshot+Helpers.h"
#import "XCElementSnapshot-TreeManagement.h"
#import "CFA.h"

// Common attributes of element snapshot items: horizontalSizeClass,enabled,elementType,frame,title,verticalSizeClass,identifier,label,hasFocus,selected,children

void snapToJson( XCElementSnapshot *el, NSMutableString *str, int depth ) {
    NSString *spaces   = [@"" stringByPaddingToLength:depth withString:@"  " startingAtIndex:0];
    long elementType   = el.elementType;
    NSString *ident    = el.identifier;
    NSString *typeStr  = [CFA typeStr:elementType];
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
        snapToJson( (XCElementSnapshot *)child, str, depth+2 );
        if( i != ( cCount -1 ) ) [str appendFormat:@",\n" ];
    }

    if( cCount ) [str appendFormat:@"%@]}\n", spaces ];
}

void dictToStr( NSDictionary *dict, NSMutableString *str, int depth ) {
    NSString *spaces     = [@"" stringByPaddingToLength:depth withString:@"  " startingAtIndex:0];
    long elementType     = [dict[@"elementType"] integerValue];
    NSString *ident      = dict[@"identifier"];
    NSArray *children    = dict[@"children"];
    unsigned long cCount = [children count];
    
    NSString *typeStr    = [CFA typeStr:elementType];
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
        dictToStr( (NSDictionary *)child, str, depth+2 );
    }
  
    if( cCount ) [str appendFormat:@"%@</el>\n", spaces ];
}

/*void dictToJson( myData *my, NSDictionary *dict, NSMutableString *str, int depth ) {
    NSString *spaces     = [@"" stringByPaddingToLength:depth withString:@"  " startingAtIndex:0];
    long elementType     = [dict[@"elementType"] integerValue];
    NSString *ident      = dict[@"identifier"];
    NSArray *children    = dict[@"children"];
    unsigned long cCount = [children count];
    
    NSString *typeStr    = [CFA typeStr:elementType];
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
}*/

@implementation SnapFindElResult
@end

SnapFindElResult *findElRecurse( XCElementSnapshot *el, NSString *ident, NSArray *types ) {
    if( types == nil || [types containsObject:@(el.elementType)] ) {
        if( [ident isEqual:el.identifier] || [ident isEqual:el.label]  ) {
            SnapFindElResult *res = [[SnapFindElResult alloc] init];
            res.x = el.centerX;
            res.y = el.centerY;
            res.el = el;
            return res;
        }
    }
    
    NSArray *children = el.children;
    unsigned long cCount = [children count];
    for( unsigned long i = 0; i < cCount; i++) {
        XCElementSnapshot *child = [children objectAtIndex:i];
        SnapFindElResult *found = findElRecurse( child, ident, types );
        if( found ) return found;
    }
    return nil;
}

@implementation XCElementSnapshot (Helpers)

- (NSMutableString *) asJson {
    NSMutableString *str = [NSMutableString stringWithString:@""];
    snapToJson( self, str, 0 );
    return str;
}

- (NSMutableString *) asStringViaDict {
    NSDictionary *sdict = [self dictionaryRepresentation];
    NSMutableString *str = [NSMutableString stringWithString:@""];
    dictToStr( sdict, str, 0 );
    return str;
}

- (SnapFindElResult *) findEl:(NSString *)ident withType:(NSArray *)types {
    return findElRecurse( self, ident, types );
}

@end
