//
//  Franchise.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-18.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
//#import <RestKit/CoreData.h>

@interface FranchiseModel : NSObject

@property (nonatomic, strong) NSString *retroId;
@property (nonatomic, strong) NSString *leagueId;
@property (nonatomic, strong) NSString *divisionId;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *name;

- (NSString *)displayName;

@end
