//
//  PlayersResult.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

@interface PlayersResultModel : NSManagedObject

@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *games;
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
