//
//  ViewController.m
//  WalkthroughDemo
//
//  Created by Mark Fayngersh on 3/18/14.
//  Copyright (c) 2014 Mark Fayngersh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
  UISwitch *_switchView;
}

@property(readonly) UISwitch *switchView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.view addSubview:self.switchView];
  [self.view addConstraint:[NSLayoutConstraint
                               constraintWithItem:self.switchView
                                        attribute:NSLayoutAttributeCenterX
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self.view
                                        attribute:NSLayoutAttributeCenterX
                                       multiplier:1
                                         constant:0]];
  [self.view addConstraint:[NSLayoutConstraint
                               constraintWithItem:self.switchView
                                        attribute:NSLayoutAttributeCenterY
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self.view
                                        attribute:NSLayoutAttributeCenterY
                                       multiplier:1
                                         constant:0]];
}

#pragma mark - Getters

- (UISwitch *)switchView {
  if (!_switchView) {
    _switchView = [[UISwitch alloc] init];
    _switchView.translatesAutoresizingMaskIntoConstraints = NO;
    _switchView.tintColor = [UIColor redColor];
    [_switchView addTarget:self
                    action:@selector(switchWasToggled:)
          forControlEvents:UIControlEventValueChanged];
  }

  return _switchView;
}

#pragma mark - Actions

- (void)switchWasToggled:(UISwitch *)switchView {
  self.isValid = switchView.on;
}

- (void)shakeAnimation {
  CABasicAnimation *animation =
      [CABasicAnimation animationWithKeyPath:@"position"];
  [animation setDuration:0.08];
  [animation setRepeatCount:2];
  [animation setAutoreverses:YES];
  [animation
      setFromValue:
          [NSValue valueWithCGPoint:CGPointMake(self.switchView.center.x - 5.0f,
                                                self.switchView.center.y)]];
  [animation
      setToValue:[NSValue valueWithCGPoint:CGPointMake(
                                               self.switchView.center.x + 5.0f,
                                               self.switchView.center.y)]];
  [self.switchView.layer addAnimation:animation forKey:@"position"];
}

@end
