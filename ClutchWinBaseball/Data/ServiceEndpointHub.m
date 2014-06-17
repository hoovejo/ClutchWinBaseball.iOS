//
//  DataContext.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-19.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "ServiceEndpointHub.h"

#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>
#import "CWBConfiguration.h"

#import "TeamsContextViewModel.h"
#import "PlayersContextViewModel.h"

#import "FranchiseModel.h"
#import "TeamsResultModel.h"
#import "TeamsDrillDownModel.h"

#import "YearModel.h"
#import "TeamModel.h"
#import "BatterModel.h"
#import "PitcherModel.h"
#import "PlayersResultModel.h"
#import "PlayersDrillDownModel.h"

@interface ServiceEndpointHub ()

@end

@implementation ServiceEndpointHub

static NSManagedObjectModel *staticManagedObjectModel;
static NSManagedObjectContext *staticManagedObjectContext;
static RKManagedObjectStore *staticManagedObjectStore;

+ (NSManagedObjectModel *)getManagedObjectModel
{
    return staticManagedObjectModel;
}

+ (NSManagedObjectContext *)getManagedObjectContext
{
    return staticManagedObjectContext;
}

+ (RKManagedObjectStore *)getManagedObjectStore
{
    return staticManagedObjectStore;
}

static BOOL isNetWorkAvailable;
+ (BOOL)getIsNetworkAvailable
{
    return isNetWorkAvailable;
}

+ (void)configureRestKit
{
    // initialize AFNetworking HTTPClient
    NSString *baseStringUrl = [CWBConfiguration baseUrlString];
    NSURL *baseURL = [NSURL URLWithString:baseStringUrl];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];

    // Enable Activity Indicator Spinner
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // Initialize managed object store
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    objectManager.managedObjectStore = managedObjectStore;
    
    [objectManager.HTTPClient setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                // -- Reachable -- //
                isNetWorkAvailable = YES;
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                // -- Not reachable -- //
                isNetWorkAvailable = NO;
                break;
        }
        
        
         if (status == AFNetworkReachabilityStatusNotReachable) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                             message:@"You must be connected to the internet to use this app."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
         }
         
    }];
    
    // add the routes
    [ServiceEndpointHub addRoutes:objectManager ];
    
    // setup object mappings
    [[RKObjectManager sharedManager] addResponseDescriptor:[self buildFranchises:managedObjectStore ]];
    [[RKObjectManager sharedManager] addResponseDescriptor:[self buildTeamsResults:managedObjectStore ]];
    [[RKObjectManager sharedManager] addResponseDescriptor:[self buildTeamsDrillDown:managedObjectStore ]];

    [[RKObjectManager sharedManager] addResponseDescriptor:[self buildYears:managedObjectStore ]];
    [[RKObjectManager sharedManager] addResponseDescriptor:[self buildTeamSearch:managedObjectStore ]];
    [[RKObjectManager sharedManager] addResponseDescriptor:[self buildBatterSearch:managedObjectStore ]];
    [[RKObjectManager sharedManager] addResponseDescriptor:[self buildPitcherSearch:managedObjectStore ]];
    //[[RKObjectManager sharedManager] addResponseDescriptor:[self buildPlayersResults:managedObjectStore ]];
    //[[RKObjectManager sharedManager] addResponseDescriptor:[self buildPlayersDrillDown:managedObjectStore ]];

    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"ClutchWinModel.sqlite"];
    NSError *error;
    
    NSPersistentStore *persistentStore = [managedObjectStore
                                          addSQLitePersistentStoreAtPath:storePath
                                          fromSeedDatabaseAtPath:nil
                                          withConfiguration:nil
                                          options:@{NSMigratePersistentStoresAutomaticallyOption:@YES,
                                                    NSInferMappingModelAutomaticallyOption:@YES}
                                          error:&error];
    
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    [managedObjectStore createManagedObjectContexts];
    
    NSManagedObjectContext *managedObjectContext = managedObjectStore.persistentStoreManagedObjectContext;
    
    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectContext];
    
    staticManagedObjectModel = managedObjectModel;
    staticManagedObjectContext = managedObjectContext;
    staticManagedObjectStore = managedObjectStore;
    
    //setup the persistent ContextViewModels
    [ServiceEndpointHub setupContextModels ];

}

