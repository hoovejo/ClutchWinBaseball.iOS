//
//  PlayersBattersTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "PlayersBattersTVC.h"
#import "BatterModel.h"
#import "CWBConfiguration.h"

@interface PlayersBattersTVC ()

@property (nonatomic, strong) NSMutableArray *batters;

@end

@implementation PlayersBattersTVC

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
    //@"/search/roster_for_team_and_year/ATL/2013.json"
    NSString *batterSearchEndpoint = [NSString stringWithFormat:@"%1$@%2$@/%3$@%4$@",
                                      [CWBConfiguration batterSearchUrl],
                                      self.playersContextViewModel.teamId,
                                      self.playersContextViewModel.yearId,
                                      [CWBConfiguration jsonSuffix]];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:batterSearchEndpoint
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  self.batters = [mappingResult.array mutableCopy];
                                                  [self.tableView reloadData];
                                                  [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                                                  [self.playersContextViewModel recordLastTeamId];
                                                  [spinner stopAnimating];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load batters failed with exception': %@", error);
                                                  }
                                              }];
}

#pragma mark - Helper methods
- (BOOL) needsToLoadData {
    
    if (![self.playersContextViewModel.teamId isEqualToString:self.playersContextViewModel.lastTeamId]) {
        return YES;
    }
    
    return NO;
}

- (void) readyTheArray {
    if( [self.batters count] == 0 ){
        self.batters = [[NSMutableArray alloc] init];
    } else {
        [self.batters removeAllObjects];
    }
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.batters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    BatterModel *batter = self.batters[indexPath.row];
    cell.textLabel.text = [batter displayName];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BatterModel *batter = self.batters[indexPath.row];
    self.playersContextViewModel.batterId = batter.retroPlayerId;
    
    [self.delegate playersBatterSelected:self];
}


@end