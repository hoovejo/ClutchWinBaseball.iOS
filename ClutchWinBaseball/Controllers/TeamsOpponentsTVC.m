//
//  OpponentsTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-18.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "TeamsOpponentsTVC.h"
#import "FranchiseModel.h"
#import "CWBText.h"

@interface TeamsOpponentsTVC ()

@property (nonatomic, strong) NSMutableArray *opponents;

@end

@implementation TeamsOpponentsTVC

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

- (void) setNotifyText: (NSString *) msg {
    [self.notifyLabel setText:msg];
}

- (void)refresh
{
    [self setNotifyText:@""];

    if ( [self needsToLoadData] && ![self.teamsContextViewModel.lastOpponentFilterFranchiseId
                                         isEqualToString:self.teamsContextViewModel.franchiseId]) {
        
        [self.teamsContextViewModel setLastOpponentFilterFranchiseId:self.teamsContextViewModel.franchiseId ];
        
        // Update the view.
        [self filterOpponentList];
    } else {
        //prereq's not met
        NSString *msg = [CWBText selectTeam];
        [self setNotifyText:msg];
    }
}

- (BOOL) needsToLoadData {
    
    //check for empty and nil
    if ([self.teamsContextViewModel.franchiseId length] == 0) {
        return NO;
    }
    return YES;
}

- (void)filterOpponentList
{
    if( [self.opponents count] == 0 ){
        self.opponents = [[NSMutableArray alloc] init];
    } else {
        [self.opponents removeAllObjects];
    }
    
    for(FranchiseModel *franchise in self.franchises) {
        if( ![franchise.retroId isEqualToString:self.teamsContextViewModel.franchiseId]){
            [self.opponents addObject:franchise];
        }
    }
    
    [self.collectionView reloadData];
    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    if([self.opponents count] == 0){
        NSString *msg = [CWBText noResults];
        [self setNotifyText:msg];
    }
}

#pragma mark - UICollection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.opponents.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UILabel *displayText = (UILabel *)[cell viewWithTag:100];
    FranchiseModel *franchise = self.opponents[indexPath.row];
    displayText.text = [franchise displayName];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FranchiseModel *franchise = self.opponents[indexPath.row];
    [self.teamsContextViewModel recordOpponentId:franchise.retroId];
    
    [self.delegate teamsOpponentSelected:self];
}


@end
