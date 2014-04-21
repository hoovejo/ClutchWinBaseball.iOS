//
//  PlayersContextViewModel.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "PlayersContextViewModel.h"

@implementation PlayersContextViewModel

- (void) recordLastYearId {    
    [self setLastYearId:self.yearId];
}

- (void) recordLastTeamId {
    [self setLastTeamId:self.teamId];
}

- (void) recordLastBatterId {
    [self setLastBatterId:self.batterId];
}

- (void) recordLastSearchIds {
    [self setLastSearchBatterId:self.batterId];
    [self setLastSearchPitcherId:self.pitcherId];
}

- (void) recordLastDrillDownIds {
    [self setLastDrillDownBatterId:self.batterId];
    [self setLastDrillDownPitcherId:self.pitcherId];
    [self setLastDrillDownYearId:self.resultYearId];
    [self setLastDrillDownGameType:self.gameType];
}

@end
