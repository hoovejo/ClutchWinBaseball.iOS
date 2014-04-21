//
//  TeamsResultsTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-19.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "TeamsResultsTVC.h"
#import "TeamsResultModel.h"
#import "TeamsResultsTableViewCell.h"
#import "CWBConfiguration.h"

@interface TeamsResultsTVC ()

@property (nonatomic, strong) NSMutableArray *results;

@end

@implementation TeamsResultsTVC

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
    //@"/search/franchise_vs_franchise/ATL/BAL.json"
    NSString *teamsResultsEndpoint = [NSString stringWithFormat:@"%1$@%2$@/%3$@%4$@",
                                      [CWBConfiguration franchiseSearchUrl],
                                      self.teamsContextViewModel.franchiseId,
                                      self.teamsContextViewModel.opponentId,
                                      [CWBConfiguration jsonSuffix]];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:teamsResultsEndpoint
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  self.results = [mappingResult.array mutableCopy];
                                                  [self.tableView reloadData];
                                                  [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                                                  [self.teamsContextViewModel recordLastSearchIds];
                                                  [spinner stopAnimating];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load franchise results failed with exception': %@", error);
                                                  }
                                              }];
}

#pragma mark - Helper methods
- (BOOL) needsToLoadData {
    
    if (![self.teamsContextViewModel.franchiseId isEqualToString:self.teamsContextViewModel.lastSearchFranchiseId]) {
        return YES;
    }
    
    if (![self.teamsContextViewModel.opponentId isEqualToString:self.teamsContextViewModel.lastSearchOpponentId]) {
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
    TeamsResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeamsResultsTableViewCell" forIndexPath:indexPath];
    
    TeamsResultModel *result = self.results[indexPath.row];
    
    cell.yearLabel.text = result.year;
    cell.gamesLabel.text = result.games;
    cell.teamLabel.text = result.team;
    cell.opponentLabel.text = result.opponent;
    cell.winsLabel.text = result.wins;
    cell.lossesLabel.text = result.losses;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamsResultModel *result = self.results[indexPath.row];
    self.teamsContextViewModel.yearId = result.year;
    
    [self.delegate teamsResultSelected:self];
}


@end
