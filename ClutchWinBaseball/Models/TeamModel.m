//
//  Team.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "TeamModel.h"

@implementation TeamModel

// We use @dynamic for the properties in Core Data
@dynamic teamIdValue;
@dynamic leagueId;
@dynamic location;
@dynamic name;

- (NSString *)displayName {
    
    return [NSString stringWithFormat:@"%1$@ %2$@  %3$@", self.location, self.name, self.leagueId];
}

@end
