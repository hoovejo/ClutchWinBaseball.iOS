//
//  TeamsDetailsTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-19.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
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
    [super viewDidLoad];
    
    [self refresh];
    
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
    }
}

- (void)loadResults
{
    //@"/search/franchise_vs_franchise_by_year/ATL/BOS/2012.json"
    NSString *teamsDrillDownEndpoint = [NSString stringWithFormat:@"%1$@%2$@/%3$@/%4$@%5$@",
                                      [CWBConfiguration franchiseSearchByYearUrl],
                                      self.teamsContextViewModel.franchiseId,
                                      self.teamsContextViewModel.opponentId,
                                      self.teamsContextViewModel.yearId,
                                      [CWBConfiguration jsonSuffix]];
    
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
