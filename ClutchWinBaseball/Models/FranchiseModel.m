//
//  Franchise.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-18.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "FranchiseModel.h"

@implementation FranchiseModel

- (NSString *)displayName {
    
    return [NSString stringWithFormat:@"%1$@ %2$@", self.location, self.name];
}

@end
