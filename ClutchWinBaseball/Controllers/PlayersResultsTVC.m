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

@interface PlayersResultsTVC ()

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

- (void) setNotifyText{
    
    if([self.results count] == 0){
        [self.notifyLabel setText:@"select a pitcher first"];
    } else {
        [self.notifyLabel setText:@""];
    }
}

#pragma mark - loading controller
- (void) refresh {
    
    if ([self needsToLoadData]) {
        
        [self readyTheArray];
        [self loadResults];
        
    } else {
        // if PlayersResultsTVC is recreated load from core data
        if( [self.results count] == 0 ) {

            NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
            NSEntityDescription *entityDescription = [NSEntityDescription
                                                      entityForName:@"Pitcher" inManagedObjectContext:managedObjectContext];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            
            NSError *error = nil;
            NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
            
            if(!error){
                [self readyTheArray];
                
                for(PlayersResultModel *result in results) {
                    if( result.year != nil){
                        [self.results addObject:result];
                    }
                }
                [self.tableView reloadData];
            } else {
                
                [self readyTheArray];
                [self loadResults];
            }
        }
    }

    [self setNotifyText];
}

- (void)loadResults
{
    RKManagedObjectStore *managedObjectStore = [ServiceEndpointHub getManagedObjectStore];
    RKResponseDescriptor *responseDescriptor = [ServiceEndpointHub buildPlayersResults:managedObjectStore];
    
    //@"/search/player_vs_player/aybae001/parkj001.json"
    NSString *playerResultsEndpoint = [NSString stringWithFormat:@"%1$@%2$@&bat_id=%3$@&pit_id=%4$@",
                                       [CWBConfiguration baseUrlString],
                                       [CWBConfiguration playerResultsUrl],
                                       self.playersContextViewModel.batterId,
                                       self.playersContextViewModel.pitcherId];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:playerResultsEndpoint]];
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    
    operation.managedObjectContext = managedObjectStore.mainQueueManagedObjectContext;
    operation.managedObjectCache = managedObjectStore.managedObjectCache;
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        //TODO: sort these results
        self.results = [mappingResult.array mutableCopy];
        [self.tableView reloadData];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [self.playersContextViewModel recordLastSearchIds:self.playersContextViewModel.batterId :self.playersContextViewModel.pitcherId ];
        
        [spinner stopAnimating];
        [self setNotifyText];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if ([CWBConfiguration isLoggingEnabled]){
            NSLog(@"Load player results failed with exception': %@", error);
        }
        [spinner stopAnimating];
    }];
    
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operation];
}

#pragma mark - Helper methods
- (BOOL) needsToLoadData {
    
    if (![self.playersContextViewModel.batterId isEqualToString:self.playersContextViewModel.lastSearchBatterId]) {
        return YES;
    }
    
    if (![self.playersContextViewModel.pitcherId isEqualToString:self.playersContextViewModel.lastSearchPitcherId]) {
        return YES;
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


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlayersResultsTableViewCell";
    
    PlayersResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
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
        cell.averageLabel.text = @"0.000";
    } else {
        double val = (float)hitValue / (float)[result.atBat intValue];
        cell.averageLabel.text = [NSString localizedStringWithFormat:@"%.3f", (val)];;
    }

    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayersResultModel *result = self.results[indexPath.row];
    self.playersContextViewModel.resultYearId = result.year;
    
    [self.delegate playersResultSelected:self];
}


@end
