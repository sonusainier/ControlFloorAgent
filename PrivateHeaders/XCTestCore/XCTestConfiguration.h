// class-dump results processed by bin/class-dump/dump.rb
//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Nov 26 2020 14:08:26).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <XCTest/XCUIElementTypes.h>
#import "CDStructures.h"
@protocol OS_dispatch_queue;
@protocol OS_xpc_object;

#import <objc/NSObject.h>

#import "XCTReportingSessionConfiguration-Protocol.h"

@class NSArray, NSDictionary, NSNumber, NSString, NSURL, NSUUID, XCTAggregateSuiteRunStatistics, XCTCapabilities, XCTRepetitionPolicy, XCTRerunPolicy, XCTTestIdentifierSet;

@interface XCTestConfiguration : NSObject <XCTReportingSessionConfiguration, NSSecureCoding, NSCopying>
{
    BOOL _reportResultsToIDE;
    BOOL _testsDrivenByIDE;
    BOOL _disablePerformanceMetrics;
    BOOL _treatMissingBaselinesAsFailures;
    BOOL _reportActivities;
    BOOL _testsMustRunOnMainThread;
    BOOL _initializeForUITesting;
    BOOL _gatherLocalizableStringsData;
    BOOL _emitOSLogs;
    BOOL _testTimeoutsEnabled;
    BOOL _shouldEncodeLegacyTestIdentifiers;
    NSString *_testBundleRelativePath;
    NSURL *_testBundleURL;
    XCTTestIdentifierSet *_testsToRun;
    XCTTestIdentifierSet *_testsToSkip;
    NSUUID *_sessionIdentifier;
    NSURL *_baselineFileURL;
    NSString *_baselineFileRelativePath;
    NSString *_targetApplicationPath;
    NSString *_targetApplicationBundleID;
    NSDictionary *_testApplicationDependencies;
    NSDictionary *_testApplicationUserOverrides;
    NSString *_productModuleName;
    NSNumber *_traceCollectionEnabled;
    NSDictionary *_performanceTestConfiguration;
    NSNumber *_enablePerformanceTestsDiagnostics;
    NSDictionary *_targetApplicationEnvironment;
    NSArray *_targetApplicationArguments;
    XCTAggregateSuiteRunStatistics *_aggregateStatisticsBeforeCrash;
    NSString *_automationFrameworkPath;
    NSInteger _systemAttachmentLifetime;
    NSInteger _userAttachmentLifetime;
    NSInteger _testExecutionOrdering;
    NSNumber *_randomExecutionOrderingSeed;
    XCTRepetitionPolicy *_repetitionPolicy;
    XCTRerunPolicy *_rerunPolicy;
    NSNumber *_defaultTestExecutionTimeAllowance;
    NSNumber *_maximumTestExecutionTimeAllowance;
    CDUnknownBlockType _randomNumberGenerator;
    NSString *_basePathForTestBundleResolution;
    XCTCapabilities *_IDECapabilities;
    NSDictionary *_applicationBundleInfos;
}

@property(retain) XCTCapabilities *IDECapabilities;
@property(copy) XCTAggregateSuiteRunStatistics *aggregateStatisticsBeforeCrash;
@property(copy) NSDictionary *applicationBundleInfos;
@property(copy) NSString *automationFrameworkPath;
@property(copy, nonatomic) NSString *basePathForTestBundleResolution;
@property(copy) NSString *baselineFileRelativePath;
@property(copy, nonatomic) NSURL *baselineFileURL;
@property(copy, nonatomic) NSNumber *defaultTestExecutionTimeAllowance;
@property BOOL disablePerformanceMetrics;
@property BOOL emitOSLogs;
@property(copy) NSNumber *enablePerformanceTestsDiagnostics;
@property BOOL gatherLocalizableStringsData;
@property BOOL initializeForUITesting;
@property(copy, nonatomic) NSNumber *maximumTestExecutionTimeAllowance;
@property(copy) NSDictionary *performanceTestConfiguration;
@property(copy) NSString *productModuleName;
@property(retain) NSNumber *randomExecutionOrderingSeed;
@property(copy) CDUnknownBlockType randomNumberGenerator;
@property(retain) XCTRepetitionPolicy *repetitionPolicy;
@property BOOL reportActivities;
@property BOOL reportResultsToIDE;
@property(retain) XCTRerunPolicy *rerunPolicy;
@property(copy) NSUUID *sessionIdentifier;
@property BOOL shouldEncodeLegacyTestIdentifiers;
@property NSInteger systemAttachmentLifetime;
@property(copy) NSArray *targetApplicationArguments;
@property(copy) NSString *targetApplicationBundleID;
@property(copy) NSDictionary *targetApplicationEnvironment;
@property(copy) NSString *targetApplicationPath;
@property(copy) NSDictionary *testApplicationDependencies;
@property(copy) NSDictionary *testApplicationUserOverrides;
@property(copy) NSString *testBundleRelativePath;
@property(copy, nonatomic) NSURL *testBundleURL;
@property NSInteger testExecutionOrdering;
@property BOOL testTimeoutsEnabled;
@property BOOL testsDrivenByIDE;
@property BOOL testsMustRunOnMainThread;
@property(copy) XCTTestIdentifierSet *testsToRun;
@property(copy) XCTTestIdentifierSet *testsToSkip;
@property(copy) NSNumber *traceCollectionEnabled;
@property BOOL treatMissingBaselinesAsFailures;
@property NSInteger userAttachmentLifetime;
@property(readonly) NSInteger testMode;

+ (id)activeTestConfiguration;
+ (id)defaultBasePathForTestBundleResolution;
+ (id)defaultBasePathForTestBundleResolutionForMainBundlePath:(id)arg1;
+ (void)setActiveTestConfiguration:(id)arg1;
- (void)_encodeTestIdentifiersWithCoder:(id)arg1;
- (void)clearXcodeReportingConfiguration;

@end

