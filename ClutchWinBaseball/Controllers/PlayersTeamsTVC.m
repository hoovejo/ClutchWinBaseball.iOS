//
//  PlayersTeamsTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "ServiceEndpointHub.h"

#import "PlayersTeamsTVC.h"
#import "TeamModel.h"
#import "CWBConfiguration.h"
#import "CWBText.h"

@interface PlayersTeamsTVC ()

@property (nonatomic, strong) NSMutableArray *teams;

@end

@implementation PlayersTeamsTVC

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
  
    [self setNotifyText:@""];
    
    if ([self needsToLoadData]) {
        
        [self readyTheArray];
        [self loadResults];
        
    } else if (![self serviceCallAllowed]){
        //if svc call not allowed prereq's not met
        NSString *msg = [CWBText selectSeason];
        [self setNotifyText:msg];
    }
    
    /*
    if ([self needsToLoadData]) {
        
        [self readyTheArray];
        [self loadResults];
        
    } else {
        // if PlayersTeamsTVC is recreated load from core data
        if( [self.teams count] == 0 ) {

            NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
            NSEntityDescription *entityDescription = [NSEntityDescription
                                                      entityForName:@"Team" inManagedObjectContext:managedObjectContext];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            
            NSSortDescriptor * sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"location" ascending:YES];
            [request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
            
            NSError *error = nil;
            NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
            
            if(!error && [results count] != 0){
                [self readyTheArray];
                
                for(TeamModel *result in results) {
                    if( result.teamIdValue != nil){
                        [self.teams addObject:result];
                    }
                }
                [self.collectionView reloadData];
            } else {
                
                if ([self serviceCallAllowed]) {
                    [self readyTheArray];
                    [self loadResults];
                } else {
                    //if svc call not allowed prereq's not met
                    NSString *msg = [CWBText selectSeason];
                    [self setNotifyText:msg];
                }
            }
        }
    }
     */
}

- (void) setNotifyText: (NSString *) msg {
    [self.notifyLabel setText:msg];
}

- (void)loadResults
{
    BOOL isNetworkAvailable = [ServiceEndpointHub getIsNetworkAvailable];
    
    if (!isNetworkAvailable) {
        NSString *msg = [CWBText networkMessage];
        [self setNotifyText:msg];
        return;
    }
    
    // http://clutchwin.com/api/v1/teams.json?
    // &access_token=abc&season=2013
    NSString *teamSearchEndpoint = [NSString stringWithFormat:@"%1$@&season=%2$@",
                                      [CWBConfiguration teamSearchUrl],
                                      self.playersContextViewModel.yearId];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:teamSearchEndpoint
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  NSArray *sorted = [mappingResult.array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                                                      NSString *first = [(TeamModel*)a location];
                                                      NSString *second = [(TeamModel*)b location];
                                                      return [first compare:second];
                                                  }];
                                                  
                                                  self.teams = [sorted mutableCopy];
                                                  [self.collectionView reloadData];
                                                  [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                                                  [self.playersContextViewModel recordLastYearId:self.playersContextViewModel.yearId];
                                                  
                                                  [spinner stopAnimating];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load teams failed with exception': %@", error);
                                                  }
                                                  [spinner stopAnimating];
                                                  NSString *msg = [CWBText errorMessage];
                                                  [self setNotifyText:msg];
                                              }];
}

#pragma mark - Helper methods
- (BOOL) serviceCallAllowed {
    
    //check for empty and nil
    if ([self.playersContextViewModel.yearId length] == 0) {
        return NO;
    }
    return YES;
}

- (BOOL) needsToLoadData {

    if ([self serviceCallAllowed]) {
        if (![self.playersContextViewModel.yearId isEqualToString:self.playersContextViewModel.lastYearId]) {
            return YES;
        }
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

#pragma mark - UICollection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.teams.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UILabel *displayText = (UILabel *)[cell viewWithTag:100];
    TeamModel *team = self.teams[indexPath.row];
    displayText.text = [team displayName];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TeamModel *team = self.teams[indexPath.row];
    self.playersContextViewModel.teamId = team.teamIdValue;
    
    [self.delegate playersTeamSelected:self];
    
    [self performSegueWithIdentifier:@"TeamsUnwind" sender:self];
}



@end
