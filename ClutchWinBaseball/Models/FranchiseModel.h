//
//  Franchise.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-18.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FranchiseModel : NSObject

@property (nonatomic, strong) NSString *franchiseId;
@property (nonatomic, strong) NSString *retroId;
@property (nonatomic, strong) NSString *leagueId;
@property (nonatomic, strong) NSString *divisionId;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *alternateName;
@property (nonatomic, strong) NSString *firstGameDt;
@property (nonatomic, strong) NSString *lastGameDt;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;

- (NSString *)displayName;

@end
