//
//  PlayersDrillDownTVC.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayersContextViewModel.h"

@interface PlayersDrillDownTVC : UITableViewController



@property (weak, nonatomic) IBOutlet UILabel *notifyLabel;
@property (nonatomic, strong) PlayersContextViewModel *playersContextViewModel;

- (void) refresh;

@end