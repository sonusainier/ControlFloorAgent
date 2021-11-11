//  Copyright © 2021 DryArk LLC. All rights reserved.
//  Anti-Corruption License ( AC_LICENSE.TXT )

#import "NNGServer.h"
#import "XCElementSnapshot-XCUIElementSnapshot.h"
#import "FBConfiguration.h"
#import "FBLogger.h"
#import "FBAlert.h"
#import "XCUIDevice+FBHelpers.h"
#import "XCUIDevice+CFHelpers.h"
#import "XCPointerEventPath.h"
#import "XCSynthesizedEventRecord.h"
#import "FBApplication.h"
#import "XCUIElement+FBFind.h"
#import "FBElementCache.h"
#import "XCUIElement+FBTap.h"
#import "XCUIElement+FBForceTouch.h"
#import "XCUIElement+FBUID.h"
#import "XCUIApplication+FBQuiescence.h"
#import "XCUIApplication+FBHelpers.h"
#import "XCUIDevice+FBHelpers.h"
#import "XCUIApplication+FBTouchAction.h"
#import "FBXCAXClientProxy.h"
#import <objc/runtime.h>
#import "XCTestPrivateSymbols.h"
#import "FBXCodeCompatibility.h"
#import "XCUIElementQuery.h"

//#import <AXRuntime/AXUIElement.h>

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

