//
//  TeamsResultsTVC.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-19.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeamsContextViewModel.h"

@class TeamsResultsTVC;

@protocol TeamsResultsTVCDelegate
- (void)teamsResultSelected:(TeamsResultsTVC *)controller;
@end


@interface TeamsResultsTVC : UITableViewController

@property (weak, nonatomic) id <TeamsResultsTVCDelegate> delegate;
@property (nonatomic, strong) TeamsContextViewModel *teamsContextViewModel;

- (void) refresh;

@end