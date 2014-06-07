//
//  PlayersBattersTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "ServiceEndpointHub.h"

#import "PlayersBattersTVC.h"
#import "BatterModel.h"
#import "CWBConfiguration.h"

@interface PlayersBattersTVC ()

@property (nonatomic, strong) NSMutableArray *batters;

@end

@implementation PlayersBattersTVC

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
        // if PlayersBattersTVC is recreated load from core data
        if( [self.batters count] == 0 ) {

            NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
            NSEntityDescription *entityDescription = [NSEntityDescription
                                                      entityForName:@"Batter" inManagedObjectContext:managedObjectContext];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            
            NSError *error = nil;
            NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
            
            if(!error && [results count] != 0){
                [self readyTheArray];
                
                for(BatterModel *result in results) {
                    if( result.batterIdValue != nil){
                        [self.batters addObject:result];
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
    // http://clutchwin.com/api/v1/players.json?
    // &access_token=abc&team_abbr=BAL&season=2013
    NSString *batterSearchEndpoint = [NSString stringWithFormat:@"%1$@&team_abbr=%2$@&season=%3$@",
                                      [CWBConfiguration batterSearchUrl],
                                      self.playersContextViewModel.teamId,
                                      self.playersContextViewModel.yearId];
    
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
                                                  [self.playersContextViewModel recordLastTeamId:self.playersContextViewModel.teamId ];
                                                  [spinner stopAnimating];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load batters failed with exception': %@", error);
                                                  }
                                                  [spinner stopAnimating];
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
    self.playersContextViewModel.batterId = batter.batterIdValue;
    
    [self.delegate playersBatterSelected:self];
}


@end