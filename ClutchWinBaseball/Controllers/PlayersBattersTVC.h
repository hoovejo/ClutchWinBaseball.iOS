//
//  PlayersBattersTVC.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayersContextViewModel.h"

@class PlayersBattersTVC;

@protocol PlayersBattersTVCDelegate
- (void)playersBatterSelected:(PlayersBattersTVC *)controller;
@end

@interface PlayersBattersTVC : UITableViewController

- (IBAction)goToSeasons:(id)sender;
- (IBAction)goToTeams:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *goToSeasonsButton;
@property (weak, nonatomic) IBOutlet UIButton *goToTeamsButton;
@property (weak, nonatomic) IBOutlet UILabel *notifyLabel;

@property (weak, nonatomic) id <PlayersBattersTVCDelegate> delegate;
@property (nonatomic, strong) PlayersContextViewModel *playersContextViewModel;

- (void)refresh;

@end
