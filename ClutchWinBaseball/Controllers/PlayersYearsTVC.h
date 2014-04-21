//
//  PlayersYearsTVC.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayersContextViewModel.h"

@class PlayersYearsTVC;

@protocol PlayersYearsTVCDelegate
- (void)playersYearSelected:(PlayersYearsTVC *)controller;
@end

@interface PlayersYearsTVC : UITableViewController

@property (weak, nonatomic) id <PlayersYearsTVCDelegate> delegate;
@property (nonatomic, strong) PlayersContextViewModel *playersContextViewModel;

@end
