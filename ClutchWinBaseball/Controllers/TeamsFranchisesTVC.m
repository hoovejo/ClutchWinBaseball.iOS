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
    [self setNotifyText:NO];
    
    if(self.teamsContextViewModel.hasLoadedFranchisesOncePerSession == NO){
        
        [self loadFranchises];
        [self.teamsContextViewModel setLoadedOnce];
        
    } else if ( [self.franchises count] == 0 ) {

        NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"Franchise" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSSortDescriptor * sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"location" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
        NSError *error = nil;
        NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
        
        if(!error){
            self.franchises = results;
            [self.collectionView reloadData];
        } else {
            [self loadFranchises];
        }
    }

    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loading controller

- (void) setNotifyText: (BOOL) error {
    
    if(error){
        [self.notifyLabel setText:@"an error has occured"];
    } else {
        [self.notifyLabel setText:@""];
    }
}

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
                                                  
                                                  self.franchises = [mappingResult.array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                                                      NSString *first = [(FranchiseModel*)a location];
                                                      NSString *second = [(FranchiseModel*)b location];
                                                      return [first compare:second];
                                                  }];

                                                  [self.collectionView reloadData];
                                                  [spinner stopAnimating];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load franchises failed with exception': %@", error);
                                                  }
                                                  [spinner stopAnimating];
                                                  [self setNotifyText:YES];
                                              }];
}

#pragma mark - UICollection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.franchises.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UILabel *displayText = (UILabel *)[cell viewWithTag:100];
    FranchiseModel *franchise = self.franchises[indexPath.row];
    displayText.text = [franchise displayName];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FranchiseModel *franchise = self.franchises[indexPath.row];
    [self.teamsContextViewModel recordFranchiseId:franchise.retroId];
    
    [self.delegate teamsFranchiseSelected:self];
}


@end
