//
//  TeamsTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-18.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

#import "TeamsFranchisesTVC.h"
#import "FranchiseModel.h"
#import "CWBConfiguration.h"
#import "ServiceEndpointHub.h"

@interface TeamsFranchisesTVC ()

@end

@implementation TeamsFranchisesTVC

- (void)viewDidLoad
{
    if(self.teamsContextViewModel.hasLoadedFranchisesOncePerSession == NO){
        [self loadFranchises];
    } else if( [self.franchises count] == 0 ) {

        NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"Franchise" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSError *error = nil;
        NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
        
        if(!error){
            self.franchises = results;
            [self.tableView reloadData];
        } else {
            [self loadFranchises];
        }
        
        [self.teamsContextViewModel setLoadedOnce];
    }

    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loading controller

- (void)loadFranchises
{
    // http://clutchwin.com/api/v1/franchises.json?
    // &access_token=abc
    NSString *franchisesEndpoint = [CWBConfiguration franchiseUrl];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:franchisesEndpoint
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  self.franchises = mappingResult.array;
                                                  [self.tableView reloadData];
                                                  [spinner stopAnimating];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load franchises failed with exception': %@", error);
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
    return self.franchises.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    FranchiseModel *franchise = self.franchises[indexPath.row];
    cell.textLabel.text = [franchise displayName];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FranchiseModel *franchise = self.franchises[indexPath.row];
    [self.teamsContextViewModel recordFranchiseId:franchise.retroId];
    
    [self.delegate teamsFranchiseSelected:self];
}


@end