+ (void) addRoutes:(RKObjectManager *) objectManager {
    
    RKRoute *franchiseRoute = [RKRoute routeWithClass:[FranchiseModel class]
                                          pathPattern:@"/api/v1/franchises.json" method:RKRequestMethodGET];
    franchiseRoute.shouldEscapePath = YES;
    [objectManager.router.routeSet addRoute:franchiseRoute];
    
    RKRoute *teamsResultsRoute = [RKRoute routeWithClass:[TeamsResultModel class]
                                             pathPattern:@"/api/v1/games/for_team/summary.json" method:RKRequestMethodGET];
    teamsResultsRoute.shouldEscapePath = YES;
    [objectManager.router.routeSet addRoute:teamsResultsRoute];
    
    RKRoute *teamsDrillDownRoute = [RKRoute routeWithClass:[TeamsDrillDownModel class]
                                               pathPattern:@"/api/v1/games/for_team.json" method:RKRequestMethodGET];
    teamsDrillDownRoute.shouldEscapePath = YES;
    [objectManager.router.routeSet addRoute:teamsDrillDownRoute];
    
    RKRoute *seasonsRoute = [RKRoute routeWithClass:[YearModel class]
                                        pathPattern:@"/api/v1/seasons.json" method:RKRequestMethodGET];
    seasonsRoute.shouldEscapePath = YES;
    [objectManager.router.routeSet addRoute:seasonsRoute];

    RKRoute *teamsRoute = [RKRoute routeWithClass:[TeamModel class]
                                      pathPattern:@"/api/v1/teams.json" method:RKRequestMethodGET];
    teamsRoute.shouldEscapePath = YES;
    [objectManager.router.routeSet addRoute:teamsRoute];
    
    RKRoute *battersRoute = [RKRoute routeWithClass:[BatterModel class]
                                        pathPattern:@"/api/v1/players.json" method:RKRequestMethodGET];
    battersRoute.shouldEscapePath = YES;
    [objectManager.router.routeSet addRoute:battersRoute];
    
    RKRoute *pitchersRoute = [RKRoute routeWithClass:[PitcherModel class]
                                         pathPattern:@"/api/v1/opponents/pitchers.json" method:RKRequestMethodGET];
    pitchersRoute.shouldEscapePath = YES;
    [objectManager.router.routeSet addRoute:pitchersRoute];
    
    /*
    RKRoute *playersResultsRoute = [RKRoute routeWithClass:[PlayersResultModel class]
                                               pathPattern:@"/api/v1/events/summary.json" method:RKRequestMethodGET];
    playersResultsRoute.shouldEscapePath = YES;
    [objectManager.router.routeSet addRoute:playersResultsRoute];
    
    RKRoute *playersDrillDownRoute = [RKRoute routeWithClass:[PlayersDrillDownModel class]
                                                 pathPattern:@"/api/v1/events/summary.json" method:RKRequestMethodGET];
    playersDrillDownRoute.shouldEscapePath = YES;
    [objectManager.router.routeSet addRoute:playersDrillDownRoute];
     */
}

