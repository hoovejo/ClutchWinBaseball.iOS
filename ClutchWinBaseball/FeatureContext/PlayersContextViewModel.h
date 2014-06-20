//
//  PlayersContextViewModel.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
//#import <RestKit/CoreData.h>

@interface PlayersContextViewModel : NSObject

@property BOOL hasLoadedSeasonsOncePerSession;

//retain current selections
@property (nonatomic, strong) NSString *yearId;
@property (nonatomic, strong) NSString *teamId;
@property (nonatomic, strong) NSString *batterId;
@property (nonatomic, strong) NSString *pitcherId;
@property (nonatomic, strong) NSString *resultYearId;
//retain last param for team search
@property (nonatomic, strong) NSString *lastYearId;
//retain last param for batter search
@property (nonatomic, strong) NSString *lastTeamId;
//retain last param for pitcher search
@property (nonatomic, strong) NSString *lastBatterId;
//retain last params for player result search
@property (nonatomic, strong) NSString *lastSearchBatterId;
@property (nonatomic, strong) NSString *lastSearchPitcherId;
//retain last params for player drilldown search
@property (nonatomic, strong) NSString *lastDrillDownBatterId;
@property (nonatomic, strong) NSString *lastDrillDownPitcherId;
@property (nonatomic, strong) NSString *lastDrillDownYearId;

- (void) setLoadedOnce;
- (void) recordLastYearId:(NSString *)newYearId;
- (void) recordLastTeamId:(NSString *)newTeamId;
- (void) recordLastBatterId:(NSString *)newBatterId;
- (void) recordLastSearchIds:(NSString *)newBatterId : (NSString *)newPitcherId;
- (void) recordLastDrillDownIds:(NSString *)newBatterId : (NSString *)newPitcherId : (NSString *)newYearId;

@end
