//
//  Team.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "TeamModel.h"

@implementation TeamModel

- (NSString *)displayName {
    
    return [NSString stringWithFormat:@"%1$@ %2$@", self.location, self.name];
}

@end
