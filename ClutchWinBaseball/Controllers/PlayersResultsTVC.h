//
//  PlayersResultsTVC.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayersContextViewModel.h"

@class PlayersResultsTVC;

@protocol PlayersResultsTVCDelegate
- (void)playersResultSelected:(PlayersResultsTVC *)controller;
@end

@interface PlayersResultsTVC : UITableViewController

@property (weak, nonatomic) id <PlayersResultsTVCDelegate> delegate;
@property (nonatomic, strong) PlayersContextViewModel *playersContextViewModel;

- (void) refresh;

@end
