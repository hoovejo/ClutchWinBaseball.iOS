//
//  Pitcher.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "PitcherModel.h"

@implementation PitcherModel

- (NSString *)displayName {
    
    return [NSString stringWithFormat:@"%1$@ %2$@", self.firstName, self.lastName];
}

@end
