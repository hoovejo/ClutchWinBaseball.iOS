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
#import "CWBText.h"

@interface PlayersYearsTVC ()

@end

@implementation PlayersYearsTVC

- (void)viewDidLoad
{
    [self setNotifyText:@""];
    
    if(self.playersContextViewModel.hasLoadedSeasonsOncePerSession == NO){
        
        [self loadYears];
        [self.playersContextViewModel setLoadedOnce];
        
    } else if( [self.years count] == 0 ) {
        // if PlayersYearsTVC is recreated load from core data
        NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"Season" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSSortDescriptor * sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"yearValue" ascending:NO];
        [request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
        NSError *error = nil;
        NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
        
        if(!error && [results count] != 0){
            self.years = results;
            [self.collectionView reloadData];
        } else {
            [self loadYears];
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

- (void) setNotifyText: (NSString *) msg {
    [self.notifyLabel setText:msg];
}

- (void)loadYears
{
    BOOL isNetworkAvailable = [ServiceEndpointHub getIsNetworkAvailable];
    
    if (!isNetworkAvailable) {
        NSString *msg = [CWBText networkMessage];
        [self setNotifyText:msg];
        return;
    }
    
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
                                                  [self.collectionView reloadData];
                                                  [spinner stopAnimating];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load years failed with exception': %@", error);
                                                  }
                                                  [spinner stopAnimating];
                                                  NSString *msg = [CWBText errorMessage];
                                                  [self setNotifyText:msg];
                                              }];
}

#pragma mark - UICollection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.years.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UILabel *displayText = (UILabel *)[cell viewWithTag:100];
    YearModel *year = self.years[indexPath.row];
    displayText.text = year.yearValue;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YearModel *year = self.years[indexPath.row];
    self.playersContextViewModel.yearId = year.yearValue;
    
    [self.delegate playersYearSelected:self];
    
    [self performSegueWithIdentifier:@"SeasonsUnwind" sender:self];
}

@end