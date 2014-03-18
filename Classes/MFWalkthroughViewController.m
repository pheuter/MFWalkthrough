//
//  MFWalkthroughViewController.m
//  Prand
//
//  Created by Mark Fayngersh on 3/15/14.
//  Copyright (c) 2014 Mark Fayngersh. All rights reserved.
//

#import "MFWalkthroughViewController.h"

#import <FRDLivelyButton/FRDLivelyButton.h>
#import <KVOController/FBKVOController.h>

@interface MFWalkthroughViewController () {
  NSArray *_viewControllers;
  FBKVOController *_KVOController;
  FRDLivelyButton *_backButton;
  FRDLivelyButton *_forwardButton;
}

@property(readwrite) NSInteger currentIndex;
@property(readonly) FBKVOController *KVOController;
@property(readonly) FRDLivelyButton *backButton;
@property(readonly) FRDLivelyButton *forwardButton;

typedef NS_ENUM(NSInteger, kMFWalkthroughDirection) {
  kMFWalkthroughDirectionForward,
  kMFWalkthroughDirectionBackward
};

@end
@implementation MFWalkthroughViewController

#pragma mark - Constructors
- (id)initWithViewControllers:(NSArray *)viewControllers {
  self = [super init];

  if (self) {
    _viewControllers = viewControllers;
  }

  return self;
}

#pragma mark - View Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];

  // Initialize navigation buttons
  self.navigationItem.leftBarButtonItem =
      [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithCustomView:self.forwardButton];
  self.navigationController.interactivePopGestureRecognizer.delegate =
      (id<UIGestureRecognizerDelegate>)self;

  // Display initial view controller
  [self displayInitialViewController];
}

- (void)viewWillAppear:(BOOL)animated {
  [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - KVO Actions

- (void)enableContinuePropertyDidChange:(NSDictionary *)change {
  BOOL isValid = [change[NSKeyValueChangeNewKey] boolValue];

  if (isValid) {
    [self.forwardButton setStyle:kFRDLivelyButtonStyleCaretRight animated:YES];
  } else {
    [self.forwardButton setStyle:kFRDLivelyButtonStyleClose animated:YES];
  }
}

#pragma mark - Container Methods

- (void)displayInitialViewController {
  self.currentIndex = 0;
  UIViewController *viewController = [self.viewControllers firstObject];

  viewController.view.frame = self.view.frame;
  self.title = viewController.title;

  [self addChildViewController:viewController];
  [self.view addSubview:viewController.view];
  [viewController didMoveToParentViewController:self];

  [self.KVOController
      observe:viewController
      keyPath:[self.dataSource walkthroughViewController:self
                  enableContinuePropertyForViewController:viewController]
      options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
       action:@selector(enableContinuePropertyDidChange:)];
}

- (void)cycleFromViewController:(UIViewController *)oldC
               toViewController:(UIViewController *)newC
                  withDirection:(kMFWalkthroughDirection)direction {
  [oldC willMoveToParentViewController:nil];
  [self addChildViewController:newC];

  newC.view.frame = [self newViewStartFrameWithDirection:direction];
  CGRect endFrame = [self oldViewEndFrameWithDirection:direction];

  [self transitionFromViewController:oldC
      toViewController:newC
      duration:0.25
      options:0
      animations:^{
          newC.view.frame = oldC.view.frame;
          oldC.view.frame = endFrame;
      }
      completion:^(BOOL finished) {
          [oldC removeFromParentViewController];
          [newC didMoveToParentViewController:self];
          self.title = newC.title;

          // Update KVOController observations
          [self.KVOController unobserve:oldC];
          [self.KVOController
              observe:newC
              keyPath:[self.dataSource walkthroughViewController:self
                          enableContinuePropertyForViewController:newC]
              options:NSKeyValueObservingOptionInitial |
                      NSKeyValueObservingOptionNew
               action:@selector(enableContinuePropertyDidChange:)];
      }];
}

- (CGRect)newViewStartFrameWithDirection:(kMFWalkthroughDirection)direction {
  if (direction == kMFWalkthroughDirectionForward) {
    return CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width,
                      self.view.frame.size.height);
  } else {
    return CGRectMake(-self.view.frame.size.width, 0,
                      self.view.frame.size.width, self.view.frame.size.height);
  }
}

- (CGRect)oldViewEndFrameWithDirection:(kMFWalkthroughDirection)direction {
  if (direction == kMFWalkthroughDirectionForward) {
    return CGRectMake(-self.view.frame.size.width, 0,
                      self.view.frame.size.width, self.view.frame.size.height);
  } else {
    return CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width,
                      self.view.frame.size.height);
  }
}

