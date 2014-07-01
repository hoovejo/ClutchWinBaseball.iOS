//
//  HomeViewController.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-06-16.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface HomeViewController : UIViewController <ADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet ADBannerView *iAd;

@end
