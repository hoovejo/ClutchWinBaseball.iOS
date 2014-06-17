//
//  CWBText.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-06-16.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "CWBText.h"

#define ConfigurationErrorMessage @"ErrorMessage"
#define ConfigurationNetworkMessage @"NetworkMessage"
#define ConfigurationNoResults @"NoResults"
#define ConfigurationSelectOpponent @"SelectOpponent"
#define ConfigurationSelectResult @"SelectResult"
#define ConfigurationSelectSeason @"SelectSeason"
#define ConfigurationSelectSeasonTeam @"SelectSeasonTeam"
#define ConfigurationSelectBatter @"SelectBatter"
#define ConfigurationSelectPitcher @"SelectPitcher"


@interface CWBText ()

@property (copy, nonatomic) NSString *configuration;
@property (nonatomic, strong) NSDictionary *variables;

@end

@implementation CWBText

#pragma mark Shared Configuration
+ (CWBText *)sharedConfiguration {
    static CWBText *_sharedConfiguration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfiguration = [[self alloc] init];
    });
    
    return _sharedConfiguration;
}

#pragma mark Private Initialization
- (id)init {
    self = [super init];
    
    if (self) {
        // Fetch Current Configuration
        NSBundle *mainBundle = [NSBundle mainBundle];
        self.configuration = [[mainBundle infoDictionary] objectForKey:@"CWBText"];
        
        // Load Configurations
        NSString *path = [mainBundle pathForResource:@"Text" ofType:@"plist"];
        NSDictionary *configurations = [NSDictionary dictionaryWithContentsOfFile:path];
        
        // Load Variables for Current Configuration
        //self.variables = [configurations objectForKey:self.configuration];
        self.variables = configurations;
    }
    
    return self;
}

#pragma mark -
+ (NSString *)configuration {
    return [[CWBText sharedConfiguration] configuration];
}

+ (NSString *)errorMessage {
    CWBText *sharedConfiguration = [CWBText sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationErrorMessage];
    }
    
    return nil;
}

+ (NSString *)networkMessage {
    CWBText *sharedConfiguration = [CWBText sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationNetworkMessage];
    }
    
    return nil;
}

+ (NSString *)noResults {
    CWBText *sharedConfiguration = [CWBText sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationNoResults];
    }
    
    return nil;
}

+ (NSString *)selectOpponent {
    CWBText *sharedConfiguration = [CWBText sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationSelectOpponent];
    }
    
    return nil;
}

+ (NSString *)selectResult {
    CWBText *sharedConfiguration = [CWBText sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationSelectResult];
    }
    
    return nil;
}

+ (NSString *)selectSeason {
    CWBText *sharedConfiguration = [CWBText sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationSelectSeason];
    }
    
    return nil;
}

+ (NSString *)selectSeasonTeam {
    CWBText *sharedConfiguration = [CWBText sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationSelectSeasonTeam];
    }
    
    return nil;
}

+ (NSString *)selectBatter {
    CWBText *sharedConfiguration = [CWBText sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationSelectBatter];
    }
    
    return nil;
}

+ (NSString *)selectPitcher {
    CWBText *sharedConfiguration = [CWBText sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationSelectPitcher];
    }
    
    return nil;
}

@end
