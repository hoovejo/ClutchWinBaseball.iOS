//
//  PlayersTeamsTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "ServiceEndpointHub.h"

#import "PlayersTeamsTVC.h"
#import "TeamModel.h"
#import "CWBConfiguration.h"
#import "CWBText.h"
#import "TeamsResusableView.h"

@interface PlayersTeamsTVC ()

@end

@implementation PlayersTeamsTVC

- (void)viewDidLoad
{
    [self refresh];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loading controller
- (void) refresh {
  
    [self setNotifyText:@""];
    
    if ([self needsToLoadData]) {
        
        [self readyTheArray];
        [self loadResults];
        
    } else if (![self serviceCallAllowed]){
        //if svc call not allowed prereq's not met
        NSString *msg = [CWBText selectSeason];
        [self setNotifyText:msg];
    }
}

- (void) setNotifyText: (NSString *) msg {
    [self.notifyLabel setText:msg];
}

- (void)loadResults
{
    BOOL isNetworkAvailable = [ServiceEndpointHub getIsNetworkAvailable];
    
    if (!isNetworkAvailable) {
        NSString *msg = [CWBText networkMessage];
        [self setNotifyText:msg];
        return;
    }
    
    // http://clutchwin.com/api/v1/teams.json?
    // &access_token=abc&season=2013
    NSString *teamSearchEndpoint = [NSString stringWithFormat:@"%1$@&season=%2$@",
                                      [CWBConfiguration teamSearchUrl],
                                      self.playersContextViewModel.yearId];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = self.view.center;
    spinner.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    spinner.center = self.view.center;
    spinner.hidesWhenStopped = YES;
    if ([spinner respondsToSelector:@selector(setColor:)]) {
        [spinner setColor:[UIColor grayColor]];
    }
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:teamSearchEndpoint
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  NSArray *sorted = [mappingResult.array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                                                      NSString *first = [(TeamModel*)a location];
                                                      NSString *second = [(TeamModel*)b location];
                                                      return [first compare:second];
                                                  }];
                                                  
                                                  self.playersContextViewModel.teams = [sorted mutableCopy];
                                                  [self.collectionView reloadData];
                                                  [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                                                  [self.playersContextViewModel recordLastYearId:self.playersContextViewModel.yearId];
                                                  
                                                  [spinner stopAnimating];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load teams failed with exception': %@", error);
                                                  }
                                                  [spinner stopAnimating];
                                                  NSString *msg = [CWBText errorMessage];
                                                  [self setNotifyText:msg];
                                              }];
}

#pragma mark - Helper methods
- (BOOL) serviceCallAllowed {
    
    //check for empty and nil
    if ([self.playersContextViewModel.yearId length] == 0) {
        return NO;
    }
    return YES;
}

- (BOOL) needsToLoadData {

    if ([self serviceCallAllowed]) {
        
        if ( [self.playersContextViewModel.teams count] == 0 ){
            return YES;
        }
        
        if (![self.playersContextViewModel.yearId isEqualToString:self.playersContextViewModel.lastYearId]) {
            return YES;
        }
    }
    return NO;
}

- (void) readyTheArray {
    if( [self.playersContextViewModel.teams count] == 0 ){
        self.playersContextViewModel.teams = [[NSMutableArray alloc] init];
    } else {
        [self.playersContextViewModel.teams removeAllObjects];
    }
}

#pragma mark - UICollection view data source

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        TeamsResusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        headerView.title.text = @"Teams";
        
        reusableview = headerView;
    }
    
    return reusableview;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.playersContextViewModel.teams.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UILabel *displayText = (UILabel *)[cell viewWithTag:100];
    TeamModel *team = self.self.playersContextViewModel.teams[indexPath.row];
    displayText.text = [team displayName];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TeamModel *team = self.playersContextViewModel.teams[indexPath.row];
    self.playersContextViewModel.teamId = team.teamIdValue;
    
    [self.delegate playersTeamSelected:self];
    
    [self performSegueWithIdentifier:@"TeamsUnwind" sender:self];
}



@end
