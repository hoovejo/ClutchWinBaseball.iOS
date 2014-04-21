//
//  PlayersYearsTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "PlayersYearsTVC.h"
#import "YearModel.h"
#import "CWBConfiguration.h"

@interface PlayersYearsTVC ()

@end

@implementation PlayersYearsTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if( [self.playersContextViewModel.years count] == 0 ) {
        [self loadYears];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loading controller

- (void)loadYears
{
    //@"/years.json"
    NSString *yearsEndpoint = [CWBConfiguration yearUrl];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:yearsEndpoint
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  self.playersContextViewModel.years = mappingResult.array;
                                                  [self.tableView reloadData];
                                                  [spinner stopAnimating];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load years failed with exception': %@", error);
                                                  }
                                              }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.playersContextViewModel.years.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    YearModel *year = self.playersContextViewModel.years[indexPath.row];
    cell.textLabel.text = year.yearValue;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YearModel *year = self.playersContextViewModel.years[indexPath.row];
    self.playersContextViewModel.yearId = year.yearValue;
    
    [self.delegate playersYearSelected:self];
}


@end