//
//  PlayersContextViewModel.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "PlayersContextViewModel.h"
#import "ServiceEndpointHub.h"

@implementation PlayersContextViewModel

// We use @dynamic for the properties in Core Data
@dynamic hasLoadedSeasonsOncePerSession;
@dynamic yearId;
@dynamic teamId;
@dynamic batterId;
@dynamic pitcherId;
@dynamic resultYearId;
@dynamic lastYearId;
@dynamic lastTeamId;
@dynamic lastBatterId;
@dynamic lastSearchBatterId;

@dynamic lastSearchPitcherId;
@dynamic lastDrillDownBatterId;
@dynamic lastDrillDownPitcherId;
@dynamic lastDrillDownYearId;

- (void) setLoadedOnce {
    
    PlayersContextViewModel * contextViewModel = nil;
    NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
    NSError *error = nil;
    //Set up the object to update
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PlayersContextViewModel" inManagedObjectContext:managedObjectContext]];
    //Ask for it
    contextViewModel = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    if (!error && contextViewModel) {
        contextViewModel.hasLoadedSeasonsOncePerSession = YES;
    }
    //Save it
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
}

- (void) recordLastYearId:(NSString *)newYearId {
    
    [self setLastYearId:newYearId];
    
    PlayersContextViewModel * contextViewModel = nil;
    NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
    NSError *error = nil;
    //Set up the object to update
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PlayersContextViewModel" inManagedObjectContext:managedObjectContext]];
    //Ask for it
    contextViewModel = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    if (!error && contextViewModel) {
        contextViewModel.yearId = newYearId;
    }
    //Save it
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
}

- (void) recordLastTeamId:(NSString *)newTeamId {
    
    [self setLastTeamId:newTeamId];
    
    PlayersContextViewModel * contextViewModel = nil;
    NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
    NSError *error = nil;
    //Set up the object to update
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PlayersContextViewModel" inManagedObjectContext:managedObjectContext]];
    //Ask for it
    contextViewModel = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    if (!error && contextViewModel) {
        contextViewModel.teamId = newTeamId;
    }
    //Save it
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
}

- (void) recordLastBatterId:(NSString *)newBatterId {
    
    [self setLastBatterId:newBatterId];
    
    PlayersContextViewModel * contextViewModel = nil;
    NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
    NSError *error = nil;
    //Set up the object to update
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PlayersContextViewModel" inManagedObjectContext:managedObjectContext]];
    //Ask for it
    contextViewModel = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    if (!error && contextViewModel) {
        contextViewModel.batterId = newBatterId;
    }
    //Save it
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
}

- (void) recordLastSearchIds:(NSString *)newBatterId : (NSString *)newPitcherId {
    
    [self setLastSearchBatterId:newBatterId];
    [self setLastSearchPitcherId:newPitcherId];
    
    PlayersContextViewModel * contextViewModel = nil;
    NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
    NSError *error = nil;
    //Set up the object to update
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PlayersContextViewModel" inManagedObjectContext:managedObjectContext]];
    //Ask for it
    contextViewModel = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    if (!error && contextViewModel) {
        contextViewModel.lastSearchBatterId = newBatterId;
        contextViewModel.lastSearchPitcherId = newPitcherId;
    }
    //Save it
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
}

- (void) recordLastDrillDownIds:(NSString *)newBatterId : (NSString *)newPitcherId : (NSString *)newYearId {
    [self setLastDrillDownBatterId:newBatterId];
    [self setLastDrillDownPitcherId:newPitcherId];
    [self setLastDrillDownYearId:newYearId];
    
    PlayersContextViewModel * contextViewModel = nil;
    NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
    NSError *error = nil;
    //Set up the object to update
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PlayersContextViewModel" inManagedObjectContext:managedObjectContext]];
    //Ask for it
    contextViewModel = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    if (!error && contextViewModel) {
        contextViewModel.lastDrillDownBatterId = newBatterId;
        contextViewModel.lastDrillDownPitcherId = newPitcherId;
        contextViewModel.lastDrillDownYearId = newYearId;
    }
    //Save it
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
}

@end
