//
//  PlayersResultsTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "PlayersResultsTVC.h"
#import "PlayersResultModel.h"
#import "PlayersResultsTableViewCell.h"
#import "CWBConfiguration.h"

@interface PlayersResultsTVC ()

@property (nonatomic, strong) NSMutableArray *results;

@end

@implementation PlayersResultsTVC

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
    //@"/search/player_vs_player/aybae001/parkj001.json"
    NSString *playerResultsEndpoint = [NSString stringWithFormat:@"%1$@%2$@/%3$@%4$@",
                                      [CWBConfiguration playerResultsUrl],
                                      self.playersContextViewModel.batterId,
                                      self.playersContextViewModel.pitcherId,
                                      [CWBConfiguration jsonSuffix]];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:playerResultsEndpoint
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {                                                  
                                                  //TODO: sort these results
                                                  self.results = [mappingResult.array mutableCopy];
                                                  [self.tableView reloadData];
                                                  [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                                                  [self.playersContextViewModel recordLastSearchIds];

                                                  [spinner stopAnimating];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load player results failed with exception': %@", error);
                                                  }
                                              }];
    
   

    

}

#pragma mark - Helper methods
- (BOOL) needsToLoadData {
    
    if (![self.playersContextViewModel.batterId isEqualToString:self.playersContextViewModel.lastSearchBatterId]) {
        return YES;
    }
    
    if (![self.playersContextViewModel.pitcherId isEqualToString:self.playersContextViewModel.lastSearchPitcherId]) {
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
    PlayersResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlayersResultsTableViewCell" forIndexPath:indexPath];
    
    PlayersResultModel *result = self.results[indexPath.row];
    
    cell.yearLabel.text = result.year;
    cell.typeLabel.text = result.type;
    cell.gamesLabel.text = result.games;
    cell.atBatLabel.text = result.atBat;
    cell.hitLabel.text = result.hit;
    cell.secondBaseLabel.text = result.secondBase;
    cell.thirdBaseLabel.text = result.thirdBase;
    cell.homeRunLabel.text = result.homeRun;
    cell.runBattedInLabel.text = result.runBattedIn;
    cell.strikeOutLabel.text = result.strikeOut;
    cell.baseBallLabel.text = result.baseBall;
    cell.averageLabel.text = result.average;

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
    PlayersResultModel *result = self.results[indexPath.row];
    self.playersContextViewModel.resultYearId = result.year;
    self.playersContextViewModel.gameType = result.type;
    
    [self.delegate playersResultSelected:self];
}


@end
