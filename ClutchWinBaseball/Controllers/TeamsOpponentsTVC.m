//
//  OpponentsTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-18.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "TeamsOpponentsTVC.h"
#import "FranchiseModel.h"

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

- (void)refresh
{
    if ([self.opponents count] == 0 || ![self.teamsContextViewModel.lastOpponentFilterFranchiseId
                                         isEqualToString:self.teamsContextViewModel.franchiseId]) {
        
        [self.teamsContextViewModel setLastOpponentFilterFranchiseId:self.teamsContextViewModel.franchiseId ];
        
        // Update the view.
        [self filterOpponentList];
    }
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

    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.opponents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    FranchiseModel *franchise = self.opponents[indexPath.row];
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
    FranchiseModel *franchise = self.opponents[indexPath.row];
    [self.teamsContextViewModel recordOpponentId:franchise.retroId];
    
    [self.delegate teamsOpponentSelected:self];
}



@end