#pragma mark - Response Descriptor builders
+ (RKResponseDescriptor *) buildFranchises:(RKManagedObjectStore *)managedObjectStore {
    
    // setup object mappings
    RKEntityMapping *resultMapping = [RKEntityMapping mappingForEntityForName:@"Franchise" inManagedObjectStore:managedObjectStore];
    [resultMapping addAttributeMappingsFromDictionary:@{@"franchise_abbr": @"retroId",
                                                           @"league": @"leagueId",
                                                           @"division": @"divisionId",
                                                           @"location": @"location",
                                                           @"name": @"name"}];
    resultMapping.identificationAttributes = @[ @"retroId" ];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/api/v1/franchises.json"
                                                keyPath:nil
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (RKResponseDescriptor *) buildTeamsResults:(RKManagedObjectStore *)managedObjectStore {
    
    // setup object mappings
    RKEntityMapping *resultMapping = [RKEntityMapping mappingForEntityForName:@"TeamsResult" inManagedObjectStore:managedObjectStore];
    [resultMapping addAttributeMappingsFromDictionary:@{@"season": @"year",
                                                        @"team_abbr": @"team",
                                                        @"opp_abbr": @"opponent",
                                                        @"win": @"wins",
                                                        @"loss": @"losses",
                                                        @"score": @"runsFor",
                                                        @"opp_score": @"runsAgainst"}];
    
    resultMapping.identificationAttributes = @[ @"year" ];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/api/v1/games/for_team/summary.json"
                                                keyPath:nil
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (RKResponseDescriptor *) buildTeamsDrillDown:(RKManagedObjectStore *)managedObjectStore {
    
    RKEntityMapping *resultMapping = [RKEntityMapping mappingForEntityForName:@"TeamsDrillDown" inManagedObjectStore:managedObjectStore];
    [resultMapping addAttributeMappingsFromDictionary:@{@"game_date": @"gameDate",
                                                           @"team_abbr": @"team",
                                                           @"opp_abbr": @"opponent",
                                                           @"win": @"win",
                                                           @"loss": @"loss",
                                                           @"score": @"runsFor",
                                                           @"opp_score": @"runsAgainst"}];

    resultMapping.identificationAttributes = @[ @"gameDate" ];

    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/api/v1/games/for_team.json"
                                                keyPath:nil
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (RKResponseDescriptor *) buildYears:(RKManagedObjectStore *)managedObjectStore {
    
    // setup object mappings
    RKEntityMapping *resultMapping = [RKEntityMapping mappingForEntityForName:@"Season" inManagedObjectStore:managedObjectStore];
    [resultMapping addAttributeMappingsFromDictionary:@{@"season": @"yearValue"}];

    resultMapping.identificationAttributes = @[ @"yearValue" ];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/api/v1/seasons.json"
                                                keyPath:nil
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (RKResponseDescriptor *) buildTeamSearch:(RKManagedObjectStore *)managedObjectStore {

    // setup object mappings
    RKEntityMapping *resultMapping = [RKEntityMapping mappingForEntityForName:@"Team" inManagedObjectStore:managedObjectStore];
    [resultMapping addAttributeMappingsFromDictionary:@{@"team_abbr": @"teamIdValue",
                                                        @"league": @"leagueId",
                                                        @"location": @"location",
                                                        @"name": @"name"}];
    
    resultMapping.identificationAttributes = @[ @"teamIdValue" ];

    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/api/v1/teams.json"
                                                keyPath:nil
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (RKResponseDescriptor *) buildBatterSearch:(RKManagedObjectStore *)managedObjectStore {
    
    // setup object mappings
    RKEntityMapping *resultMapping = [RKEntityMapping mappingForEntityForName:@"Batter" inManagedObjectStore:managedObjectStore];
    [resultMapping addAttributeMappingsFromDictionary:@{@"player_retro_id": @"batterIdValue",
                                                        @"first_name": @"firstName",
                                                        @"last_name": @"lastName"}];
    
    resultMapping.identificationAttributes = @[ @"batterIdValue" ];

    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/api/v1/players.json"
                                                keyPath:nil
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (RKResponseDescriptor *) buildPitcherSearch:(RKManagedObjectStore *)managedObjectStore {
    
    // setup object mappings
    RKEntityMapping *resultMapping = [RKEntityMapping mappingForEntityForName:@"Pitcher" inManagedObjectStore:managedObjectStore];
    [resultMapping addAttributeMappingsFromDictionary:@{@"first_name": @"firstName",
                                                        @"last_name": @"lastName",
                                                        @"player_id": @"retroId"}];
    
    resultMapping.identificationAttributes = @[ @"retroId" ];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/api/v1/opponents/pitchers.json"
                                                keyPath:nil
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (RKResponseDescriptor *) buildPlayersResults:(RKManagedObjectStore *)managedObjectStore {
    // setup object mappings
    RKEntityMapping *resultMapping = [RKEntityMapping mappingForEntityForName:@"PlayersResult" inManagedObjectStore:managedObjectStore];
    [resultMapping addAttributeMappingsFromDictionary:@{@"season": @"year",
                                                        @"g": @"games",
                                                        @"ab": @"atBat",
                                                        @"h": @"hit",
                                                        @"bb": @"walks",
                                                        @"k": @"strikeOut",
                                                        @"h_2b": @"secondBase",
                                                        @"h_3b": @"thirdBase",
                                                        @"hr": @"homeRun",
                                                        @"rbi_ct": @"runBattedIn"}];
    
    resultMapping.identificationAttributes = @[ @"year" ];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/api/v1/events/summary.json"
                                                keyPath:nil
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (RKResponseDescriptor *) buildPlayersDrillDown:(RKManagedObjectStore *)managedObjectStore {
    // setup object mappings
    RKEntityMapping *resultMapping = [RKEntityMapping mappingForEntityForName:@"PlayersDrillDown" inManagedObjectStore:managedObjectStore];
    [resultMapping addAttributeMappingsFromDictionary:@{@"game_date": @"gameDate",
                                                        @"ab": @"atBat",
                                                        @"h": @"hit",
                                                        @"bb": @"walks",
                                                        @"k": @"strikeOut",
                                                        @"h_2b": @"secondBase",
                                                        @"h_3b": @"thirdBase",
                                                        @"hr": @"homeRun",
                                                        @"rbi_ct": @"runBattedIn"}];
    
    resultMapping.identificationAttributes = @[ @"gameDate" ];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/api/v1/events/summary.json"
                                                keyPath:nil
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (void) setupContextModels {

    NSError *error = nil;

    TeamsContextViewModel * contextViewModel = nil;
    NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
    //Set up the object to update
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TeamsContextViewModel" inManagedObjectContext:managedObjectContext]];
    //Ask for it
    contextViewModel = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    if (!error && contextViewModel) {
        contextViewModel.hasLoadedFranchisesOncePerSession = NO;
    } else {
        NSManagedObject *newTeamsContextViewModel;
        newTeamsContextViewModel = [NSEntityDescription insertNewObjectForEntityForName:@"TeamsContextViewModel"
                                                                 inManagedObjectContext:managedObjectContext];
    }
    //Save it
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }

    PlayersContextViewModel *playerContext = nil;
    [request setEntity:[NSEntityDescription entityForName:@"PlayersContextViewModel" inManagedObjectContext:managedObjectContext]];
    //Ask for it
    playerContext = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    if (!error && playerContext) {
        playerContext.hasLoadedSeasonsOncePerSession = NO;
    } else {
        NSManagedObject *newPlayersContextViewModel;
        newPlayersContextViewModel = [NSEntityDescription insertNewObjectForEntityForName:@"PlayersContextViewModel"
                                                                 inManagedObjectContext:managedObjectContext];
    }
    //Save it
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
}


@end
