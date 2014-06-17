//
//  CWBText.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-06-16.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWBText : NSObject

#pragma mark -
+ (NSString *)configuration;

+ (NSString *)errorMessage;
+ (NSString *)networkMessage;
+ (NSString *)selectTeam;
+ (NSString *)noResults;
+ (NSString *)selectOpponent;
+ (NSString *)selectResult;
+ (NSString *)selectSeason;
+ (NSString *)selectSeasonTeam;
+ (NSString *)selectBatter;
+ (NSString *)selectPitcher;

@end
