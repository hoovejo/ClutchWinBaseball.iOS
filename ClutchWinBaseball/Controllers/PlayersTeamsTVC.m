//
//  PlayersTeamsTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "PlayersTeamsTVC.h"
#import "TeamModel.h"
#import "CWBConfiguration.h"

@interface PlayersTeamsTVC ()

@property (nonatomic, strong) NSMutableArray *teams;

@end

@implementation PlayersTeamsTVC

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
    //@"/teams/2012.json"
    NSString *teamSearchEndpoint = [NSString stringWithFormat:@"%1$@%2$@%3$@",
                                      [CWBConfiguration teamSearchUrl],
                                      self.playersContextViewModel.yearId,
                                      [CWBConfiguration jsonSuffix]];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:teamSearchEndpoint
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  self.teams = [mappingResult.array mutableCopy];
                                                  [self.tableView reloadData];
                                                  [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                                                  [self.playersContextViewModel recordLastYearId];
                                                  [spinner stopAnimating];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load teams failed with exception': %@", error);
                                                  }
                                              }];
}

#pragma mark - Helper methods
- (BOOL) needsToLoadData {
    
    if (![self.playersContextViewModel.yearId isEqualToString:self.playersContextViewModel.lastYearId]) {
        return YES;
    }
   
    return NO;
}

- (void) readyTheArray {
    if( [self.teams count] == 0 ){
        self.teams = [[NSMutableArray alloc] init];
    } else {
        [self.teams removeAllObjects];
    }
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.teams.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    TeamModel *team = self.teams[indexPath.row];
    cell.textLabel.text = [team displayName];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamModel *team = self.teams[indexPath.row];
    self.playersContextViewModel.teamId = team.teamId;
    
    [self.delegate playersTeamSelected:self];
}


@end
