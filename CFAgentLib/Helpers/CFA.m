#import "CFA.h"
#import "XCUIElement.h"

static NSArray *map = nil;
static NSDictionary *types = nil;
@implementation CFA

+ (NSString *) typeStr:(long)typeNum {
  if( map == nil ) [CFA typeMap];
  return map[typeNum];
}

+ (long) typeNum:(NSString *)typeStr {
  if( types == nil ) [CFA types];
  id typeNumNS = types[ typeStr ];
  return [typeNumNS longValue];
}

+ (NSDictionary *) types {
  static dispatch_once_t once;
  dispatch_once(&once, ^{
  types = [[NSDictionary alloc] initWithObjectsAndKeys:
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
  });
  return types;
}

+ (NSArray *) typeMap {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
    map = @[
    @"Any", @"Other",  @"Application",  @"Group", @"Window", @"Sheet",
    @"Drawer", @"Alert", @"Dialog", @"Button", @"RadioButton", @"RadioGroup",
    @"CheckBox", @"DisclosureTriangle", @"PopUpButton", @"ComboBox", @"MenuButton",
    @"ToolbarButton", @"Popover", @"Keyboard", @"Key", @"NavigationBar", @"TabBar",
    @"TabGroup", @"Toolbar", @"StatusBar", @"Table", @"TableRow", @"TableColumn",
    @"Outline", @"OutlineRow", @"Browser", @"CollectionView", @"Slider",
    @"PageIndicator", @"ProgressIndicator", @"ActivityIndicator", @"SegmentedControl",
    @"Picker", @"PickerWheel", @"Switch", @"Toggle", @"Link", @"Image", @"Icon",
    @"SearchField", @"ScrollView", @"ScrollBar", @"StaticText", @"TextField",
    @"SecureTextField", @"DatePicker", @"TextView", @"Menu", @"MenuItem", @"MenuBar",
    @"MenuBarItem", @"Map", @"WebView", @"IncrementArrow", @"DecrementArrow",
    @"Timeline", @"RatingIndicator", @"ValueIndicator", @"SplitGroup", @"Splitter",
    @"RelevanceIndicator", @"ColorWell", @"HelpTag", @"Matte", @"DockItem", @"Ruler",
    @"RulerMarker", @"Grid", @"LevelIndicator", @"Cell", @"LayoutArea",
    @"LayoutItem", @"Handle", @"Stepper", @"Tab"
    ];
  });
  return map;
}

@end


