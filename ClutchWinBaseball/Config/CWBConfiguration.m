//
//  Configuration.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-04-19.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "CWBConfiguration.h"

#define ConfigurationBaseUrlString @"BaseUrlString"
#define ConfigurationJsonSuffix @"JsonSuffix"
#define ConfigurationFranchises @"Franchise"
#define ConfigurationTeamResults @"FranchiseSearch"
#define ConfigurationTeamDrillDown @"FranchiseYearSearch"

#define ConfigurationYears @"Years"
#define ConfigurationTeamSearch @"Teams"
#define ConfigurationBatterSearch @"RosterSearch"
#define ConfigurationPitcherSearch @"OpponentsForBatter"
#define ConfigurationPlayerResults @"PlayerPlayerSearch"
#define ConfigurationPlayerDrillDown @"PlayerPlayerYearSearch"

#define ConfigurationLoggingEnabled @"LoggingEnabled"

@interface CWBConfiguration ()

@property (copy, nonatomic) NSString *configuration;
@property (nonatomic, strong) NSDictionary *variables;

@end

@implementation CWBConfiguration

#pragma mark Shared Configuration
+ (CWBConfiguration *)sharedConfiguration {
    static CWBConfiguration *_sharedConfiguration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfiguration = [[self alloc] init];
    });
    
    return _sharedConfiguration;
}

#pragma mark -
#pragma mark Private Initialization
- (id)init {
    self = [super init];
    
    if (self) {
        // Fetch Current Configuration
        NSBundle *mainBundle = [NSBundle mainBundle];
        self.configuration = [[mainBundle infoDictionary] objectForKey:@"CWBConfiguration"];
        
        // Load Configurations
        NSString *path = [mainBundle pathForResource:@"Configurations" ofType:@"plist"];
        NSDictionary *configurations = [NSDictionary dictionaryWithContentsOfFile:path];
        
        // Load Variables for Current Configuration
        //self.variables = [configurations objectForKey:self.configuration];
        self.variables = configurations;
    }
    
    return self;
}

#pragma mark -
+ (NSString *)configuration {
    return [[CWBConfiguration sharedConfiguration] configuration];
}

#pragma mark -
+ (NSString *)baseUrlString {
    CWBConfiguration *sharedConfiguration = [CWBConfiguration sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationBaseUrlString];
    }
    
    return nil;
}

+ (NSString *)jsonSuffix {
    CWBConfiguration *sharedConfiguration = [CWBConfiguration sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationJsonSuffix];
    }
    
    return nil;
}

+ (NSString *)franchiseUrl {
    CWBConfiguration *sharedConfiguration = [CWBConfiguration sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationFranchises];
    }
    
    return nil;
}

+ (NSString *)franchiseSearchUrl {
    CWBConfiguration *sharedConfiguration = [CWBConfiguration sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationTeamResults];
    }
    
    return nil;
}

+ (NSString *)franchiseSearchByYearUrl {
    CWBConfiguration *sharedConfiguration = [CWBConfiguration sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationTeamDrillDown];
    }
    
    return nil;
}

+ (NSString *)yearUrl {
    CWBConfiguration *sharedConfiguration = [CWBConfiguration sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationYears];
    }
    
    return nil;
}

+ (NSString *)teamSearchUrl {
    CWBConfiguration *sharedConfiguration = [CWBConfiguration sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationTeamSearch];
    }
    
    return nil;
}

+ (NSString *)batterSearchUrl {
    CWBConfiguration *sharedConfiguration = [CWBConfiguration sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationBatterSearch];
    }
    
    return nil;
}

+ (NSString *)pitcherSearchUrl {
    CWBConfiguration *sharedConfiguration = [CWBConfiguration sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationPitcherSearch];
    }
    
    return nil;
}

+ (NSString *)playerResultsUrl {
    CWBConfiguration *sharedConfiguration = [CWBConfiguration sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationPlayerResults];
    }
    
    return nil;
}

+ (NSString *)playerDrillDownUrl {
    CWBConfiguration *sharedConfiguration = [CWBConfiguration sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [sharedConfiguration.variables objectForKey:ConfigurationPlayerDrillDown];
    }
    
    return nil;
}

+ (BOOL)isLoggingEnabled {
    CWBConfiguration *sharedConfiguration = [CWBConfiguration sharedConfiguration];
    
    if (sharedConfiguration.variables) {
        return [[sharedConfiguration.variables objectForKey:ConfigurationLoggingEnabled] boolValue];
    }
    
    return NO;
}


@end