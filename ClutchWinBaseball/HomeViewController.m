//
//  HomeViewController.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-06-16.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@property BOOL bannerLoaded;

@end

@implementation HomeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bannerLoaded = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma iAd Delegate methods

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{

    if (!self.bannerLoaded) {
        _iAd.hidden = NO;
        self.bannerLoaded = YES;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1];
        [UIView commitAnimations];
    }
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    if (self.bannerLoaded) {
        _iAd.hidden = YES;
        self.bannerLoaded = NO;
    }
}

@end
