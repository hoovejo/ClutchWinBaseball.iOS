//
//  Batter.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BatterModel : NSObject

@property (nonatomic, strong) NSString *batterIdValue;
@property (nonatomic, strong) NSString *batHand;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *gameType;
@property (nonatomic, strong) NSString *pitHand;
@property (nonatomic, strong) NSString *posTx;
@property (nonatomic, strong) NSString *repTeamId;
@property (nonatomic, strong) NSString *retroPlayerId;
@property (nonatomic, strong) NSString *retroTeamId;
@property (nonatomic, strong) NSString *yearId;

- (NSString *)displayName;

@end
