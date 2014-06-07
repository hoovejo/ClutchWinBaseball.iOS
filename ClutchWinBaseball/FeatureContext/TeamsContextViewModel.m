//
//  TeamsContextViewModel.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-20.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "TeamsContextViewModel.h"
#import "ServiceEndpointHub.h"

@implementation TeamsContextViewModel

// We use @dynamic for the properties in Core Data
@dynamic hasLoadedFranchisesOncePerSession;
@dynamic franchiseId;
@dynamic opponentId;
@dynamic yearId;
@dynamic lastOpponentFilterFranchiseId;
@dynamic lastSearchFranchiseId;
@dynamic lastSearchOpponentId;
@dynamic lastDrillDownFranchiseId;
@dynamic lastDrillDownOpponentId;
@dynamic lastDrillDownYearId;

- (void) setLoadedOnce {
    
    TeamsContextViewModel * contextViewModel = nil;
    NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
    NSError *error = nil;
    //Set up the object to update
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TeamsContextViewModel" inManagedObjectContext:managedObjectContext]];
    //Ask for it
    contextViewModel = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    if (!error && contextViewModel) {
        contextViewModel.hasLoadedFranchisesOncePerSession = YES;
    }
    //Save it
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
}

- (void) recordFranchiseId:(NSString *)newFranchiseId {
    
    [self setFranchiseId:newFranchiseId];
    
    TeamsContextViewModel * contextViewModel = nil;
    NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
    NSError *error = nil;
    //Set up the object to update
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TeamsContextViewModel" inManagedObjectContext:managedObjectContext]];
    //Ask for it
    contextViewModel = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    if (!error && contextViewModel) {
        contextViewModel.franchiseId = newFranchiseId;
    }
    //Save it
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
}

- (void) recordOpponentId:(NSString *)newOpponentId {
    
    [self setOpponentId:newOpponentId];
    
    TeamsContextViewModel * contextViewModel = nil;
    NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
    NSError *error = nil;
    //Set up the object to update
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TeamsContextViewModel" inManagedObjectContext:managedObjectContext]];
    //Ask for it
    contextViewModel = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    if (!error && contextViewModel) {
        contextViewModel.opponentId = newOpponentId;
    }
    //Save it
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
}

- (void) recordLastSearchIds {
    
    [self setLastSearchFranchiseId:self.franchiseId];
    [self setLastSearchOpponentId:self.opponentId];
    
    TeamsContextViewModel * contextViewModel = nil;
    NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
    NSError *error = nil;
    //Set up the object to update
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TeamsContextViewModel" inManagedObjectContext:managedObjectContext]];
    //Ask for it
    contextViewModel = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    if (!error && contextViewModel) {
        contextViewModel.lastSearchFranchiseId = self.franchiseId;
        contextViewModel.lastSearchOpponentId = self.opponentId;
    }
    //Save it
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
}

- (void) recordLastDrillDownIds {
    [self setLastDrillDownFranchiseId:self.franchiseId];
    [self setLastDrillDownOpponentId:self.opponentId];
    [self setLastDrillDownYearId:self.yearId];
    
    TeamsContextViewModel * contextViewModel = nil;
    NSManagedObjectContext *managedObjectContext = [ServiceEndpointHub getManagedObjectContext];
    NSError *error = nil;
    //Set up the object to update
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TeamsContextViewModel" inManagedObjectContext:managedObjectContext]];
    //Ask for it
    contextViewModel = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    if (!error && contextViewModel) {
        contextViewModel.lastDrillDownFranchiseId = self.franchiseId;
        contextViewModel.lastDrillDownOpponentId = self.opponentId;
        contextViewModel.lastDrillDownYearId = self.yearId;
    }
    //Save it
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
}

@end
