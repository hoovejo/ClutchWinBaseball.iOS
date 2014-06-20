//
//  PlayersDrillDown.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
//#import <RestKit/CoreData.h>

@interface PlayersDrillDownModel : NSObject

@property (nonatomic, strong) NSString *gameDate;
@property (nonatomic, strong) NSString *atBat;
@property (nonatomic, strong) NSString *hit;
@property (nonatomic, strong) NSString *walks;
@property (nonatomic, strong) NSString *strikeOut;
@property (nonatomic, strong) NSString *secondBase;
@property (nonatomic, strong) NSString *thirdBase;
@property (nonatomic, strong) NSString *homeRun;
@property (nonatomic, strong) NSString *runBattedIn;
@property (nonatomic, strong) NSString *average;

@end
