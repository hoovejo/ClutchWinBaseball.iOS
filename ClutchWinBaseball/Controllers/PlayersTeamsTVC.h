//
//  PlayersTeamsTVC.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayersContextViewModel.h"

@class PlayersTeamsTVC;

@protocol PlayersTeamsTVCDelegate
- (void)playersTeamSelected:(PlayersTeamsTVC *)controller;
@end

@interface PlayersTeamsTVC : UICollectionViewController

@property (weak, nonatomic) IBOutlet UILabel *notifyLabel;
@property (weak, nonatomic) id <PlayersTeamsTVCDelegate> delegate;
@property (nonatomic, strong) PlayersContextViewModel *playersContextViewModel;

- (void)refresh;

@end
