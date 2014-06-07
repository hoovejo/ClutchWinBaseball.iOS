//
//  Team.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

@interface TeamModel : NSManagedObject

@property (nonatomic, strong) NSString *teamIdValue;
@property (nonatomic, strong) NSString *leagueId;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *name;

- (NSString *)displayName;

@end
