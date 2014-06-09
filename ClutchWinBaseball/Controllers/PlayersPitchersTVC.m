//
//  PlayersPitchersTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "ServiceEndpointHub.h"

#import "PlayersPitchersTVC.h"
#import "PitcherModel.h"
#import "CWBConfiguration.h"

@interface PlayersPitchersTVC ()

@property BOOL isLoading;
@property (nonatomic, strong) NSMutableArray *pitchers;

@end

@implementation PlayersPitchersTVC

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
        
        self.isLoading = YES;
        [self readyTheArray];
        [self loadResults];
        
    } else {
        // if PlayersPitchersTVC is recreated load from core data
        if( [self.pitchers count] == 0 ) {

            NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
            NSEntityDescription *entityDescription = [NSEntityDescription
                                                      entityForName:@"Pitcher" inManagedObjectContext:managedObjectContext];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            
            NSSortDescriptor * sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
            [request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
            
            NSError *error = nil;
            NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
            
            if(!error && [results count] != 0){
                [self readyTheArray];
                
                for(PitcherModel *result in results) {
                    if( result.retroId != nil){
                        [self.pitchers addObject:result];
                    }
                }
                [self.collectionView reloadData];
            } else {
                
                if ([self serviceCallAllowed]) {
                    [self readyTheArray];
                    [self loadResults];
                }
            }
        }
        
        [self setNotifyText:NO:NO];
    }
}

- (void) setNotifyText: (BOOL) service : (BOOL) error {
    
    if(error){
        [self.notifyLabel setText:@"an error has occured"];
    } else if (service) {
        if([self.pitchers count] == 0){
            [self.notifyLabel setText:@"no results found"];
        } else {
            [self.notifyLabel setText:@""];
        }
    } else {
        if([self.pitchers count] == 0){
            [self.notifyLabel setText:@"select a batter first"];
        } else {
            [self.notifyLabel setText:@""];
        }
    }
}

- (void)loadResults
{
    // http://clutchwin.com/api/v1/opponents/pitchers.json?
    // &access_token=abc&bat_id=aybae001&season=2013&fieldset=basic
    NSString *pitcherSearchEndpoint = [NSString stringWithFormat:@"%1$@&bat_id=%2$@&season=%3$@",
                                      [CWBConfiguration pitcherSearchUrl],
                                      self.playersContextViewModel.batterId,
                                      self.playersContextViewModel.yearId];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:pitcherSearchEndpoint
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  NSArray *sorted = [mappingResult.array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                                                      NSString *first = [(PitcherModel*)a firstName];
                                                      NSString *second = [(PitcherModel*)b firstName];
                                                      return [first compare:second];
                                                  }];
                                                  
                                                  self.pitchers = [sorted mutableCopy];
                                                  [self.collectionView reloadData];
                                                  [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                                                  [self.playersContextViewModel recordLastBatterId:self.playersContextViewModel.batterId];
                                                  
                                                  [spinner stopAnimating];
                                                  [self setNotifyText:YES:NO];
                                                  self.isLoading = NO;
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load pitchers failed with exception': %@", error);
                                                  }
                                                  [spinner stopAnimating];
                                                  [self setNotifyText:YES:YES];
                                                  self.isLoading = NO;
                                              }];
}

#pragma mark - Helper methods
- (BOOL) serviceCallAllowed {
    
    //check for empty and nil
    if ([self.playersContextViewModel.yearId length] == 0 || [self.playersContextViewModel.batterId length] == 0) {
        return NO;
    }
    return YES;
}

- (BOOL) needsToLoadData {

    if ([self serviceCallAllowed]) {
        if (![self.playersContextViewModel.batterId isEqualToString:self.playersContextViewModel.lastBatterId]) {
            return YES;
        }
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

#pragma mark - UICollection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pitchers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UILabel *displayText = (UILabel *)[cell viewWithTag:100];
    PitcherModel *pitcher = self.pitchers[indexPath.row];
    displayText.text = [pitcher displayName];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isLoading) {
        PitcherModel *pitcher = self.pitchers[indexPath.row];
        self.playersContextViewModel.pitcherId = pitcher.retroId;
        
        [self.delegate playersPitcherSelected:self];
    }
}

@end