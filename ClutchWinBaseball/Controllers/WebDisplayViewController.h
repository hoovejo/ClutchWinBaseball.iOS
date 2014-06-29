//
//  WebDisplayViewController.h
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-06-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebDisplayViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) NSString *urlAsString;

@end
