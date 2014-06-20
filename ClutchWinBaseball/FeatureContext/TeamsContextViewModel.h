//
//  TeamsContextViewModel.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-20.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <RestKit/RestKit.h>
//#import <RestKit/CoreData.h>

@interface TeamsContextViewModel : NSObject

@property BOOL hasLoadedFranchisesOncePerSession;
//retain current selections
@property (nonatomic, strong) NSString *franchiseId;
@property (nonatomic, strong) NSString *opponentId;
@property (nonatomic, strong) NSString *yearId;
//retain last params for opponent filter
@property (nonatomic, strong) NSString *lastOpponentFilterFranchiseId;
//retain last params for team result search
@property (nonatomic, strong) NSString *lastSearchFranchiseId;
@property (nonatomic, strong) NSString *lastSearchOpponentId;
//retain last params for team drilldown search
@property (nonatomic, strong) NSString *lastDrillDownFranchiseId;
@property (nonatomic, strong) NSString *lastDrillDownOpponentId;
@property (nonatomic, strong) NSString *lastDrillDownYearId;

- (void) setLoadedOnce;
- (void) recordFranchiseId:(NSString *)newFranchiseId;
- (void) recordOpponentId:(NSString *)newOpponentId;
- (void) recordLastSearchIds;
- (void) recordLastDrillDownIds;

@end
