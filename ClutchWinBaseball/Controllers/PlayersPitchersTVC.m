//
//  PlayersPitchersTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "PlayersPitchersTVC.h"
#import "PitcherModel.h"
#import "CWBConfiguration.h"

@interface PlayersPitchersTVC ()

@property (nonatomic, strong) NSMutableArray *pitchers;

@end

@implementation PlayersPitchersTVC

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
    //@"/search/opponents_for_batter/aybae001/2013.json"
    NSString *pitcherSearchEndpoint = [NSString stringWithFormat:@"%1$@%2$@/%3$@%4$@",
                                      [CWBConfiguration pitcherSearchUrl],
                                      self.playersContextViewModel.batterId,
                                      self.playersContextViewModel.yearId,
                                      [CWBConfiguration jsonSuffix]];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:pitcherSearchEndpoint
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  self.pitchers = [mappingResult.array mutableCopy];
                                                  [self.tableView reloadData];
                                                  [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                                                  [self.playersContextViewModel recordLastBatterId];
                                                  [spinner stopAnimating];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load pitchers failed with exception': %@", error);
                                                  }
                                              }];
}

#pragma mark - Helper methods
- (BOOL) needsToLoadData {
    
    if (![self.playersContextViewModel.batterId isEqualToString:self.playersContextViewModel.lastBatterId]) {
        return YES;
    }
    
    return NO;
}

- (void) readyTheArray {
    if( [self.pitchers count] == 0 ){
        self.pitchers = [[NSMutableArray alloc] init];
    } else {
        [self.pitchers removeAllObjects];
    }
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pitchers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    PitcherModel *pitcher = self.pitchers[indexPath.row];
    cell.textLabel.text = [pitcher displayName];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PitcherModel *pitcher = self.pitchers[indexPath.row];
    self.playersContextViewModel.pitcherId = pitcher.retroId;
    
    [self.delegate playersPitcherSelected:self];
}


@end