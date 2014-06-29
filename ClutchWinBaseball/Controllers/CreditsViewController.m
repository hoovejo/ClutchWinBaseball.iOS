//
//  CreditsViewController.m
//  ClutchWinBaseball
//
//  Created by Joe Hoover on 2014-06-21.
//  Copyright (c) 2014 com.clutchwin.baseball. All rights reserved.
//

#import "CreditsViewController.h"
#import "CustomSegue.h"
#import "CustomUnwindSegue.h"
#import "WebDisplayViewController.h"

@interface CreditsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *segueButton;

@end

@implementation CreditsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Prepare for the segue going forward
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue isKindOfClass:[CustomSegue class]]) {
        // Set the start point for the animation to center of the button for the animation
        ((CustomSegue *)segue).originatingPoint = self.segueButton.center;
    }
    
    if ([segue.identifier isEqualToString:@"GoToRetrosheet"]) {
        WebDisplayViewController *controller = (WebDisplayViewController *)[[segue destinationViewController] visibleViewController];
        [controller setUrlAsString:@"http://www.retrosheet.org/"];
    }
    
    if ([segue.identifier isEqualToString:@"GoToClutchWin"]) {
        WebDisplayViewController *controller = (WebDisplayViewController *)[[segue destinationViewController] visibleViewController];
        [controller setUrlAsString:@"http://ClutchWin.com/"];
    }
}

// This is the IBAction method referenced in the Storyboard Exit for the Unwind segue.
// It needs to be here to create a link for the unwind segue.
// But we'll do nothing with it.
- (IBAction)unwindFromViewController:(UIStoryboardSegue *)sender {
}

// We need to over-ride this method from UIViewController to provide a custom segue for unwinding
- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    // Instantiate a new CustomUnwindSegue
    CustomUnwindSegue *segue = [[CustomUnwindSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
    // Set the target point for the animation to the center of the button in this VC
    segue.targetPoint = self.segueButton.center;
    return segue;
}

@end
