//
//  PlayersDrillDownTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "ServiceEndpointHub.h"

#import "PlayersDrillDownTVC.h"
#import "PlayersDrillDownModel.h"
#import "PlayersDrillDownTableViewCell.h"
#import "CWBConfiguration.h"
#import "CWBText.h"

@interface PlayersDrillDownTVC ()

@property (nonatomic, strong) NSMutableArray *results;

@end

@implementation PlayersDrillDownTVC

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

    [self setNotifyText:@""];
    
    if ([self needsToLoadData]) {
        
        [self readyTheArray];
        [self loadResults];
        
    } else {
        // if PlayersDrillDownTVC is recreated load from core data
        if( [self.results count] == 0 ) {

            NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
            NSEntityDescription *entityDescription = [NSEntityDescription
                                                      entityForName:@"PlayersDrillDown" inManagedObjectContext:managedObjectContext];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            
            NSSortDescriptor * sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"gameDate" ascending:NO];
            [request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
            
            NSError *error = nil;
            NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
            
            if(!error && [results count] != 0){
                [self readyTheArray];
                
                for(PlayersDrillDownModel *result in results) {
                    if( result.gameDate != nil){
                        [self.results addObject:result];
                    }
                }
                [self.collectionView reloadData];
            } else {
                
                if ([self serviceCallAllowed]) {
                    [self readyTheArray];
                    [self loadResults];
                } else {
                    //if svc call not allowed prereq's not met
                    NSString *msg = [CWBText selectResult];
                    [self setNotifyText:msg];
                }
            }
        }
    }
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
    
    RKManagedObjectStore *managedObjectStore = [ServiceEndpointHub getManagedObjectStore];
    RKResponseDescriptor *responseDescriptor = [ServiceEndpointHub buildPlayersDrillDown:managedObjectStore];
    
    //@"/search/player_vs_player_by_year/aybae001/parkj001/2013/regular.json"
    NSString *playersDrillDownEndpoint = [NSString stringWithFormat:@"%1$@%2$@&bat_id=%3$@&pit_id=%4$@&season=%5$@",
                                          [CWBConfiguration baseUrlString],
                                          [CWBConfiguration playerDrillDownUrl],
                                          self.playersContextViewModel.batterId,
                                          self.playersContextViewModel.pitcherId,
                                          self.playersContextViewModel.resultYearId];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:playersDrillDownEndpoint]];
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    
    operation.managedObjectContext = managedObjectStore.mainQueueManagedObjectContext;
    operation.managedObjectCache = managedObjectStore.managedObjectCache;
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

        NSArray *sorted = [mappingResult.array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *first = [(PlayersDrillDownModel*)a gameDate];
            NSString *second = [(PlayersDrillDownModel*)b gameDate];
            return [second compare:first];
        }];
        
        self.results = [sorted mutableCopy];
        [self.collectionView reloadData];
        [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [self.playersContextViewModel recordLastDrillDownIds : self.playersContextViewModel.batterId
                                                             : self.playersContextViewModel.pitcherId
                                                             : self.playersContextViewModel.resultYearId];
        [spinner stopAnimating];

        if([self.results count] == 0){
            NSString *msg = [CWBText noResults];
            [self setNotifyText:msg];
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if ([CWBConfiguration isLoggingEnabled]){
            NSLog(@"Load player details failed with exception': %@", error);
        }
        [spinner stopAnimating];

        NSString *msg = [CWBText errorMessage];
        [self setNotifyText:msg];
    }];

    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operation];
}

#pragma mark - Helper methods
- (BOOL) serviceCallAllowed {
    
    //check for empty and nil
    if ([self.playersContextViewModel.batterId length] == 0 || [self.playersContextViewModel.pitcherId length] == 0 || [self.playersContextViewModel.resultYearId length] == 0) {
        return NO;
    }
    return YES;
}

- (BOOL) needsToLoadData {

    if ([self serviceCallAllowed]) {
        if (![self.playersContextViewModel.batterId isEqualToString:self.playersContextViewModel.lastDrillDownBatterId]) {
            return YES;
        }
        
        if (![self.playersContextViewModel.pitcherId isEqualToString:self.playersContextViewModel.lastDrillDownPitcherId]) {
            return YES;
        }
        
        if (![self.playersContextViewModel.resultYearId isEqualToString:self.playersContextViewModel.lastDrillDownYearId]) {
            return YES;
        }
    }
    return NO;
}

- (void) readyTheArray {
    if( [self.results count] == 0 ){
        self.results = [[NSMutableArray alloc] init];
    } else {
        [self.results removeAllObjects];
    }
}

#pragma mark - UICollection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.results.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"PlayersDrillDownTableViewCell";
    
    PlayersDrillDownTableViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PlayersDrillDownModel *result = self.results[indexPath.row];
    
    cell.gameDateLabel.text = result.gameDate;
    cell.atBatLabel.text = result.atBat;
    cell.hitLabel.text = result.hit;
    cell.walkLabel.text = result.walks;
    cell.strikeOutLabel.text = result.strikeOut;
    cell.secondBaseLabel.text = result.secondBase;
    cell.thirdBaseLabel.text = result.thirdBase;
    cell.homeRunLabel.text = result.homeRun;
    cell.runBattedInLabel.text = result.runBattedIn;
    
    int hitValue = [result.hit intValue];
    if(hitValue <= 0){
        cell.averageLabel.text = @"0.000";
    } else {
        double val = (float)hitValue / (float)[result.atBat intValue];
        cell.averageLabel.text = [NSString localizedStringWithFormat:@"%.3f", (val)];;
    }
    
    return cell;
}

@end
