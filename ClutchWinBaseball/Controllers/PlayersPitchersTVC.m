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
#import "CWBText.h"

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
    
    [self setNotifyText:@""];
    
    if ([self needsToLoadData]) {

        [self readyTheArray];
        [self.collectionView reloadData];
        [self loadResults];
        
    } else if (![self serviceCallAllowed]){
        //if svc call not allowed prereq's not met
        NSString *msg = [CWBText selectBatter];
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
    
    // http://clutchwin.com/api/v1/opponents/pitchers.json?
    // &access_token=abc&bat_id=aybae001&season=2013&fieldset=basic
    NSString *pitcherSearchEndpoint = [NSString stringWithFormat:@"%1$@&bat_id=%2$@&season=%3$@",
                                      [CWBConfiguration pitcherSearchUrl],
                                      self.playersContextViewModel.batterId,
                                      self.playersContextViewModel.yearId];
    
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

                                                  if([self.pitchers count] == 0){
                                                      NSString *msg = [CWBText noResults];
                                                      [self setNotifyText:msg];
                                                  }
                                                  
                                                  self.isLoading = NO;
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load pitchers failed with exception': %@", error);
                                                  }
                                                  [spinner stopAnimating];

                                                  NSString *msg = [CWBText errorMessage];
                                                  [self setNotifyText:msg];
                                                  
                                                  self.isLoading = NO;
                                                  
                                                  [ServiceEndpointHub reportNetworkError:error:@"Load pitchers failed with exception" ];
                                              }];
}

#pragma mark - Helper methods
- (BOOL) serviceCallAllowed {
    
    if(self.isLoading) { return NO; }
    
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