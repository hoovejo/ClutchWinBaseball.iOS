//
//  WebDisplayViewController.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-06-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "WebDisplayViewController.h"
#import <BugSense-iOS/BugSenseController.h>

@interface WebDisplayViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebDisplayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadRequestFromString:self.urlAsString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadRequestFromString:(NSString *)urlString
{
    @try
    {
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:urlRequest];
    }
    @catch (NSException *exception)
    {
        NSDictionary *data = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"value", self.urlAsString, nil ]
                                                         forKeys:[NSArray arrayWithObjects:@"key", @"URLKey", nil ]];
        BUGSENSE_LOG(exception, data);
        return;
    }
    
}

@end
