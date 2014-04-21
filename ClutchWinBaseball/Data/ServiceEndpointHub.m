//
//  DataContext.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-19.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

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

+ (void)configureRestKit
{
    // initialize AFNetworking HTTPClient
    NSString *baseStringUrl = [CWBConfiguration baseUrlString];
    NSURL *baseURL = [NSURL URLWithString:baseStringUrl];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // setup object mappings
    [objectManager addResponseDescriptor:[self buildFranchises ]];
    [objectManager addResponseDescriptor:[self buildTeamsResults ]];
    [objectManager addResponseDescriptor:[self buildTeamsDrillDown ]];

    [objectManager addResponseDescriptor:[self buildYears ]];
    [objectManager addResponseDescriptor:[self buildTeamSearch ]];
    [objectManager addResponseDescriptor:[self buildBatterSearch ]];
    [objectManager addResponseDescriptor:[self buildPitcherSearch ]];
    [objectManager addResponseDescriptor:[self buildPlayersResults ]];
    [objectManager addResponseDescriptor:[self buildPlayersDrillDown ]];

    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
}

#pragma mark - Response Descriptor builders
+ (RKResponseDescriptor *) buildFranchises {
    
    // setup object mappings
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[FranchiseModel class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"id": @"franchiseId",
                                                           @"retro_id": @"retroId",
                                                           @"league_id": @"leagueId",
                                                           @"division_id": @"divisionId",
                                                           @"location": @"location",
                                                           @"name": @"name",
                                                           @"alternate_name": @"alternateName",
                                                           @"first_game_dt": @"firstGameDt",
                                                           @"last_game_dt": @"lastGameDt",
                                                           @"city": @"city",
                                                           @"state": @"state"}];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/franchises.json"
                                                keyPath:nil
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (RKResponseDescriptor *) buildTeamsResults {
    
    // setup object mappings
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TeamsResultModel class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"year": @"year",
                                                        @"games": @"games",
                                                        @"team": @"team",
                                                        @"opponent": @"opponent",
                                                        @"wins": @"wins",
                                                        @"losses": @"losses",
                                                        @"runs_for": @"runsFor",
                                                        @"runs_against": @"runsAgainst"}];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/search/franchise_vs_franchise/:franchiseId/:opponentId.json"
                                                keyPath:@"rows"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return responseDescriptor;
}

+ (RKResponseDescriptor *) buildTeamsDrillDown {
    
    // setup object mappings
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
