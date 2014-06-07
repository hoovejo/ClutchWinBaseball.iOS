//
//  TeamDrillDown.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-19.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

@interface TeamsDrillDownModel : NSManagedObject

@property (nonatomic, strong) NSString *gameDate;
@property (nonatomic, strong) NSString *team;
@property (nonatomic, strong) NSString *opponent;
@property (nonatomic, strong) NSString *win;
@property (nonatomic, strong) NSString *loss;
@property (nonatomic, strong) NSString *runsFor;
@property (nonatomic, strong) NSString *runsAgainst;

@end
