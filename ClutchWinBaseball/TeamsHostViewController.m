//
//  HostViewController.m
//  Clutch Win Baseball
//
//  Created by Joe Hoover on 2014-04-15.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "TeamsHostViewController.h"
#import "ServiceEndpointHub.h"
//controllers
#import "TeamsFranchisesTVC.h"
#import "TeamsOpponentsTVC.h"
#import "TeamsResultsTVC.h"
#import "TeamsDrillDownTVC.h"
//context model
#import "TeamsContextViewModel.h"

@interface TeamsHostViewController () <ViewPagerDataSource, ViewPagerDelegate, TeamsFranchisesTVCDelegate, TeamsOpponentsTVCDelegate,
                                        TeamsResultsTVCDelegate>

@property (nonatomic) NSUInteger numberOfTabs;
//controllers
@property (nonatomic, strong) TeamsFranchisesTVC *teamsFranchisesTVC;
@property (nonatomic, strong) TeamsOpponentsTVC *teamsOpponentsTVC;
@property (nonatomic, strong) TeamsResultsTVC *teamsResultsTVC;
@property (nonatomic, strong) TeamsDrillDownTVC *teamsDrillDownTVC;
//context model
@property (nonatomic, strong) TeamsContextViewModel *teamsContextViewModel;

@end

@implementation TeamsHostViewController

- (void)viewDidLoad {
    
    if (self.teamsContextViewModel == nil) {
        
        self.teamsContextViewModel = [[TeamsContextViewModel alloc] init];
        
        /*
        NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
        NSError *error = nil;
        NSFetchRequest * request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"TeamsContextViewModel" inManagedObjectContext:managedObjectContext]];
        self.teamsContextViewModel = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
        
        if(error){
            self.teamsContextViewModel = [[TeamsContextViewModel alloc] init];
        }
         */
    }
    
    self.dataSource = self;
    self.delegate = self;
    
    [self performSelector:@selector(loadContent) withObject:nil];
    
    self.title = @"Team vs Team";
    
    // Keeps tab bar below navigation bar on iOS 7.0+
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [super viewDidLoad];
}
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:nil];
}

- (void)orientationChanged:(NSNotification *)notification{

    [self setNeedsReloadOptions];
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
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
- (void)teamsFranchiseSelected:(TeamsFranchisesTVC *)controller
{
    if (self.teamsOpponentsTVC != nil) {
        //call for a manual eval and possible load
        
        if([self.teamsOpponentsTVC.franchises count] == 0){
            [self.teamsOpponentsTVC setFranchises: self.teamsFranchisesTVC.franchises ];
        }
        
        [self.teamsOpponentsTVC refresh];
    }
    
    [self selectTabAtIndex:1];
}

- (void)teamsOpponentSelected:(TeamsOpponentsTVC *)controller
{
    if (self.teamsResultsTVC != nil) {
        //call for a manual eval and possible load
        [self.teamsResultsTVC refresh];
    }
    
    [self selectTabAtIndex:2];
}

- (void)teamsResultSelected:(TeamsResultsTVC *)controller
{
    if (self.teamsDrillDownTVC != nil) {
        //call for a manual eval and possible load
        [self.teamsDrillDownTVC refresh];
    }
    
    [self selectTabAtIndex:3];
}


#pragma mark - Helpers
- (void)loadContent {
    self.numberOfTabs = 4;
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
            label.text = @"Teams"; break;
        case 1:
            label.text = @"Opponents"; break;
        case 2:
            label.text = @"Results"; break;
        case 3:
            label.text = @"Details"; break;
        default:
            label.text = @"Teams";
    }
    //[NSString stringWithFormat:@"Tab #%i", index];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    
    return label;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {

    //cvc.labelString = [NSString stringWithFormat:@"Content View #%i", index];
    
    switch (index) {
        case 0: {
            if (self.teamsFranchisesTVC == nil) {
                //instantiating the view will fire viewDidLoad and cause a load
                self.teamsFranchisesTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"teamsTVC"];
                [self.teamsFranchisesTVC setDelegate:self];
                [self.teamsFranchisesTVC setTeamsContextViewModel:self.teamsContextViewModel];
            } else {
                [self.teamsFranchisesTVC refresh];
            }
            
            return self.teamsFranchisesTVC;
        }
        case 1: {
            if (self.teamsOpponentsTVC == nil) {
                //instantiating the view will fire viewDidLoad and cause a load
                self.teamsOpponentsTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"opponentsTVC"];
                [self.teamsOpponentsTVC setDelegate:self];
                [self.teamsOpponentsTVC setFranchises: self.teamsFranchisesTVC.franchises ];
                [self.teamsOpponentsTVC setTeamsContextViewModel:self.teamsContextViewModel];
            } 
            return self.teamsOpponentsTVC;
        }
        case 2: {
            if (self.teamsResultsTVC == nil) {
                //instantiating the view will fire viewDidLoad and cause a load
                self.teamsResultsTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"teamsResultsTVC"];
                [self.teamsResultsTVC setDelegate:self];
                [self.teamsResultsTVC setTeamsContextViewModel:self.teamsContextViewModel];
            }
            return self.teamsResultsTVC;
        }
        case 3: {
            if (self.teamsDrillDownTVC == nil) {
                //instantiating the view will fire viewDidLoad and cause a load
                self.teamsDrillDownTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"teamsDrillDownTVC"];
                [self.teamsDrillDownTVC setTeamsContextViewModel:self.teamsContextViewModel];
            }
            return self.teamsDrillDownTVC;
        }
        default: {
            if (self.teamsFranchisesTVC == nil) {
                //instantiating the view will fire viewDidLoad and cause a load
                self.teamsFranchisesTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"teamsTVC"];
                [self.teamsFranchisesTVC setDelegate:self];
                [self.teamsFranchisesTVC setTeamsContextViewModel:self.teamsContextViewModel];
            }
            return self.teamsFranchisesTVC;
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
            return 128.0; //UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 128.0 : 96.0;
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
