//
//  PlayersResultsTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "ServiceEndpointHub.h"

#import "PlayersResultsTVC.h"
#import "PlayersResultModel.h"
#import "PlayersResultsTableViewCell.h"
#import "CWBConfiguration.h"
#import "CWBText.h"

@interface PlayersResultsTVC ()

@property BOOL isLoading;
@property (nonatomic, strong) NSMutableArray *results;

@end

@implementation PlayersResultsTVC

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
        [self.collectionView reloadData];
        [self loadResults];
        
    } else if (![self serviceCallAllowed]){
        //if svc call not allowed prereq's not met
        NSString *msg = [CWBText selectPitcher];
        [self setNotifyText:msg];
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
    
    //RKManagedObjectStore *managedObjectStore = [ServiceEndpointHub getManagedObjectStore];
    RKResponseDescriptor *responseDescriptor = [ServiceEndpointHub buildPlayersResults];
    
    //@"/search/player_vs_player/aybae001/parkj001.json"
    NSString *playerResultsEndpoint = [NSString stringWithFormat:@"%1$@%2$@&bat_id=%3$@&pit_id=%4$@",
                                       [CWBConfiguration baseUrlString],
                                       [CWBConfiguration playerResultsUrl],
                                       self.playersContextViewModel.batterId,
                                       self.playersContextViewModel.pitcherId];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = self.view.center;
    spinner.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    spinner.center = self.view.center;
    spinner.hidesWhenStopped = YES;
    if ([spinner respondsToSelector:@selector(setColor:)]) {
        [spinner setColor:[UIColor grayColor]];
    }
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:playerResultsEndpoint]];
    
    //RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    
    //operation.managedObjectContext = managedObjectStore.mainQueueManagedObjectContext;
    //operation.managedObjectCache = managedObjectStore.managedObjectCache;
    
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        NSArray *sorted = [mappingResult.array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *first = [(PlayersResultModel*)a year];
            NSString *second = [(PlayersResultModel*)b year];
            return [second compare:first];
        }];
        
        self.results = [sorted mutableCopy];
        [self.collectionView reloadData];
        [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [self.playersContextViewModel recordLastSearchIds:self.playersContextViewModel.batterId :self.playersContextViewModel.pitcherId ];
        
        [spinner stopAnimating];

        if([self.results count] == 0){
            NSString *msg = [CWBText noResults];
            [self setNotifyText:msg];
        }
        
        self.isLoading = NO;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if ([CWBConfiguration isLoggingEnabled]){
            NSLog(@"Load player results failed with exception': %@", error);
        }
        [spinner stopAnimating];

        NSString *msg = [CWBText errorMessage];
        [self setNotifyText:msg];
        
        self.isLoading = NO;
    }];
    
    self.isLoading = YES;

    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operation];
}

#pragma mark - Helper methods
- (BOOL) serviceCallAllowed {
    
    if(self.isLoading) { return NO; }
    
    //check for empty and nil
    if ([self.playersContextViewModel.batterId length] == 0 || [self.playersContextViewModel.pitcherId length] == 0) {
        return NO;
    }
    return YES;
}

- (BOOL) needsToLoadData {

    if ([self serviceCallAllowed]) {
        if (![self.playersContextViewModel.batterId isEqualToString:self.playersContextViewModel.lastSearchBatterId]) {
            return YES;
        }
        
        if (![self.playersContextViewModel.pitcherId isEqualToString:self.playersContextViewModel.lastSearchPitcherId]) {
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

    static NSString *CellIdentifier = @"PlayersResultsTableViewCell";
    
    PlayersResultsTableViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PlayersResultModel *result = self.results[indexPath.row];
    
    cell.yearLabel.text = result.year;
    cell.gamesLabel.text = result.games;
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
        cell.averageLabel.text = @".000";
    } else {
        double val = (float)hitValue / (float)[result.atBat intValue];
        
        NSString *valAsString = [NSString localizedStringWithFormat:@"%.3f", (val)];
        NSRange range = [valAsString rangeOfString:@"^0*" options:NSRegularExpressionSearch];
        valAsString = [valAsString stringByReplacingCharactersInRange:range withString:@""];
        cell.averageLabel.text = valAsString;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isLoading) {
        PlayersResultModel *result = self.results[indexPath.row];
        self.playersContextViewModel.resultYearId = result.year;
        
        [self.delegate playersResultSelected:self];
    }
}


@end
