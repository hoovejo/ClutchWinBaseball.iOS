//
//  TeamsResultsCellTableViewCell.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-19.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamsResultsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *yearLabel;
@property (nonatomic, weak) IBOutlet UILabel *gamesLabel;
@property (nonatomic, weak) IBOutlet UILabel *teamLabel;
@property (nonatomic, weak) IBOutlet UILabel *opponentLabel;
@property (nonatomic, weak) IBOutlet UILabel *winsLabel;
@property (nonatomic, weak) IBOutlet UILabel *lossesLabel;
@property (nonatomic, weak) IBOutlet UILabel *runsForLabel;
@property (nonatomic, weak) IBOutlet UILabel *runsAgainstLabel;

@end
