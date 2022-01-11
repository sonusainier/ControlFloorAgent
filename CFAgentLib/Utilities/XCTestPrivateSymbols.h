// Copyright (c) 2015, Facebook Inc. All rights reserved.
// BSD license - See LICENSE

#import <Foundation/Foundation.h>

@protocol XCDebugLogDelegate;

// Accessibility identifier for is visible attribute
extern NSNumber *FB_XCAXAIsVisibleAttribute;
extern NSString *FB_XCAXAIsVisibleAttributeName;

// Accessibility identifier for is accessible attribute
extern NSNumber *FB_XCAXAIsElementAttribute;
extern NSString *FB_XCAXAIsElementAttributeName;

// Getter for  XCTest logger
extern id<XCDebugLogDelegate> (*XCDebugLogger)(void);

// Setter for  XCTest logger
extern void (*XCSetDebugLogger)(id <XCDebugLogDelegate>);

// Maps string attributes to AX Accesibility Attributes
extern NSArray<NSNumber *> *(*XCAXAccessibilityAttributesForStringAttributes)(id stringAttributes);

/**
 Method used to retrieve pointer for given symbol 'name' from given 'binary'

 @param name name of the symbol
 @return pointer to symbol
 */
void *FBRetrieveXCTestSymbol(const char *name);

// Static constructor that will retrieve XCTest private symbols
__attribute__((constructor)) void FBLoadXCTestSymbols(void);

NSArray<NSString*> *FBStandardAttributeNames(void);
