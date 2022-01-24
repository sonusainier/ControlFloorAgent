// Copyright (C) 2021 Dry Ark LLC
// Cooperative License ( LICENSE_DRYARK )
#define IOS_VERSION()       [[UIDevice currentDevice] systemVersion]
#define IOS_EQUALS(v)       (IOS_VERSION() isEqualToString:v )
#define IOS_GREATER_THAN(v) ([IOS_VERSION() compare:v options:NSNumericSearch] == NSOrderedDescending)
#define IOS_LESS_THAN(v)    ([IOS_VERSION() compare:v options:NSNumericSearch] == NSOrderedAscending )
#define IOS_GREATER_THAN_OR_EQUAL_TO(v)  ([IOS_VERSION() compare:v options:NSNumericSearch] != NSOrderedAscending)
