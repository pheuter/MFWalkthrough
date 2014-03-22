//
//  AppDelegate.m
//  WalkthroughDemo
//
//  Created by Mark Fayngersh on 3/18/14.
//  Copyright (c) 2014 Mark Fayngersh. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)          application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];

  // First we instantiate the view controllers that we'll want to walkthrough
  ViewController *firstViewController = [[ViewController alloc] init];
  firstViewController.title = @"First";
  ViewController *secondViewController = [[ViewController alloc] init];
  secondViewController.title = @"Second";
  ViewController *lastViewController = [[ViewController alloc] init];
  lastViewController.title = @"Last";

  // Then we initialize a MFWalkthroughViewController object with the view
  // controllers
  MFWalkthroughViewController *walkthroughController = [[MFWalkthroughViewController alloc]
                                                                                     initWithViewControllers:
                                                                                       @[firstViewController, secondViewController, lastViewController]];

  // Don't forget to assign dataSource and delegate properties
  walkthroughController.dataSource = self;
  walkthroughController.delegate = self;

  // MFWalkthroughViewController is designed to be used in conjunction with
  // UINavigationController
  UINavigationController *navigationController = [[UINavigationController alloc]
                                                                          initWithRootViewController:walkthroughController];

  self.window.rootViewController = navigationController;
  [self.window makeKeyAndVisible];
  return YES;
}

#pragma mark - MFWalkthroughDataSource Methods

// Required

- (NSString *)walkthroughViewController:(MFWalkthroughViewController *)walkthroughViewController
enableContinuePropertyForViewController:(UIViewController *)viewController {
  // If you take a look at ViewController.m, you'll notice a property named
  // `isValid` that is toggled by the UISwitch.
  return @"isValid";
}

#pragma mark - MFWalkthroughDelegate Methods

// Required

- (void) walkthroughViewController:(MFWalkthroughViewController *)walkthroughViewController
willContinueFromLastViewController:(UIViewController *)lastViewController {
}

- (void)walkthroughViewController:(MFWalkthroughViewController *)walkthroughViewController
willGoBackFromFirstViewController:(UIViewController *)firstViewController {
}

// Optional

- (void) walkthroughViewController:(MFWalkthroughViewController *)walkthroughViewController
couldNotContinueFromViewController:(ViewController *)currentViewController {
  [currentViewController shakeAnimation];
}

@end
