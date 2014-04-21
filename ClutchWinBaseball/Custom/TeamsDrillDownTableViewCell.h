//
//  TeamsDrillDownTableViewCell.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-19.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamsDrillDownTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *gameDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *teamLabel;
@property (nonatomic, weak) IBOutlet UILabel *opponentLabel;
@property (nonatomic, weak) IBOutlet UILabel *winLabel;
@property (nonatomic, weak) IBOutlet UILabel *lossLabel;
@property (nonatomic, weak) IBOutlet UILabel *runsForLabel;
@property (nonatomic, weak) IBOutlet UILabel *runsAgainstLabel;

@end
