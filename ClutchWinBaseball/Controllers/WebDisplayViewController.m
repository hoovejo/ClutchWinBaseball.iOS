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
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

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
        
        self.webView.delegate = self;
        
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

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = self.view.center;
    spinner.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    spinner.center = self.view.center;
    spinner.hidesWhenStopped = YES;
    if ([spinner respondsToSelector:@selector(setColor:)]) {
        [spinner setColor:[UIColor grayColor]];
    }
    [self.view addSubview:spinner];
    [spinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinner stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.spinner stopAnimating];
}


@end
