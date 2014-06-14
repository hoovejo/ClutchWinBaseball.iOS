//
//  PlayersBattersTVC.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "ServiceEndpointHub.h"

#import "PlayersBattersTVC.h"
#import "BatterModel.h"
#import "CWBConfiguration.h"

#import "PlayersYearsTVC.h"
#import "PlayersTeamsTVC.h"

#import "CustomSegue.h"
#import "CustomUnwindSegue.h"


@interface PlayersBattersTVC () <PlayersYearsTVCDelegate, PlayersTeamsTVCDelegate>

@property BOOL isLoading;
@property (nonatomic, strong) NSMutableArray *batters;
@property (weak, nonatomic) IBOutlet UIButton *segueButton;

@end

@implementation PlayersBattersTVC

- (void)playersYearSelected:(PlayersYearsTVC *)controller
{
    if([self.playersContextViewModel.yearId length] > 0){
        [self.goToTeamsButton setEnabled:YES];
    }
    
    [self.goToSeasonsButton setTitle:[self getSeasonText] forState:UIControlStateNormal];
    [self refresh];
}

- (void)playersTeamSelected:(PlayersTeamsTVC *)controller
{
    [self.goToTeamsButton setTitle:[self getTeamText] forState:UIControlStateNormal];
    [self refresh];
}

- (NSString *) getSeasonText{
    static NSString *SeasonDefault = @"seasons >";
    static NSString *Arrow = @" >";
    
    NSString *seasonText = self.playersContextViewModel.yearId;
    if([seasonText length] == 0){
        seasonText = SeasonDefault;
    }
    return [seasonText stringByAppendingString:Arrow];
}

- (NSString *) getTeamText{
    static NSString *TeamDefault = @"teams >";
    static NSString *Arrow = @" >";
    
    NSString *teamText = self.playersContextViewModel.teamId;
    if([teamText length] == 0){
        teamText = TeamDefault;
    }
    return [teamText stringByAppendingString:Arrow];
}

- (void)viewDidLoad
{
    [self.goToSeasonsButton setTitle:[self getSeasonText] forState:UIControlStateNormal];
    [self.goToTeamsButton setTitle:[self getTeamText] forState:UIControlStateNormal];

    if([self.playersContextViewModel.yearId length] > 0){
        [self.goToTeamsButton setEnabled:YES];
    }

    [self refresh];
    [super viewDidLoad];
}

- (IBAction)goToSeasons:(id)sender {
    [self performSegueWithIdentifier: @"GoToSeasons" sender: self];
}

- (IBAction)goToTeams:(id)sender {
    [self performSegueWithIdentifier: @"GoToTeams" sender: self];
}

// Prepare for the segue going forward
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue isKindOfClass:[CustomSegue class]]) {
        // Set the start point for the animation to center of the button for the animation
        ((CustomSegue *)segue).originatingPoint = self.segueButton.center;
    }
    
    if ([segue.identifier isEqualToString:@"GoToSeasons"]) {
        PlayersYearsTVC *yearsController = (PlayersYearsTVC *)[segue destinationViewController];
        [yearsController setPlayersContextViewModel:self.playersContextViewModel];
        [yearsController setDelegate:self];
    }
    
    if ([segue.identifier isEqualToString:@"GoToTeams"]) {
        PlayersTeamsTVC *teamsController = (PlayersTeamsTVC *)[segue destinationViewController];
        [teamsController setPlayersContextViewModel:self.playersContextViewModel];
        [teamsController setDelegate:self];
    }
}

// This is the IBAction method referenced in the Storyboard Exit for the Unwind segue.
// It needs to be here to create a link for the unwind segue.
// But we'll do nothing with it.
- (IBAction)unwindFromViewController:(UIStoryboardSegue *)sender {
}

// We need to over-ride this method from UIViewController to provide a custom segue for unwinding
- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    // Instantiate a new CustomUnwindSegue
    CustomUnwindSegue *segue = [[CustomUnwindSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
    // Set the target point for the animation to the center of the button in this VC
    segue.targetPoint = self.segueButton.center;
    return segue;
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
        // if PlayersBattersTVC is recreated load from core data
        if( [self.batters count] == 0 ) {

            NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
            NSEntityDescription *entityDescription = [NSEntityDescription
                                                      entityForName:@"Batter" inManagedObjectContext:managedObjectContext];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            
            NSSortDescriptor * sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
            [request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
            
            NSError *error = nil;
            NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
            
            if(!error && [results count] != 0){
                [self readyTheArray];
                
                for(BatterModel *result in results) {
                    if( result.batterIdValue != nil){
                        [self.batters addObject:result];
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
        if([self.batters count] == 0){
            [self.notifyLabel setText:@"no results found"];
        } else {
            [self.notifyLabel setText:@""];
        }
    } else {
        if([self.batters count] == 0){
            [self.notifyLabel setText:@"select a season then a team"];
        } else {
            [self.notifyLabel setText:@""];
        }
    }
}

- (void)loadResults
{
    // http://clutchwin.com/api/v1/players.json?
    // &access_token=abc&team_abbr=BAL&season=2013
    NSString *batterSearchEndpoint = [NSString stringWithFormat:@"%1$@&team_abbr=%2$@&season=%3$@",
                                      [CWBConfiguration batterSearchUrl],
                                      self.playersContextViewModel.teamId,
                                      self.playersContextViewModel.yearId];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:batterSearchEndpoint
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  NSArray *sorted = [mappingResult.array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                                                      NSString *first = [(BatterModel*)a firstName];
                                                      NSString *second = [(BatterModel*)b firstName];
                                                      return [first compare:second];
                                                  }];
                                                  
                                                  self.batters = [sorted mutableCopy];
                                                  [self.collectionView reloadData];
                                                  [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                                                  [self.playersContextViewModel recordLastTeamId:self.playersContextViewModel.teamId ];
                                                  
                                                  [spinner stopAnimating];
                                                  [self setNotifyText:YES:NO];
                                                  self.isLoading = NO;
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if ([CWBConfiguration isLoggingEnabled]){
                                                      NSLog(@"Load batters failed with exception': %@", error);
                                                  }
                                                  [spinner stopAnimating];
                                                  [self setNotifyText:YES:YES];
                                                  self.isLoading = NO;
                                              }];
}

#pragma mark - Helper methods
- (BOOL) serviceCallAllowed {

    //check for empty and nil
    if ([self.playersContextViewModel.yearId length] == 0 || [self.playersContextViewModel.teamId length] == 0) {
        return NO;
    }
    return YES;
}

- (BOOL) needsToLoadData {

    if ([self serviceCallAllowed]) {
        if (![self.playersContextViewModel.teamId isEqualToString:self.playersContextViewModel.lastTeamId]) {
            return YES;
        }
    }
    return NO;
}

- (void) readyTheArray {
    if( [self.batters count] == 0 ){
        self.batters = [[NSMutableArray alloc] init];
    } else {
        [self.batters removeAllObjects];
    }
}


#pragma mark - UICollection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.batters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UILabel *displayText = (UILabel *)[cell viewWithTag:100];
    BatterModel *batter = self.batters[indexPath.row];
    displayText.text = [batter displayName];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isLoading) {
        BatterModel *batter = self.batters[indexPath.row];
        self.playersContextViewModel.batterId = batter.batterIdValue;
        
        [self.delegate playersBatterSelected:self];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    BatterModel *batter = self.batters[indexPath.row];
    cell.textLabel.text = [batter displayName];
    
    return cell;
}

@end