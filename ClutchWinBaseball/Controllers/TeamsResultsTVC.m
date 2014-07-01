//
//  TeamsResultsTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-19.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "TeamsResultsTVC.h"
#import "TeamsResultModel.h"
#import "TeamsResultsTableViewCell.h"
#import "CWBConfiguration.h"
#import "CWBText.h"
#import "ServiceEndpointHub.h"

@interface TeamsResultsTVC ()

@property BOOL isLoading;
@property (nonatomic, strong) NSMutableArray *results;

@end

@implementation TeamsResultsTVC

- (void)viewDidLoad
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processDoubleTap:)];
        [doubleTapGesture setNumberOfTapsRequired:2];
        [doubleTapGesture setNumberOfTouchesRequired:1];
        
        [self.view addGestureRecognizer:doubleTapGesture];
        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processSingleTap:)];
        [singleTapGesture setNumberOfTapsRequired:1];
        [singleTapGesture setNumberOfTouchesRequired:1];
        [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
        
        [self.view addGestureRecognizer:singleTapGesture];
    }
    
    [self refresh];
    [super viewDidLoad];
}

- (void) processDoubleTap: (UITapGestureRecognizer *)recognizer
{
    if (!self.isLoading) {
        CGPoint p = [recognizer locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
        TeamsResultModel *result = self.results[indexPath.row];
        self.teamsContextViewModel.yearId = result.year;
        
        [self.delegate teamsResultSelected:self];
    }
}

- (void) processSingleTap: (UITapGestureRecognizer *)recognizer
{
    if (!self.isLoading) {
        CGPoint p = [recognizer locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
        TeamsResultModel *result = self.results[indexPath.row];
        self.teamsContextViewModel.yearId = result.year;
        
        [self.delegate teamsResultSelected:self];
    }
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
        NSString *msg = [CWBText selectOpponent];
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
    
    // http://clutchwin.com/api/v1/games/for_team/summary.json?
    // &access_token=abc&franchise_abbr=TOR&opp_franchise_abbr=BAL&group=season,team_abbr,opp_abbr&fieldset=basic
    NSString *teamsResultsEndpoint = [NSString stringWithFormat:@"%1$@&franchise_abbr=%2$@&opp_franchise_abbr=%3$@",
                                      [CWBConfiguration franchiseSearchUrl],
                                      self.teamsContextViewModel.franchiseId,
                                      self.teamsContextViewModel.opponentId];
    
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

    self.isLoading = YES;

    [[RKObjectManager sharedManager] getObjectsAtPath:teamsResultsEndpoint
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  NSArray *sorted = [mappingResult.array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                                                      NSString *first = [(TeamsResultModel*)a year];
                                                      NSString *second = [(TeamsResultModel*)b year];
                                                      return [second compare:first];
                                                  }];
                                                  
                                                  self.results = [sorted mutableCopy];
                                                  [self.collectionView reloadData];
                                                  [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                                                  [self.teamsContextViewModel recordLastSearchIds];
                                                  
                                                  [spinner stopAnimating];
                                                  
                                                  if([self.results count] == 0){
                                                      NSString *msg = [CWBText noResults];
                                                      [self setNotifyText:msg];
                                                  }
                                                  
                                                  self.isLoading = NO;
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load franchise results failed with exception': %@", error);
                                                  }
                                                  [spinner stopAnimating];
                                                  
                                                  NSString *msg = [CWBText errorMessage];
                                                  [self setNotifyText:msg];
                                                  
                                                  self.isLoading = NO;
                                                  
                                                  [ServiceEndpointHub reportNetworkError:error:@"Load franchise results failed with exception" ];
                                              }];
}

#pragma mark - Helper methods
- (BOOL) serviceCallAllowed {
    
    if(self.isLoading) { return NO; }
    
    //check for empty and nil
    if ([self.teamsContextViewModel.franchiseId length] == 0 || [self.teamsContextViewModel.opponentId length] == 0) {
        return NO;
    }
    return YES;
}

- (BOOL) needsToLoadData {

    if ([self serviceCallAllowed]) {
        if (![self.teamsContextViewModel.franchiseId isEqualToString:self.teamsContextViewModel.lastSearchFranchiseId]) {
            return YES;
        }
    
        if (![self.teamsContextViewModel.opponentId isEqualToString:self.teamsContextViewModel.lastSearchOpponentId]) {
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

    static NSString *CellIdentifier = @"TeamsResultsTableViewCell";
    
    TeamsResultsTableViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    TeamsResultModel *result = self.results[indexPath.row];
    
    cell.yearLabel.text = result.year;
    cell.gamesLabel.text = [NSString stringWithFormat: @"%d", [result.wins intValue]+[result.losses intValue]];
    cell.teamLabel.text = result.team;
    cell.opponentLabel.text = result.opponent;
    cell.winsLabel.text = result.wins;
    cell.lossesLabel.text = result.losses;
    cell.runsForLabel.text = result.runsFor;
    cell.runsAgainstLabel.text = result.runsAgainst;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        if (!self.isLoading) {
            TeamsResultModel *result = self.results[indexPath.row];
            self.teamsContextViewModel.yearId = result.year;
        
            [self.delegate teamsResultSelected:self];
        }
    }
}

@end
