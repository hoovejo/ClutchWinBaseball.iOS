//
//  ServiceEndpointHub.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-19.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

@interface ServiceEndpointHub : NSObject

/*
+ (NSManagedObjectModel *) getManagedObjectModel;
+ (NSManagedObjectContext *) getManagedObjectContext;
+ (RKManagedObjectStore *) getManagedObjectStore;
+ (RKResponseDescriptor *) buildPlayersResults:(RKManagedObjectStore *)managedObjectStore;
+ (RKResponseDescriptor *) buildPlayersDrillDown:(RKManagedObjectStore *)managedObjectStore;
 */

+ (RKResponseDescriptor *) buildPlayersResults;
+ (RKResponseDescriptor *) buildPlayersDrillDown;
+ (void)configureRestKit;
+ (BOOL)getIsNetworkAvailable;

@end
