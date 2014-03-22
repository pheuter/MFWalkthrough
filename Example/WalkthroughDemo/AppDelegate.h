//
//  AppDelegate.h
//  WalkthroughDemo
//
//  Created by Mark Fayngersh on 3/18/14.
//  Copyright (c) 2014 Mark Fayngersh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MFWalkthrough/MFWalkthroughViewController.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, MFWalkthroughDataSource, MFWalkthroughDelegate>

@property(strong, nonatomic) UIWindow *window;

@end
