//
//  PlayersResult.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayersResultModel : NSObject

@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *games;
@property (nonatomic, strong) NSString *atBat;
@property (nonatomic, strong) NSString *hit;
@property (nonatomic, strong) NSString *secondBase;
@property (nonatomic, strong) NSString *thirdBase;
@property (nonatomic, strong) NSString *homeRun;
@property (nonatomic, strong) NSString *runBattedIn;
@property (nonatomic, strong) NSString *strikeOut;
@property (nonatomic, strong) NSString *baseBall;
@property (nonatomic, strong) NSString *average;

@end
