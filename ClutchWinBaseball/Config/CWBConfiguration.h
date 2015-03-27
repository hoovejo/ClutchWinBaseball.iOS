//
//  Configuration.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-19.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWBConfiguration : NSObject

#pragma mark -
+ (NSString *)configuration;

#pragma mark -
+ (NSString *)analyticsTokenValue;
+ (NSString *)baseUrlString;
+ (NSString *)jsonSuffix;
+ (NSString *)franchiseUrl;
+ (NSString *)franchiseSearchUrl;
+ (NSString *)franchiseSearchByYearUrl;

+ (NSString *)yearUrl;
+ (NSString *)teamSearchUrl;
+ (NSString *)batterSearchUrl;
+ (NSString *)pitcherSearchUrl;
+ (NSString *)playerResultsUrl;
+ (NSString *)playerDrillDownUrl;

+ (BOOL)isLoggingEnabled;

@end
