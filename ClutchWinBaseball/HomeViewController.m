//
//  HomeViewController.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-06-16.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma iAd Delegate methods

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    [UIView commitAnimations];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    
 
}

@end
