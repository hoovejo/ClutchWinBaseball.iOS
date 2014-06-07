//
//  PlayersYearsTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "ServiceEndpointHub.h"

#import "PlayersYearsTVC.h"
#import "YearModel.h"
#import "CWBConfiguration.h"

@interface PlayersYearsTVC ()

@end

@implementation PlayersYearsTVC

- (void)viewDidLoad
{
    if(self.playersContextViewModel.hasLoadedSeasonsOncePerSession == NO){
        
        [self loadYears];
        
    } else if( [self.years count] == 0 ) {
        // if PlayersYearsTVC is recreated load from core data
        NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"Season" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSError *error = nil;
        NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
        
        if(!error && [results count] != 0){
            self.years = results;
            [self.tableView reloadData];
        } else {
            [self loadYears];
        }
        
        [self.playersContextViewModel setLoadedOnce];
    }
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loading controller

- (void)loadYears
{
    // http://clutchwin.com/api/v1/seasons.json?
    // &access_token=abc
    NSString *yearsEndpoint = [CWBConfiguration yearUrl];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:yearsEndpoint
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  self.years = mappingResult.array;
                                                  [self.tableView reloadData];
                                                  [spinner stopAnimating];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load years failed with exception': %@", error);
                                                  }
                                                  [spinner stopAnimating];
                                              }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.years.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    YearModel *year = self.years[indexPath.row];
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
    YearModel *year = self.years[indexPath.row];
    self.playersContextViewModel.yearId = year.yearValue;
    
    [self.delegate playersYearSelected:self];
    
    [self performSegueWithIdentifier:@"SeasonsUnwind" sender:self];
}


@end