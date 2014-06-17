//
//  TeamsDetailsTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-19.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "ServiceEndpointHub.h"

#import "TeamsDrillDownTVC.h"
#import "TeamsDrillDownModel.h"
#import "TeamsDrillDownTableViewCell.h"
#import "CWBConfiguration.h"
#import "CWBText.h"

@interface TeamsDrillDownTVC ()

@property (nonatomic, strong) NSMutableArray *results;

@end

@implementation TeamsDrillDownTVC

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
        
    } else {
        // if TeamsDrillDownTVC is recreated load from core data
        if( [self.results count] == 0 ) {
            
            NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
            NSEntityDescription *entityDescription = [NSEntityDescription
                                                      entityForName:@"TeamsDrillDown" inManagedObjectContext:managedObjectContext];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            
            NSSortDescriptor * sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"gameDate" ascending:NO];
            [request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
            
            NSError *error = nil;
            NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
            
            if(!error && [results count] != 0){
                [self readyTheArray];
                
                for(TeamsDrillDownModel *result in results) {
                    if( result.gameDate != nil){
                        [self.results addObject:result];
                    }
                }
                [self.collectionView reloadData];
            } else {
                
                if ([self serviceCallAllowed]) {
                    [self readyTheArray];
                    [self loadResults];
                } else {
                    //if svc call not allowed prereq's not met
                    NSString *msg = [CWBText selectResult];
                    [self setNotifyText:msg];
                }
            }
        }
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
    
    // http://clutchwin.com/api/v1/games/for_team.json?
    // &access_token=abc&franchise_abbr=TOR&opp_franchise_abbr=BAL&season=2013&fieldset=basic
    NSString *teamsDrillDownEndpoint = [NSString stringWithFormat:@"%1$@&franchise_abbr=%2$@&opp_franchise_abbr=%3$@&season=%4$@",
                                      [CWBConfiguration franchiseSearchByYearUrl],
                                      self.teamsContextViewModel.franchiseId,
                                      self.teamsContextViewModel.opponentId,
                                      self.teamsContextViewModel.yearId];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:teamsDrillDownEndpoint
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  NSArray *sorted = [mappingResult.array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                                                      NSString *first = [(TeamsDrillDownModel*)a gameDate];
                                                      NSString *second = [(TeamsDrillDownModel*)b gameDate];
                                                      return [second compare:first];
                                                  }];
                                                  
                                                  self.results = [sorted mutableCopy];
                                                  [self.collectionView reloadData];
                                                  [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                                                  [self.teamsContextViewModel recordLastDrillDownIds];
                                                  
                                                  [spinner stopAnimating];
                                                  if([self.results count] == 0){
                                                      NSString *msg = [CWBText noResults];
                                                      [self setNotifyText:msg];
                                                  }
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load franchise details failed with exception': %@", error);
                                                  }
                                                  [spinner stopAnimating];
                                                  NSString *msg = [CWBText errorMessage];
                                                  [self setNotifyText:msg];
                                              }];
}

#pragma mark - Helper methods
- (BOOL) serviceCallAllowed {
    
    //check for empty and nil
    if ([self.teamsContextViewModel.franchiseId length] == 0 || [self.teamsContextViewModel.opponentId length] == 0 || [self.teamsContextViewModel.yearId length] == 0) {
        return NO;
    }
    return YES;
}

- (BOOL) needsToLoadData {

    if ([self serviceCallAllowed]) {
        if (![self.teamsContextViewModel.franchiseId isEqualToString:self.teamsContextViewModel.lastDrillDownFranchiseId]) {
            return YES;
        }
        
        if (![self.teamsContextViewModel.opponentId isEqualToString:self.teamsContextViewModel.lastDrillDownOpponentId]) {
            return YES;
        }
        
        if (![self.teamsContextViewModel.yearId isEqualToString:self.teamsContextViewModel.lastDrillDownYearId]) {
            return YES;
        }
    }
    
    return NO;
}

- (void) readyTheArray {
    if( [self.results count] == 0 ){
        self.results = [[NSMutableArray alloc] init];
    } else {
        [self.results removeAllObjects];
    }
}

#pragma mark - UICollection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.results.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"TeamsDrillDownTableViewCell";
    
    TeamsDrillDownTableViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    TeamsDrillDownModel *result = self.results[indexPath.row];
    
    cell.gameDateLabel.text = result.gameDate;
    cell.teamLabel.text = result.team;
    cell.opponentLabel.text = result.opponent;
    cell.winLabel.text = result.win;
    cell.lossLabel.text = result.loss;
    cell.runsForLabel.text = result.runsFor;
    cell.runsAgainstLabel.text = result.runsAgainst;
    
    return cell;
}

@end
