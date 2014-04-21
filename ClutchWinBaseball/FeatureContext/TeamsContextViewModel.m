//
//  TeamsContextViewModel.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-20.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "TeamsContextViewModel.h"

@implementation TeamsContextViewModel

- (void) recordLastSearchIds {
    
    [self setLastSearchFranchiseId:self.franchiseId];
    [self setLastSearchOpponentId:self.opponentId];
}

- (void) recordLastDrillDownIds {
    [self setLastDrillDownFranchiseId:self.franchiseId];
    [self setLastDrillDownOpponentId:self.opponentId];
    [self setLastDrillDownYearId:self.yearId];}

@end