-(void) snapToJson:(XCElementSnapshot *)el
               str:(NSMutableString *)str
             depth:(int)depth
               app:(XCUIApplication *)app {
    NSString *spaces = [@"" stringByPaddingToLength:depth withString:@"  " startingAtIndex:0];
    //horizontalSizeClass,enabled,elementType,frame,title,verticalSizeClass,identifier,label,hasFocus,selected,children
    long elementType = el.elementType;
    NSString *ident = el.identifier;
    
    NSString *typeStr = _typeMap[ elementType ];
    
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
    
    /*if( [label isEqualToString:@"AssistiveTouch menu"]) {
        XCAccessibilityElement *accEl = el.accessibilityElement;
        accEl = [XCAccessibilityElement elementWithAXUIElement:accEl.AXUIElement];
        NSArray *standardAttributes = FBStandardAttributeNames();
        el = [app cf_snapshotForElement:accEl
                             attributes:standardAttributes
                             parameters:nil];
    }*/
    
    /*if( atts[@"UIView"] ) {
        UIView *uiview = atts[@"UIView"];
        int count = 0;
        for ( UIView *subview in uiview.subviews ) {
            count++;
        }
      
    }*/
    
    NSArray *children = el.children;
    unsigned long cCount = [children count];

    NSString *title = el.title;
    if( [title length] ) [str appendFormat:@" \"title\":\"%@\",", title];

    CGRect rect = el.frame;
    [str
     appendFormat:@" \"x\":%.0f, \"y\":%.0f, \"w\":%.0f, \"h\":%.0f",
     rect.origin.x, rect.origin.y,
     rect.size.width, rect.size.height];
   
    if( !cCount ) [str appendFormat:@"}\n" ];
    else [str appendFormat:@",\"c\":[\n" ];
    
    for( unsigned long i = 0; i < cCount; i++) {
        NSObject *child = [children objectAtIndex:i];
        //const char *className = class_getName( [child class] );
        //[str appendFormat:@"  i:%d className:%s\n",i,className ];
        [self snapToJson:(XCElementSnapshot *)child str:str depth:(depth+2) app:app];
        if( i != ( cCount -1 ) ) [str appendFormat:@",\n" ];
    }

    if( cCount ) [str appendFormat:@"%@]}\n", spaces ];
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

NSString *createKey(void);
NSString *createKey(void) {
    NSString *keyCharSet = @"abcdefghijklmnopqrstuvwxyz0123456789";
    int setLength = (int) [keyCharSet length];
  
    NSMutableString *key = [NSMutableString stringWithCapacity: 5];
    for( int i=0; i<5; i++ ) {
        [key appendFormat: @"%C",
            [keyCharSet characterAtIndex: arc4random_uniform(setLength)]];
    }
    return key;
}

/*XCUIElementQuery *appElsActivityIndicator( XCUIApplication *app ) { return app.activityIndicators; }
XCUIElementQuery *appElsAlert( XCUIApplication *app ) { return app.alerts; }
//XCUIElementQuery *appElsAny( XCUIApplication *app ) { return app.anys; }
//XCUIElementQuery *appElsApplication( XCUIApplication *app ) { return app.applications; }
XCUIElementQuery *appElsBrowser( XCUIApplication *app ) { return app.browsers; }
XCUIElementQuery *appElsButton( XCUIApplication *app ) { return app.buttons; }
XCUIElementQuery *appElsCell( XCUIApplication *app ) { return app.cells; }
XCUIElementQuery *appElsCheckBox( XCUIApplication *app ) { return app.checkBoxes; }
XCUIElementQuery *appElsCollectionView( XCUIApplication *app ) { return app.collectionViews; }
XCUIElementQuery *appElsColorWell( XCUIApplication *app ) { return app.colorWells; }
XCUIElementQuery *appElsComboBox( XCUIApplication *app ) { return app.comboBoxes; }
XCUIElementQuery *appElsDatePicker( XCUIApplication *app ) { return app.datePickers; }
XCUIElementQuery *appElsDecrementArrow( XCUIApplication *app ) { return app.decrementArrows; }
XCUIElementQuery *appElsDialog( XCUIApplication *app ) { return app.dialogs; }
XCUIElementQuery *appElsDisclosureTriangle( XCUIApplication *app ) { return app.disclosureTriangles; }
XCUIElementQuery *appElsDockItem( XCUIApplication *app ) { return app.dockItems; }
XCUIElementQuery *appElsDrawer( XCUIApplication *app ) { return app.drawers; }
XCUIElementQuery *appElsGrid( XCUIApplication *app ) { return app.grids; }
XCUIElementQuery *appElsGroup( XCUIApplication *app ) { return app.groups; }
XCUIElementQuery *appElsHandle( XCUIApplication *app ) { return app.handles; }
XCUIElementQuery *appElsHelpTag( XCUIApplication *app ) { return app.helpTags; }
XCUIElementQuery *appElsIcon( XCUIApplication *app ) { return app.icons; }
XCUIElementQuery *appElsImage( XCUIApplication *app ) { return app.images; }
XCUIElementQuery *appElsIncrementArrow( XCUIApplication *app ) { return app.incrementArrows; }
XCUIElementQuery *appElsKey( XCUIApplication *app ) { return app.keys; }
XCUIElementQuery *appElsKeyboard( XCUIApplication *app ) { return app.keyboards; }
XCUIElementQuery *appElsLayoutArea( XCUIApplication *app ) { return app.layoutAreas; }
XCUIElementQuery *appElsLayoutItem( XCUIApplication *app ) { return app.layoutItems; }
XCUIElementQuery *appElsLevelIndicator( XCUIApplication *app ) { return app.levelIndicators; }
XCUIElementQuery *appElsLink( XCUIApplication *app ) { return app.links; }
XCUIElementQuery *appElsMap( XCUIApplication *app ) { return app.maps; }
XCUIElementQuery *appElsMatte( XCUIApplication *app ) { return app.mattes; }
XCUIElementQuery *appElsMenu( XCUIApplication *app ) { return app.menus; }
XCUIElementQuery *appElsMenuBar( XCUIApplication *app ) { return app.menuBars; }
XCUIElementQuery *appElsMenuBarItem( XCUIApplication *app ) { return app.menuBarItems; }
XCUIElementQuery *appElsMenuButton( XCUIApplication *app ) { return app.menuButtons; }
XCUIElementQuery *appElsMenuItem( XCUIApplication *app ) { return app.menuItems; }
XCUIElementQuery *appElsNavigationBar( XCUIApplication *app ) { return app.navigationBars; }
XCUIElementQuery *appElsOther( XCUIApplication *app ) { return app.otherElements; }
XCUIElementQuery *appElsOutline( XCUIApplication *app ) { return app.outlines; }
XCUIElementQuery *appElsOutlineRow( XCUIApplication *app ) { return app.outlineRows; }
XCUIElementQuery *appElsPageIndicator( XCUIApplication *app ) { return app.pageIndicators; }
XCUIElementQuery *appElsPicker( XCUIApplication *app ) { return app.pickers; }
XCUIElementQuery *appElsPickerWheel( XCUIApplication *app ) { return app.pickerWheels; }
XCUIElementQuery *appElsPopUpButton( XCUIApplication *app ) { return app.popUpButtons; }
XCUIElementQuery *appElsPopover( XCUIApplication *app ) { return app.popovers; }
XCUIElementQuery *appElsProgressIndicator( XCUIApplication *app ) { return app.progressIndicators; }
XCUIElementQuery *appElsRadioButton( XCUIApplication *app ) { return app.radioButtons; }
XCUIElementQuery *appElsRadioGroup( XCUIApplication *app ) { return app.radioGroups; }
XCUIElementQuery *appElsRatingIndicator( XCUIApplication *app ) { return app.ratingIndicators; }
XCUIElementQuery *appElsRelevanceIndicator( XCUIApplication *app ) { return app.relevanceIndicators; }
XCUIElementQuery *appElsRuler( XCUIApplication *app ) { return app.rulers; }
XCUIElementQuery *appElsRulerMarker( XCUIApplication *app ) { return app.rulerMarkers; }
XCUIElementQuery *appElsScrollBar( XCUIApplication *app ) { return app.scrollBars; }
XCUIElementQuery *appElsScrollView( XCUIApplication *app ) { return app.scrollViews; }
XCUIElementQuery *appElsSearchField( XCUIApplication *app ) { return app.searchFields; }
XCUIElementQuery *appElsSecureTextField( XCUIApplication *app ) { return app.secureTextFields; }
XCUIElementQuery *appElsSegmentedControl( XCUIApplication *app ) { return app.segmentedControls; }
XCUIElementQuery *appElsSheet( XCUIApplication *app ) { return app.sheets; }
XCUIElementQuery *appElsSlider( XCUIApplication *app ) { return app.sliders; }
XCUIElementQuery *appElsSplitGroup( XCUIApplication *app ) { return app.splitGroups; }
XCUIElementQuery *appElsSplitter( XCUIApplication *app ) { return app.splitters; }
XCUIElementQuery *appElsStaticText( XCUIApplication *app ) { return app.staticTexts; }
XCUIElementQuery *appElsStatusBar( XCUIApplication *app ) { return app.statusBars; }
XCUIElementQuery *appElsStatusItem( XCUIApplication *app ) { return app.statusItems; }
XCUIElementQuery *appElsStepper( XCUIApplication *app ) { return app.steppers; }
XCUIElementQuery *appElsSwitch( XCUIApplication *app ) { return app.switches; }
XCUIElementQuery *appElsTab( XCUIApplication *app ) { return app.tabs; }
XCUIElementQuery *appElsTabBar( XCUIApplication *app ) { return app.tabBars; }
XCUIElementQuery *appElsTabGroup( XCUIApplication *app ) { return app.tabGroups; }
XCUIElementQuery *appElsTable( XCUIApplication *app ) { return app.tables; }
XCUIElementQuery *appElsTableColumn( XCUIApplication *app ) { return app.tableColumns; }
XCUIElementQuery *appElsTableRow( XCUIApplication *app ) { return app.tableRows; }
XCUIElementQuery *appElsTextField( XCUIApplication *app ) { return app.textFields; }
XCUIElementQuery *appElsTextView( XCUIApplication *app ) { return app.textViews; }
XCUIElementQuery *appElsTimeline( XCUIApplication *app ) { return app.timelines; }
XCUIElementQuery *appElsToggle( XCUIApplication *app ) { return app.toggles; }
XCUIElementQuery *appElsToolbar( XCUIApplication *app ) { return app.toolbars; }
XCUIElementQuery *appElsToolbarButton( XCUIApplication *app ) { return app.toolbarButtons; }
XCUIElementQuery *appElsValueIndicator( XCUIApplication *app ) { return app.valueIndicators; }
XCUIElementQuery *appElsWebView( XCUIApplication *app ) { return app.webViews; }
XCUIElementQuery *appElsWindow( XCUIApplication *app ) { return app.windows; }
XCUIElementQuery *appElsTouchBar( XCUIApplication *app ) { return app.touchBars; }*/

-(void) entry:(id)param {
    nng_rep_open(&_replySocket);
    
    char addr2[50];
    sprintf( addr2, "tcp://*:%d", _nngPort );
    nng_setopt_int( _replySocket, NNG_OPT_SENDBUF, 100000);
    int listen_error = nng_listen( _replySocket, addr2, NULL, 0);
    if( listen_error != 0 ) {
        NSLog( @"xxr error bindind on * : %d - %d", _nngPort, listen_error );
        [FBLogger logFmt:@"xxr error bindind on * : %d - %d", _nngPort, listen_error ];
    }
    [FBLogger logFmt:@"NNG Ready"];

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
    
  // Unnecessary function map based method for selecting elements
  /*XCUIElementQuery *(*appElsFuncs[90])(XCUIApplication *app);
  for( int i=0;i<90;i++ ) appElsFuncs[i] = NULL;
  appElsFuncs[XCUIElementTypeActivityIndicator] = appElsActivityIndicator;
  appElsFuncs[XCUIElementTypeAlert] = appElsAlert;
  //appElsFuncs[XCUIElementTypeAny] = appElsAny;
  //appElsFuncs[XCUIElementTypeApplication] = appElsApplication;
  appElsFuncs[XCUIElementTypeBrowser] = appElsBrowser;
  appElsFuncs[XCUIElementTypeButton] = appElsButton;
  appElsFuncs[XCUIElementTypeCell] = appElsCell;
  appElsFuncs[XCUIElementTypeCheckBox] = appElsCheckBox;
  appElsFuncs[XCUIElementTypeCollectionView] = appElsCollectionView;
  appElsFuncs[XCUIElementTypeColorWell] = appElsColorWell;
  appElsFuncs[XCUIElementTypeComboBox] = appElsComboBox;
  appElsFuncs[XCUIElementTypeDatePicker] = appElsDatePicker;
  appElsFuncs[XCUIElementTypeDecrementArrow] = appElsDecrementArrow;
  appElsFuncs[XCUIElementTypeDialog] = appElsDialog;
  appElsFuncs[XCUIElementTypeDisclosureTriangle] = appElsDisclosureTriangle;
  appElsFuncs[XCUIElementTypeDockItem] = appElsDockItem;
  appElsFuncs[XCUIElementTypeDrawer] = appElsDrawer;
  appElsFuncs[XCUIElementTypeGrid] = appElsGrid;
  appElsFuncs[XCUIElementTypeGroup] = appElsGroup;
  appElsFuncs[XCUIElementTypeHandle] = appElsHandle;
  appElsFuncs[XCUIElementTypeHelpTag] = appElsHelpTag;
  appElsFuncs[XCUIElementTypeIcon] = appElsIcon;
  appElsFuncs[XCUIElementTypeImage] = appElsImage;
  appElsFuncs[XCUIElementTypeIncrementArrow] = appElsIncrementArrow;
  appElsFuncs[XCUIElementTypeKey] = appElsKey;
  appElsFuncs[XCUIElementTypeKeyboard] = appElsKeyboard;
  appElsFuncs[XCUIElementTypeLayoutArea] = appElsLayoutArea;
  appElsFuncs[XCUIElementTypeLayoutItem] = appElsLayoutItem;
  appElsFuncs[XCUIElementTypeLevelIndicator] = appElsLevelIndicator;
  appElsFuncs[XCUIElementTypeLink] = appElsLink;
  appElsFuncs[XCUIElementTypeMap] = appElsMap;
  appElsFuncs[XCUIElementTypeMatte] = appElsMatte;
  appElsFuncs[XCUIElementTypeMenu] = appElsMenu;
  appElsFuncs[XCUIElementTypeMenuBar] = appElsMenuBar;
  appElsFuncs[XCUIElementTypeMenuBarItem] = appElsMenuBarItem;
  appElsFuncs[XCUIElementTypeMenuButton] = appElsMenuButton;
  appElsFuncs[XCUIElementTypeMenuItem] = appElsMenuItem;
  appElsFuncs[XCUIElementTypeNavigationBar] = appElsNavigationBar;
  appElsFuncs[XCUIElementTypeOther] = appElsOther;
  appElsFuncs[XCUIElementTypeOutline] = appElsOutline;
  appElsFuncs[XCUIElementTypeOutlineRow] = appElsOutlineRow;
  appElsFuncs[XCUIElementTypePageIndicator] = appElsPageIndicator;
  appElsFuncs[XCUIElementTypePicker] = appElsPicker;
  appElsFuncs[XCUIElementTypePickerWheel] = appElsPickerWheel;
  appElsFuncs[XCUIElementTypePopUpButton] = appElsPopUpButton;
  appElsFuncs[XCUIElementTypePopover] = appElsPopover;
  appElsFuncs[XCUIElementTypeProgressIndicator] = appElsProgressIndicator;
  appElsFuncs[XCUIElementTypeRadioButton] = appElsRadioButton;
  appElsFuncs[XCUIElementTypeRadioGroup] = appElsRadioGroup;
  appElsFuncs[XCUIElementTypeRatingIndicator] = appElsRatingIndicator;
  appElsFuncs[XCUIElementTypeRelevanceIndicator] = appElsRelevanceIndicator;
  appElsFuncs[XCUIElementTypeRuler] = appElsRuler;
  appElsFuncs[XCUIElementTypeRulerMarker] = appElsRulerMarker;
  appElsFuncs[XCUIElementTypeScrollBar] = appElsScrollBar;
  appElsFuncs[XCUIElementTypeScrollView] = appElsScrollView;
  appElsFuncs[XCUIElementTypeSearchField] = appElsSearchField;
  appElsFuncs[XCUIElementTypeSecureTextField] = appElsSecureTextField;
  appElsFuncs[XCUIElementTypeSegmentedControl] = appElsSegmentedControl;
  appElsFuncs[XCUIElementTypeSheet] = appElsSheet;
  appElsFuncs[XCUIElementTypeSlider] = appElsSlider;
  appElsFuncs[XCUIElementTypeSplitGroup] = appElsSplitGroup;
  appElsFuncs[XCUIElementTypeSplitter] = appElsSplitter;
  appElsFuncs[XCUIElementTypeStaticText] = appElsStaticText;
  appElsFuncs[XCUIElementTypeStatusBar] = appElsStatusBar;
  appElsFuncs[XCUIElementTypeStatusItem] = appElsStatusItem;
  appElsFuncs[XCUIElementTypeStepper] = appElsStepper;
  appElsFuncs[XCUIElementTypeSwitch] = appElsSwitch;
  appElsFuncs[XCUIElementTypeTab] = appElsTab;
  appElsFuncs[XCUIElementTypeTabBar] = appElsTabBar;
  appElsFuncs[XCUIElementTypeTabGroup] = appElsTabGroup;
  appElsFuncs[XCUIElementTypeTable] = appElsTable;
  appElsFuncs[XCUIElementTypeTableColumn] = appElsTableColumn;
  appElsFuncs[XCUIElementTypeTableRow] = appElsTableRow;
  appElsFuncs[XCUIElementTypeTextField] = appElsTextField;
  appElsFuncs[XCUIElementTypeTextView] = appElsTextView;
  appElsFuncs[XCUIElementTypeTimeline] = appElsTimeline;
  appElsFuncs[XCUIElementTypeToggle] = appElsToggle;
  appElsFuncs[XCUIElementTypeToolbar] = appElsToolbar;
  appElsFuncs[XCUIElementTypeToolbarButton] = appElsToolbarButton;
  appElsFuncs[XCUIElementTypeValueIndicator] = appElsValueIndicator;
  appElsFuncs[XCUIElementTypeWebView] = appElsWebView;
  appElsFuncs[XCUIElementTypeWindow] = appElsWindow;
  appElsFuncs[XCUIElementTypeTouchBar] = appElsTouchBar;*/
  
    XCUIApplication *app = nil;
    XCUIApplication *systemApp = nil;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:10];
    XCUIDevice *device = XCUIDevice.sharedDevice;
  
    FBApplication *sbApp = [ [FBApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
    
    ujsonin_init();
    while( 1 ) {
        nng_msg *nmsg = NULL;
        nng_recvmsg( _replySocket, &nmsg, 0 );
        if( nmsg ) {
            const char *respText = NULL;
            char *respTextA = NULL;
            int respLen = 0;
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
                
                if( !strncmp( action, "done", 4 ) ) break;
                else if( !strncmp( action, "ping", 4 ) ) {
                    respText = "pong";
                }
                else if( !strncmp( action, "tap", 3 ) && strlen( action ) == 3 ) {
                    int x = node_hash__get_int( root, "x", 1 );
                    int y = node_hash__get_int( root, "y", 1 );
                    [device cf_tap:x y:y];
                    respText = "ok";
                }
                else if( !strncmp( action, "mouseDown", 9 ) && strlen( action ) == 9 ) {
                    int x = node_hash__get_int( root, "x", 1 );
                    int y = node_hash__get_int( root, "y", 1 );
                    [device cf_mouseDown:x y:y];
                    respText = "ok";
                }
                else if( !strncmp( action, "mouseUp", 7 ) && strlen( action ) == 7 ) {
                    int x = node_hash__get_int( root, "x", 1 );
                    int y = node_hash__get_int( root, "y", 1 );
                    [device cf_mouseUp:x y:y];
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
                else if( !strncmp( action, "toLauncher", 10 )) {
                    if( [sbApp fb_state] < 2 ) [sbApp launch];
                    else                       [sbApp fb_activate];
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
                else if( !strncmp( action, "homebtn", 7 ) ) {
                    double duration = 0.1;
                    [device cf_holdHomeButtonForDuration:duration];
                    respText = "ok";
                }
                else if( !strncmp( action, "wifiIp", 6 ) ) {
                    NSString *ip = [device fb_wifiIPAddress];
                    respTextA = strdup( [ip UTF8String] );
                }
                else if( !strncmp( action, "elClick", 7 ) ) {
                    char *elId = node_hash__get_str( root, "id", 2 );
                    NSString *id2 = [NSString stringWithUTF8String:elId];
                  
                    XCUIElement *element = dict[id2];
                    [dict removeObjectForKey:id2];
                    NSError *error = nil;
                    if( element == nil ) {
                        // todo error
                    } else {
                        /*if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")) {
                            [element tap];
                        } else {
                            XCElementSnapshot *snapshot = (XCElementSnapshot *) [element snapshotWithError:&error];
                            int x = snapshot.frame.origin.x/2;
                            int y = snapshot.frame.origin.y/2;
                            NSLog( @"tapping a %d,%d", x+1, y+1 );
                            [device cf_tap:x/2 y:y/2];
                        }*/
                        [element fb_tapWithError:&error];
                    }
                }
                else if( !strncmp( action, "elTouchAndHold", 14 ) ) {
                    char *elId = node_hash__get_str( root, "id", 2 );
                    NSString *id2 = [NSString stringWithUTF8String:elId];
                  
                    XCUIElement *element = dict[id2];
                    [dict removeObjectForKey:id2];
                    double forTime = node_hash__get_double( root, "time", 4 );
                    [element pressForDuration:forTime];
                }
                else if( !strncmp( action, "elForceTouch", 12 ) ) {
                    char *elId = node_hash__get_str( root, "id", 2 );
                    NSString *id2 = [NSString stringWithUTF8String:elId];
                  
                    XCUIElement *element = dict[id2];
                    [dict removeObjectForKey:id2];
                    
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
                    [device cf_tapFirm:(int)x y:(int)y pressure:pressure];
                }
                else if( !strncmp( action, "getEl", 9 ) ) {
                    char *name = node_hash__get_str( root, "id", 2 );
                    NSString *name2 = [NSString stringWithUTF8String:name];
                    
                    char *type = node_hash__get_str( root, "type", 4 );
                    int typeNum = 0;
                    if( type ) {
                        NSString *type2 = [NSString stringWithUTF8String:type];
                        id typeNumNS = types[ type2 ];
                        if( typeNumNS ) typeNum = [typeNumNS intValue];
                    }
                    
                    double wait = node_hash__get_double( root, "wait", 4 );
                  
                    XCUIElement *el = nil;
                  
                    for(;;) {
                        if( node_hash__get( root, "system", 6 ) ) {
                            //el = systemApp.buttons[name2];
                            //XCUIElementQuery *(*qfunc)(XCUIApplication *app);
                            //qfunc = appElsFuncs[typeNum];
                            //if( qfunc ) el = qfunc( systemApp )[name2];
                            
                            //el = [systemApp descendantsMatchingType:typeNum][name2];//.firstMatch;
                            
                            XCUIElementQuery *query = [systemApp descendantsMatchingType:typeNum];
                            el = [query elementMatchingType:typeNum identifier:name2];
                        }
                        else {
                            //el = app.buttons[name2];
                            //XCUIElementQuery *(*qfunc)(XCUIApplication *app);
                            //qfunc = appElsFuncs[typeNum];
                            //if( qfunc ) el = qfunc( app )[name2];
                            
                            //el = [app descendantsMatchingType:typeNum][name2];
                            
                            XCUIElementQuery *query = [app descendantsMatchingType:typeNum];
                            el = [query elementMatchingType:typeNum identifier:name2];
                          
                            //NSPredicate *p1 = [NSPredicate predicateWithFormat:@"type == cd //%@",typeNum];
                            //query = [query matchingPredicate:pred];
                            
                        }
                      
                        if( wait != -1 ) {
                            bool exists = [el waitForExistenceWithTimeout:wait];
                            if( !exists ) el = nil;
                        }
                        else {
                            if( !el.exists ) el = nil;
                        }
                        
                        if( el == nil ) {
                            respText = "";
                            break;
                        }
                        
                        NSString *key;
                        for( int i=0;i<20;i++ ) {
                            key = createKey();
                            if( dict[key] == nil ) break;
                        }
                        dict[key] = el;
                        
                        respTextA = strdup( [key UTF8String] );
                        
                        break;
                    }
                }
                else if( !strncmp( action, "elByName", 8 ) ) {
                    char *name = node_hash__get_str( root, "name", 4 );
                    NSString *name2 = [NSString stringWithUTF8String:name];
                    
                    XCUIElement *element = [ [app
                                              fb_descendantsMatchingIdentifier:name2
                                              shouldReturnAfterFirstMatch:true]
                                            firstObject];
                    if( element == nil ) {
                      element = [ [systemApp
                                   fb_descendantsMatchingIdentifier:name2
                                   shouldReturnAfterFirstMatch:true]
                                 firstObject];
                    }
                    
                    //let predicate = NSPredicate(format: "identifier CONTAINS 'Cat'")
                    //let image = app.images.matching(predicate).element(boundBy: 0)
                    //XCUIElementQuery *q = app.buttons;
                    //XCUIElement *element = [q elementBoundByIndex:0 ];
                  
                    NSString *key;
                    for( int i=0;i<20;i++ ) {
                        key = createKey();
                        if( dict[key] == nil ) break;
                    }
                    dict[key] = element;
                    
                    respTextA = strdup( [key UTF8String] );
                }
                else if( !strncmp( action, "alertInfo", 9 ) ) {
                    FBAlert *alert = [FBAlert alertWithApplication:app];
                    
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
                        alertText = [alertText stringByReplacingOccurrencesOfString:@"\""
                                     withString:@"\\\""];
                        res = [res stringByAppendingFormat:@"]\n  alert:\"%@\"\n]\n}", alertText];
                      
                        respTextA = strdup( [res UTF8String] );
                    }
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
                else if( !strncmp( action, "siri", 4 ) ) {
                    NSError *error;
                    char *text = node_hash__get_str( root, "text", 4 );
                    NSString *text2 = [NSString stringWithUTF8String:text];
                    [device fb_activateSiriVoiceRecognitionWithText:text2 error:&error];
                }
                else if( !strncmp( action, "status", 6 ) ) {
                    respText = "{sessionId:\"fakesession\"}";
                }
                else if( !strncmp( action, "typeText", 8 ) ) {
                    char *text = node_hash__get_str( root, "text", 4 );
                    NSString *text2 = [NSString stringWithUTF8String:text];
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
                    char *bi = node_hash__get_str( root, "bundleId", 8 );
                    app = [ [XCUIApplication alloc] initWithBundleIdentifier:[NSString stringWithUTF8String:bi]];
                }
                else if( !strncmp( action, "source", 6 ) ) {
                    XCUIElement *el = nil;
                    
                    char *bi = node_hash__get_str( root, "bi", 2 );
                    if( bi ) {
                        NSString *bi2 = [NSString stringWithUTF8String:bi];
                        el = [ [XCUIApplication alloc] initWithBundleIdentifier:bi2];
                    } else {
                        el = app;
                    }
                  
                    int pid = node_hash__get_int( root, "pid", 3 );
                    if( pid != -1 ) {
                        el = [FBApplication applicationWithPID:pid];
                    }
                    
                    NSError *serror = nil;
                    XCElementSnapshot *snapshot = (XCElementSnapshot *) [el snapshotWithError:&serror];
                    if( serror != nil ) [FBLogger logFmt:@"err:%@", serror ];
                    NSDictionary *sdict = [snapshot dictionaryRepresentation];
                    NSMutableString *str = [NSMutableString stringWithString:@""];
                    if( strlen( action ) > 6 ) {
                        [self dictToJson:sdict str:str depth: 0];
                    } else {
                        [self dictToStr:sdict str:str depth: 0];
                    }
                    respTextA = strdup( [str UTF8String] );
                }
                else if( !strncmp( action, "elementAtPoint", 14 ) ) {
                    int x = node_hash__get_int( root, "x", 1 );
                    int y = node_hash__get_int( root, "y", 1 );
                    int json = node_hash__get_int( root, "json", 4 );
                    int nopid = node_hash__get_int( root, "nopid", 5 );
                    int top = node_hash__get_int( root, "top", 3 );
                    //XCUIElement *el = [XCUIApplication elementAtPoint:x y:y];
                    //instancetype *sharedClient = FBXCAXClientProxy.sharedClient;
                    
                    //XCUIElement *el = [FBXCAXClientProxy.sharedClient elementAtPoint:x y:y];
                    //XCUIApplication *app = [el application];
                    CGPoint point = CGPointMake(x,y);
                    XCAccessibilityElement *el = [app cf_requestElementAtPoint:point];
                    
                    //AXUIElement *el2 = [AXUIElement uiElementWithAXElement:el.AXUIElement];
                    
                    NSArray *standardAttributes = FBStandardAttributeNames();
                  
                    XCElementSnapshot *snap = [app cf_snapshotForElement:el
                                                              attributes:standardAttributes
                                                              parameters:nil];
                  
                    if( top != -1 ) {
                        while( snap.parent != nil ) {
                            //XCAccessibilityElement *parentEl = snap.parentAccessibilityElement;
                            //snap = [app cf_snapshotForElement:parentEl
                            //                                        attributes:standardAttributes
                            //                                        parameters:nil];
                            snap = snap.parent;
                        }
                        snap = snap.rootElement;
                    }
                    
                    int pid = el.processIdentifier;
                                        
                    /*char str[200];
                    sprintf( str, "pid:%d", pid );
                    respTextA = strdup( str );*/
                  
                    NSMutableString *str = [NSMutableString stringWithString:@""];
                  
                    if( nopid == -1 ) [str appendFormat:@"Pid:%d\n", pid];
                    
                    if( json != -1 ) {
                        [self snapToJson:snap str:str depth: 0 app:app];
                    } else {
                        NSDictionary *sdict = [snap dictionaryRepresentation];
                        
                        [self dictToStr:sdict str:str depth: 0];
                    }
                    respTextA = strdup( [str UTF8String] );
                }
                else if( !strncmp( action, "elPos", 5 ) ) {
                    char *elId = node_hash__get_str( root, "id", 2 );
                    NSString *id2 = [NSString stringWithUTF8String:elId];
                  
                    XCUIElement *element = dict[id2];
                    CGRect frame = [element frame];
                    int x = (int) frame.origin.x;
                    int y = (int) frame.origin.y;
                    int width = (int) frame.size.width;
                    int height = (int) frame.size.height;
                    char json[200];
                    sprintf( json, "{x:%d,y:%d,w:%d,h:%d}", x, y, width, height );
                    respTextA = strdup( json );
                }
                else if( !strncmp( action, "windowSize", 10 ) ) {
                    CGRect frame = CGRectIntegral( systemApp.frame );
                    
                    char output[100];
                    sprintf(output,
                            "{width:%d,height:%d}",
                            (int)frame.size.width,
                            (int)frame.size.height);
                    respTextA = strdup( output );
                }
                else if( !strncmp( action, "createSession", 13 ) ) {
                    //[XCUIApplicationProcessDelay setEventLoopHasIdledDelay:[delay doubleValue]];
                    //[XCUIApplicationProcessDelay disableEventLoopDelay];
                                     
                    char *bundleID = node_hash__get_str( root, "bundleId", 8 );
                                            
                    int pid = [[FBXCAXClientProxy.sharedClient systemApplication] processIdentifier];
                    systemApp = [FBApplication applicationWithPID:pid];
                    if( strlen(bundleID) ) {
                      app = [ [XCUIApplication alloc] initWithBundleIdentifier:[NSString stringWithUTF8String:bundleID]];
                      
                      //app.fb_shouldWaitForQuiescence = true; // or nil
                      app.launchArguments = @[];
                      app.launchEnvironment = @{};
                      [app launch];
                      
                      if( app.processID == 0 ) {
                        // todo
                      }
                    } else {
                      app = systemApp;
                    }
                                        
                    NSString *sessionId = @"fakesession";
                    const char *sid = [sessionId UTF8String];
                    [FBLogger logFmt:@"createSession sid:%s", sid ];
                    respTextA = strdup( sid );
                }
                else if( !strncmp( action, "activeApps", 10 ) ) {
                    NSArray<XCAccessibilityElement *> *apps = [FBXCAXClientProxy.sharedClient activeApplications];
                    
                    NSMutableString *ids = [[NSMutableString alloc] init];
                    for( int i=0;i<[apps count];i++ ) {
                        XCAccessibilityElement *app = [apps objectAtIndex:i];
                        int pid = app.processIdentifier;
                        [ids appendFormat:@"%d,", pid ];
                    }
                    const char *idsC = [ids UTF8String];
                    respTextA = strdup( idsC );
                }
                else if( !strncmp( action, "elByPid", 7 ) ) {
                    int pid = node_hash__get_int( root, "pid", 3 );
                    int json = node_hash__get_int( root, "json", 4 );
                    XCAccessibilityElement *el = [XCAccessibilityElement elementWithProcessIdentifier:pid];
                    
                    NSArray *standardAttributes = FBStandardAttributeNames();
                  
                    XCElementSnapshot *snap = [app cf_snapshotForElement:el
                                                              attributes:standardAttributes
                                                              parameters:nil];
                    
                    NSMutableString *str = [NSMutableString stringWithString:@""];
                    
                    if( json != -1 ) {
                        [self snapToJson:snap str:str depth: 0 app:app];
                    } else {
                        NSDictionary *sdict = [snap dictionaryRepresentation];
                        
                        [self dictToStr:sdict str:str depth: 0];
                    }
                    respTextA = strdup( [str UTF8String] );
                }
                else if( !strncmp( action, "pidChildWithWidth", 17 ) ) {
                    int pid = node_hash__get_int( root, "pid", 3 );
                    int matchWidth = node_hash__get_int( root, "width", 5 );
                  
                    //XCUIApplication *app = [XCUIApplication applicationWithPID:0];
                    //FBApplication *app = [FBApplication fb_applicationWithPID:pid];
                    XCAccessibilityElement *el = [XCAccessibilityElement elementWithProcessIdentifier:pid];
                    
                    NSArray *standardAttributes = FBStandardAttributeNames();
                  
                    XCElementSnapshot *snap = [app cf_snapshotForElement:el
                                                              attributes:standardAttributes
                                                              parameters:nil];
                  
                    XCUIElement *app = [XCUIElement alloc];
                    [app setLastSnapshot:snap];
                  
                    NSArray<XCElementSnapshot *> *children = [app descendantsMatchingType:XCUIElementTypeOther];
                  
                    XCUIElement *gotit = nil;
                    for( int i=0;i<[children count];i++ ) {
                        XCUIElement *el = [children objectAtIndex:i];
                        CGRect frame = [el frame];
                        int width = frame.size.width;
                        if( width == matchWidth ) {
                          gotit = el;
                        }
                    }
                    if( gotit != nil ) {
                        NSString *key;
                        for( int i=0;i<20;i++ ) {
                            key = createKey();
                            if( dict[key] == nil ) break;
                        }
                        dict[key] = gotit;
                        
                        respTextA = strdup( [key UTF8String] );
                    } else {
                        respText = "could not find";
                    }
                }
            }
            else NSLog(@"xxr empty message");
            if( root ) node_hash__delete( root );
            nng_msg_free( nmsg );
            
            nng_msg *respN;
            nng_msg_alloc(&respN, 0);
            
            if( respTextA ) respText = respTextA;
            [FBLogger logFmt:@"sending back :%s", respText ];
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
