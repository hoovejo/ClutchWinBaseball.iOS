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
#import "ServiceEndpointHub.h"

@interface TeamsResultsTVC ()

@property BOOL isLoading;
@property (nonatomic, strong) NSMutableArray *results;

@end

@implementation TeamsResultsTVC

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
        
        self.isLoading = YES;
        [self readyTheArray];
        [self loadResults];
        
    } else {
        // if object is recreated load from core data
        if( [self.results count] == 0 ) {

            NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
            NSEntityDescription *entityDescription = [NSEntityDescription
                                                      entityForName:@"TeamsResult" inManagedObjectContext:managedObjectContext];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            
            NSSortDescriptor * sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:NO];
            [request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
            
            NSError *error = nil;
            NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
            
            if(!error && [results count] != 0){
                [self readyTheArray];
                
                for(TeamsResultModel *result in results) {
                    if( result.year != nil){
                        [self.results addObject:result];
                    }
                }
                [self.tableView reloadData];
            } else {
                
                if ([self serviceCallAllowed]) {
                    [self readyTheArray];
                    [self loadResults];
                }
            }
        }
        
        [self setNotifyText:NO:NO];
    }
}

- (void) setNotifyText: (BOOL) service : (BOOL) error {
    
    if(error){
        [self.notifyLabel setText:@"an error has occured"];
    } else if (service) {
        if([self.results count] == 0){
            [self.notifyLabel setText:@"no results found"];
        } else {
            [self.notifyLabel setText:@""];
        }
    } else {
        if([self.results count] == 0){
            [self.notifyLabel setText:@"select an opponent first"];
        } else {
            [self.notifyLabel setText:@""];
        }
    }
}

- (void)loadResults
{
    // http://clutchwin.com/api/v1/games/for_team/summary.json?
    // &access_token=abc&franchise_abbr=TOR&opp_franchise_abbr=BAL&group=season,team_abbr,opp_abbr&fieldset=basic
    NSString *teamsResultsEndpoint = [NSString stringWithFormat:@"%1$@&franchise_abbr=%2$@&opp_franchise_abbr=%3$@",
                                      [CWBConfiguration franchiseSearchUrl],
                                      self.teamsContextViewModel.franchiseId,
                                      self.teamsContextViewModel.opponentId];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:teamsResultsEndpoint
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  NSArray *sorted = [mappingResult.array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                                                      NSString *first = [(TeamsResultModel*)a year];
                                                      NSString *second = [(TeamsResultModel*)b year];
                                                      return [second compare:first];
                                                  }];
                                                  
                                                  self.results = [sorted mutableCopy];
                                                  [self.tableView reloadData];
                                                  [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                                                  [self.teamsContextViewModel recordLastSearchIds];
                                                  
                                                  [spinner stopAnimating];
                                                  [self setNotifyText:YES:NO];
                                                  self.isLoading = NO;
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load franchise results failed with exception': %@", error);
                                                  }
                                                  [spinner stopAnimating];
                                                  [self setNotifyText:YES:YES];
                                                  self.isLoading = NO;
                                              }];
}

#pragma mark - Helper methods
- (BOOL) serviceCallAllowed {
    
    //check for empty and nil
    if ([self.teamsContextViewModel.franchiseId length] == 0 || [self.teamsContextViewModel.opponentId length] == 0) {
        return NO;
    }
    return YES;
}

- (BOOL) needsToLoadData {

    if ([self serviceCallAllowed]) {
        if (![self.teamsContextViewModel.franchiseId isEqualToString:self.teamsContextViewModel.lastSearchFranchiseId]) {
            return YES;
        }
    
        if (![self.teamsContextViewModel.opponentId isEqualToString:self.teamsContextViewModel.lastSearchOpponentId]) {
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
    static NSString *CellIdentifier = @"TeamsResultsTableViewCell";
    
    TeamsResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    TeamsResultModel *result = self.results[indexPath.row];
    
    cell.yearLabel.text = result.year;
    cell.gamesLabel.text = [NSString stringWithFormat: @"%d", [result.wins intValue]+[result.losses intValue]];
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
    if (!self.isLoading) {
        TeamsResultModel *result = self.results[indexPath.row];
        self.teamsContextViewModel.yearId = result.year;
    
        [self.delegate teamsResultSelected:self];
    }
}


@end
