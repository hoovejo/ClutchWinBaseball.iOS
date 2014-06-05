//
//  DataContext.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-19.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>
#import "ServiceEndpointHub.h"
#import "CWBConfiguration.h"

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

+ (NSManagedObjectModel *)getManagedObjectModel
{
    return staticManagedObjectModel;
}

+ (NSManagedObjectContext *)getManagedObjectContext
{
    return staticManagedObjectContext;
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
    
    // setup object mappings
    [objectManager addResponseDescriptor:[self buildFranchises:managedObjectStore ]];
    [objectManager addResponseDescriptor:[self buildTeamsResults:managedObjectStore ]];
    //[objectManager addResponseDescriptor:[self buildTeamsDrillDown ]];

    //[objectManager addResponseDescriptor:[self buildYears ]];
    //[objectManager addResponseDescriptor:[self buildTeamSearch ]];
    //[objectManager addResponseDescriptor:[self buildBatterSearch ]];
    //[objectManager addResponseDescriptor:[self buildPitcherSearch ]];
    //[objectManager addResponseDescriptor:[self buildPlayersResults ]];
    //[objectManager addResponseDescriptor:[self buildPlayersDrillDown ]];

    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"ClutchWinModel.sqlite"];
    
    NSError *error;
    
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error];
    
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    [managedObjectStore createManagedObjectContexts];
    
    NSManagedObjectContext *managedObjectContext = managedObjectStore.persistentStoreManagedObjectContext;
    
    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectContext];
    
    staticManagedObjectModel = managedObjectModel;
    staticManagedObjectContext = managedObjectContext;
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
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:nil
                                                keyPath:nil
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (RKResponseDescriptor *) buildTeamsDrillDown {
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TeamsDrillDownModel class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"Game Date": @"gameDate",
                                                           @"team": @"team",
                                                           @"opponent": @"opponent",
                                                           @"win": @"win",
                                                           @"loss": @"loss",
                                                           @"runs_for": @"runsFor",
                                                           @"runs_against": @"runsAgainst"}];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/search/franchise_vs_franchise_by_year/:franchiseId/:opponentId/:yearId.json"
                                                keyPath:@"rows"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (RKResponseDescriptor *) buildYears {
    
    // setup object mappings
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[YearModel class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"id": @"yearValue"}];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/years.json"
                                                keyPath:nil
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (RKResponseDescriptor *) buildTeamSearch {
    
    // setup object mappings
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TeamModel class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"id": @"teamIdValue",
                                                        @"year_id": @"yearId",
                                                        @"team_id": @"teamId",
                                                        @"team_type": @"teamType",
                                                        @"league_id": @"leagueId",
                                                        @"location": @"location",
                                                        @"name": @"name"}];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/teams/:yearId.json"
                                                keyPath:nil
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (RKResponseDescriptor *) buildBatterSearch {
    
    // setup object mappings
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[BatterModel class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"id": @"batterIdValue",
                                                        @"bat_hand": @"batHand",
                                                        @"first_name": @"firstName",
                                                        @"last_name": @"lastName",
                                                        @"game_type": @"gameType",
                                                        @"pit_hand": @"pitHand",
                                                        @"pos_tx": @"posTx",
                                                        @"rep_team_id": @"repTeamId",
                                                        @"retro_player_id": @"retroPlayerId",
                                                        @"retro_team_id": @"retroTeamId",
                                                        @"year_id": @"yearId"}];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/roster_for_team_and_year/:teamId/:yearId.json"
                                                keyPath:nil
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (RKResponseDescriptor *) buildPitcherSearch {
    
    // setup object mappings
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[PitcherModel class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"first_name": @"firstName",
                                                        @"last_name": @"lastName",
                                                        @"retro_id": @"retroId"}];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/search/opponents_for_batter/:batterId/:yearId.json"
                                                keyPath:@"rows"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (RKResponseDescriptor *) buildPlayersResults {
    
    // setup object mappings
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[PlayersResultModel class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"year": @"year",
                                                        @"Type": @"type",
                                                        @"G": @"games",
                                                        @"AB": @"atBat",
                                                        @"H": @"hit",
                                                        @"2B": @"secondBase",
                                                        @"3B": @"thirdBase",
                                                        @"HR": @"homeRun",
                                                        @"RBI": @"runBattedIn",
                                                        @"SO": @"strikeOut",
                                                        @"BB": @"baseBall",
                                                        @"AVG": @"average"}];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/search/player_vs_player/:batterId/:pitcherId.json"
                                                keyPath:@"rows"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (RKResponseDescriptor *) buildPlayersDrillDown {
    
    // setup object mappings
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[PlayersDrillDownModel class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"Game Date": @"gameDate",
                                                        @"AB": @"atBat",
                                                        @"H": @"hit",
                                                        @"2B": @"secondBase",
                                                        @"3B": @"thirdBase",
                                                        @"HR": @"homeRun",
                                                        @"RBI": @"runBattedIn",
                                                        @"SO": @"strikeOut",
                                                        @"BB": @"baseBall",
                                                        @"AVG": @"average"}];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/search/player_vs_player_by_year/:batterId/:pitcherId/:yearId/:gameType.json"
                                                keyPath:@"rows"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

@end
