//
//  TeamsTVC.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-18.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeamsContextViewModel.h"

@class TeamsFranchisesTVC;

@protocol TeamsFranchisesTVCDelegate
- (void)teamsFranchiseSelected:(TeamsFranchisesTVC *)controller;
@end

@interface TeamsFranchisesTVC : UITableViewController

@property (weak, nonatomic) id <TeamsFranchisesTVCDelegate> delegate;
@property (nonatomic, strong) TeamsContextViewModel *teamsContextViewModel;

@end