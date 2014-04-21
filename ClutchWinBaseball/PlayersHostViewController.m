//
//  PlayersHostViewController.m
//  Clutch Win Baseball
//
//  Created by Joe Hoover on 2014-04-15.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "PlayersHostViewController.h"

//controllers
#import "PlayersYearsTVC.h"
#import "PlayersTeamsTVC.h"
#import "PlayersBattersTVC.h"
#import "PlayersPitchersTVC.h"
#import "PlayersResultsTVC.h"
#import "PlayersDrillDownTVC.h"
//context model
#import "TeamsContextViewModel.h"

@interface PlayersHostViewController () <ViewPagerDataSource, ViewPagerDelegate, PlayersYearsTVCDelegate, PlayersTeamsTVCDelegate, PlayersBattersTVCDelegate, PlayersPitchersTVCDelegate, PlayersResultsTVCDelegate>

@property (nonatomic) NSUInteger numberOfTabs;
//controllers
@property (nonatomic, strong) PlayersYearsTVC *playersYearsTVC;
@property (nonatomic, strong) PlayersTeamsTVC *playersTeamsTVC;
@property (nonatomic, strong) PlayersBattersTVC *playersBattersTVC;
@property (nonatomic, strong) PlayersPitchersTVC *playersPitchersTVC;
@property (nonatomic, strong) PlayersResultsTVC *playersResultsTVC;
@property (nonatomic, strong) PlayersDrillDownTVC *playersDrillDownTVC;
//context model
@property (nonatomic, strong) PlayersContextViewModel *playersContextViewModel;

@end

@implementation PlayersHostViewController

