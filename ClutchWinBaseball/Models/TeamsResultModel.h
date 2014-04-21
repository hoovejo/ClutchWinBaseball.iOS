//
//  TeamsResults.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-19.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamsResultModel : NSObject

@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *games;
@property (nonatomic, strong) NSString *team;
@property (nonatomic, strong) NSString *opponent;
@property (nonatomic, strong) NSString *wins;
@property (nonatomic, strong) NSString *losses;
@property (nonatomic, strong) NSString *runsFor;
@property (nonatomic, strong) NSString *runsAgainst;

@end
