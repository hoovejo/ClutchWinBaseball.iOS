//
//  Franchise.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-18.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "FranchiseModel.h"

@implementation FranchiseModel

// We use @dynamic for the properties in Core Data
@dynamic retroId;
@dynamic leagueId;
@dynamic divisionId;
@dynamic location;
@dynamic name;

- (NSString *)displayName {
    
    return [NSString stringWithFormat:@"%1$@ %2$@  %3$@", self.location, self.name, self.leagueId];
}

@end