- (void)viewDidLoad {
    
    if (self.playersContextViewModel == nil) {
        self.playersContextViewModel = [[PlayersContextViewModel alloc] init];
    }
    
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    [self performSelector:@selector(loadContent) withObject:nil];
    
    self.title = @"Players vs Players";
    
    // Keeps tab bar below navigation bar on iOS 7.0+
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setters
- (void)setNumberOfTabs:(NSUInteger)numberOfTabs {
    
    // Set numberOfTabs
    _numberOfTabs = numberOfTabs;
    
    // Reload data
    [self reloadData];
    
}

#pragma mark - Delegates for view controller(s)
- (void)playersYearSelected:(PlayersYearsTVC *)controller
{
    if (self.playersTeamsTVC != nil) {
        //call for a manual eval and possible load
        [self.playersTeamsTVC refresh];
    }
    
    [self selectTabAtIndex:1];
}

- (void)playersTeamSelected:(PlayersTeamsTVC *)controller
{
    if (self.playersBattersTVC != nil) {
        //call for a manual eval and possible load
        [self.playersBattersTVC refresh];
    }
    
    [self selectTabAtIndex:2];
}

- (void)playersBatterSelected:(PlayersBattersTVC *)controller
{
    if (self.playersPitchersTVC != nil) {
        //call for a manual eval and possible load
        [self.playersPitchersTVC refresh];
    }
    
    [self selectTabAtIndex:3];
}

- (void)playersPitcherSelected:(PlayersPitchersTVC *)controller
{
    if (self.playersResultsTVC != nil) {
        //call for a manual eval and possible load
        [self.playersResultsTVC refresh];
    }
    
    [self selectTabAtIndex:4];
}

- (void)playersResultSelected:(PlayersResultsTVC *)controller
{
    if (self.playersDrillDownTVC != nil) {
        //call for a manual eval and possible load
        [self.playersDrillDownTVC refresh];
    }
    
    [self selectTabAtIndex:5];
}

#pragma mark - Helpers
- (void)loadContent {
    self.numberOfTabs = 6;
}

#pragma mark - Interface Orientation Changes
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // Update changes after screen rotates
    [self performSelector:@selector(setNeedsReloadOptions) withObject:nil afterDelay:duration];
}

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    
    return self.numberOfTabs;
}
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12.0];
    
    switch (index) {
        case 0:
            label.text = @"Years"; break;
        case 1:
            label.text = @"Teams"; break;
        case 2:
            label.text = @"Batters"; break;
        case 3:
            label.text = @"Pitchers"; break;
        case 4:
            label.text = @"Results"; break;
        case 5:
            label.text = @"Details"; break;
        default:
            label.text = @"Years";
    }
    //[NSString stringWithFormat:@"Tab #%i", index];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    
    return label;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    switch (index) {
        case 0: {
            if (self.playersYearsTVC == nil) {
                //instantiating the view will fire viewDidLoad and cause a load
                self.playersYearsTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playersYearsTVC"];
                [self.playersYearsTVC setDelegate:self];
                [self.playersYearsTVC setPlayersContextViewModel:self.playersContextViewModel];
            }
            return self.playersYearsTVC;
        }
        case 1: {
            if (self.playersTeamsTVC == nil) {
                //instantiating the view will fire viewDidLoad and cause a load
                self.playersTeamsTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playersTeamsTVC"];
                [self.playersTeamsTVC setDelegate:self];
                [self.playersTeamsTVC setPlayersContextViewModel:self.playersContextViewModel];
            }
            return self.playersTeamsTVC;
        }
        case 2: {
            if (self.playersBattersTVC == nil) {
                //instantiating the view will fire viewDidLoad and cause a load
                self.playersBattersTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playersBattersTVC"];
                [self.playersBattersTVC setDelegate:self];
                [self.playersBattersTVC setPlayersContextViewModel:self.playersContextViewModel];
            }
            return self.playersBattersTVC;
        }
        case 3: {
            if (self.playersPitchersTVC == nil) {
                //instantiating the view will fire viewDidLoad and cause a load
                self.playersPitchersTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playersPitchersTVC"];
                [self.playersPitchersTVC setDelegate:self];
                [self.playersPitchersTVC setPlayersContextViewModel:self.playersContextViewModel];
            }
            return self.playersPitchersTVC;
        }
        case 4: {
            if (self.playersResultsTVC == nil) {
                //instantiating the view will fire viewDidLoad and cause a load
                self.playersResultsTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playersResultsTVC"];
                [self.playersResultsTVC setDelegate:self];
                [self.playersResultsTVC setPlayersContextViewModel:self.playersContextViewModel];
            }
            return self.playersResultsTVC;
        }
        case 5: {
            if (self.playersDrillDownTVC == nil) {
                //instantiating the view will fire viewDidLoad and cause a load
                self.playersDrillDownTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playersDrillDownTVC"];
                [self.playersDrillDownTVC setPlayersContextViewModel:self.playersContextViewModel];
            }
            return self.playersDrillDownTVC;
        }
        default: {
            if (self.playersYearsTVC == nil) {
                //instantiating the view will fire viewDidLoad and cause a load
                self.playersYearsTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playersYearsTVC"];
                [self.playersYearsTVC setDelegate:self];
                [self.playersYearsTVC setPlayersContextViewModel:self.playersContextViewModel];
            }
            return self.playersYearsTVC;
        }
    }
}

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 0.0;
        case ViewPagerOptionCenterCurrentTab:
            return 1.0;
        case ViewPagerOptionTabLocation:
            return 0.0;
        case ViewPagerOptionTabHeight:
            return 49.0;
        case ViewPagerOptionTabOffset:
            return 36.0;
        case ViewPagerOptionTabWidth:
            return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 128.0 : 96.0;
        case ViewPagerOptionFixFormerTabsPositions:
            return 1.0;
        case ViewPagerOptionFixLatterTabsPositions:
            return 1.0;
        default:
            return value;
    }
}
- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    
    switch (component) {
        case ViewPagerIndicator:
            return [[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] colorWithAlphaComponent:0.64];
        case ViewPagerTabsView:
            return [[UIColor lightGrayColor] colorWithAlphaComponent:0.32];
        case ViewPagerContent:
            return [[UIColor darkGrayColor] colorWithAlphaComponent:0.32];
        default:
            return color;
    }
}

@end
