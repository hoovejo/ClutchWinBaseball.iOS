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
            
            NSError *error = nil;
            NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
            
            if(!error && [results count] != 0){
                [self readyTheArray];
                
                for(TeamsDrillDownModel *result in results) {
                    if( result.gameDate != nil){
                        [self.results addObject:result];
                    }
                }
                [self.tableView reloadData];
            } else {
                
                [self readyTheArray];
                [self loadResults];
            }
        }
    }
}

- (void)loadResults
{
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
                                                  self.results = [mappingResult.array mutableCopy];
                                                  [self.tableView reloadData];
                                                  [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                                                  [self.teamsContextViewModel recordLastDrillDownIds];
                                                  [spinner stopAnimating];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load franchise details failed with exception': %@", error);
                                                  }
                                              }];
}

#pragma mark - Helper methods
- (BOOL) needsToLoadData {
    
    if (![self.teamsContextViewModel.franchiseId isEqualToString:self.teamsContextViewModel.lastDrillDownFranchiseId]) {
        return YES;
    }
    
    if (![self.teamsContextViewModel.opponentId isEqualToString:self.teamsContextViewModel.lastDrillDownOpponentId]) {
        return YES;
    }

    if (![self.teamsContextViewModel.yearId isEqualToString:self.teamsContextViewModel.lastDrillDownYearId]) {
        return YES;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamsDrillDownTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeamsDrillDownTableViewCell" forIndexPath:indexPath];
    
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


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


@end
