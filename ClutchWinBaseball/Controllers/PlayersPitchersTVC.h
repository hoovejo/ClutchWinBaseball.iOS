//
//  PlayersPitchersTVC.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayersContextViewModel.h"

@class PlayersPitchersTVC;

@protocol PlayersPitchersTVCDelegate
- (void)playersPitcherSelected:(PlayersPitchersTVC *)controller;
@end

@interface PlayersPitchersTVC : UITableViewController


@property (weak, nonatomic) IBOutlet UILabel *notifyLabel;
@property (weak, nonatomic) id <PlayersPitchersTVCDelegate> delegate;
@property (nonatomic, strong) PlayersContextViewModel *playersContextViewModel;

- (void)refresh;

@end