- (void)displayNextViewController {
  UIViewController<MFWalkthroughDataSource, MFWalkthroughDelegate> *
  currentViewController =
      [self.viewControllers objectAtIndex:self.currentIndex];
  UIViewController<MFWalkthroughDataSource, MFWalkthroughDelegate> *
  newViewController = [self.viewControllers objectAtIndex:++self.currentIndex];

  if ([self.delegate
          respondsToSelector:@selector(walkthroughViewController:
                                  willContinueFromViewController:
                                                toViewController:)]) {
    [self.delegate walkthroughViewController:self
              willContinueFromViewController:currentViewController
                            toViewController:newViewController];
  }

  [self cycleFromViewController:currentViewController
               toViewController:newViewController
                  withDirection:kMFWalkthroughDirectionForward];
}

- (void)displayPreviousViewController {
  UIViewController<MFWalkthroughDataSource> *currentViewController =
      [self.viewControllers objectAtIndex:self.currentIndex];
  UIViewController<MFWalkthroughDataSource> *newViewController =
      [self.viewControllers objectAtIndex:--self.currentIndex];

  if ([self.delegate
          respondsToSelector:@selector(walkthroughViewController:
                                    willGoBackFromViewController:
                                                toViewController:)]) {
    [self.delegate walkthroughViewController:self
                willGoBackFromViewController:currentViewController
                            toViewController:newViewController];
  }

  [self cycleFromViewController:currentViewController
               toViewController:newViewController
                  withDirection:kMFWalkthroughDirectionBackward];
}

#pragma mark - Getters

- (NSArray *)viewControllers {
  return _viewControllers;
}

- (FRDLivelyButton *)backButton {
  if (!_backButton) {
    _backButton =
        [[FRDLivelyButton alloc] initWithFrame:CGRectMake(0, 0, 36, 28)];
    [_backButton setStyle:kFRDLivelyButtonStyleCaretLeft animated:NO];
    [_backButton setOptions:@{
                              kFRDLivelyButtonLineWidth : @(3.0f),
                              kFRDLivelyButtonColor : [UIColor whiteColor]
                            }];
    [_backButton addTarget:self
                    action:@selector(goBack)
          forControlEvents:UIControlEventTouchUpInside];
  }

  return _backButton;
}

- (FRDLivelyButton *)forwardButton {
  if (!_forwardButton) {
    _forwardButton =
        [[FRDLivelyButton alloc] initWithFrame:CGRectMake(0, 0, 36, 28)];
    [_forwardButton setStyle:kFRDLivelyButtonStyleClose animated:NO];
    [_forwardButton setOptions:@{
                                 kFRDLivelyButtonLineWidth : @(3.0f),
                                 kFRDLivelyButtonColor : [UIColor whiteColor]
                               }];
    [_forwardButton addTarget:self
                       action:@selector(goForward:)
             forControlEvents:UIControlEventTouchUpInside];
  }

  return _forwardButton;
}

- (FBKVOController *)KVOController {
  if (!_KVOController) {
    _KVOController = [FBKVOController controllerWithObserver:self];
  }

  return _KVOController;
}

#pragma mark - Navigation Actions

- (void)goBack {
  if (self.currentIndex == 0) {
    UIViewController *firstViewController = self.viewControllers.firstObject;
    [self.delegate walkthroughViewController:self
           willGoBackFromFirstViewController:firstViewController];
  } else {
    [self displayPreviousViewController];
  }
}

- (void)goForward:(FRDLivelyButton *)forwardButton {
  if (self.currentIndex == self.viewControllers.count - 1) {
    UIViewController *lastViewController = self.viewControllers.lastObject;
    [self.delegate walkthroughViewController:self
          willContinueFromLastViewController:lastViewController];

    return;
  }

  if (forwardButton.buttonStyle == kFRDLivelyButtonStyleClose) {
    UIViewController<MFWalkthroughDelegate> *currentViewController =
        [self.viewControllers objectAtIndex:self.currentIndex];

    if ([self.delegate
            respondsToSelector:@selector(walkthroughViewController:
                                   couldNotContinueFromViewController:)]) {
      [self.delegate walkthroughViewController:self
            couldNotContinueFromViewController:currentViewController];
    }
  } else {
    [self displayNextViewController];
  }
}

@end
