// Copyright (c) 2015, Facebook Inc. All rights reserved.
// BSD license - See LICENSE

#define IOS_EQUALS(v)       ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define IOS_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define IOS_LESS_THAN(v)    ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
