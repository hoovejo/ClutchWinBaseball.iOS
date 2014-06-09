//
//  TeamsDetailsTVC.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-19.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeamsContextViewModel.h"

@interface TeamsDrillDownTVC : UICollectionViewController


@property (weak, nonatomic) IBOutlet UILabel *notifyLabel;
@property (nonatomic, strong) TeamsContextViewModel *teamsContextViewModel;

- (void) refresh;

@end

