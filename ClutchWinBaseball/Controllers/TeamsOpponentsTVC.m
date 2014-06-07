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

- (void) setNotifyText{
    
    if([self.opponents count] == 0){
        [self.notifyLabel setText:@"select a team first"];
    } else {
        [self.notifyLabel setText:@""];
    }
}

- (void)refresh
{

    if ( [self needsToLoadData] && ![self.teamsContextViewModel.lastOpponentFilterFranchiseId
                                         isEqualToString:self.teamsContextViewModel.franchiseId]) {
        
        [self.teamsContextViewModel setLastOpponentFilterFranchiseId:self.teamsContextViewModel.franchiseId ];
        
        // Update the view.
        [self filterOpponentList];
    }
    
    [self setNotifyText];
}

- (BOOL) needsToLoadData {
    
    //check for empty and nil
    if ([self.teamsContextViewModel.lastOpponentFilterFranchiseId length] == 0) {
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
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
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
