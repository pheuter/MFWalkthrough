//
//  WalkthroughDemoTests.m
//  WalkthroughDemoTests
//
//  Created by Mark Fayngersh on 3/18/14.
//  Copyright (c) 2014 Mark Fayngersh. All rights reserved.
//

#import <Specta/Specta.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import "ViewController.h"
#import <MFWalkthrough/MFWalkthroughViewController.h>
#import <FRDLivelyButton/FRDLivelyButton.h>

SpecBegin(MFWalkthrough)

describe(@"MFWalkthroughViewController", ^{
    __block ViewController *firstViewController;
    __block ViewController *secondViewController;
    __block ViewController *lastViewController;

    __block id<MFWalkthroughDelegate> delegate =
        mockProtocol(@protocol(MFWalkthroughDelegate));
    __block id<MFWalkthroughDataSource> dataSource =
        mockProtocol(@protocol(MFWalkthroughDataSource));

    __block UINavigationController *navigationController;
    __block MFWalkthroughViewController *walkthroughController;

    before(^{
        firstViewController = [[ViewController alloc] init];
        firstViewController.title = @"First";

        secondViewController = [[ViewController alloc] init];
        secondViewController.title = @"Second";

        lastViewController = [[ViewController alloc] init];
        lastViewController.title = @"Last";

        walkthroughController = [[MFWalkthroughViewController alloc]
            initWithViewControllers:@[
                                      firstViewController,
                                      secondViewController,
                                      lastViewController
                                    ]];
        navigationController = [[UINavigationController alloc]
            initWithRootViewController:walkthroughController];

        [given([dataSource walkthroughViewController:walkthroughController
             enableContinuePropertyForViewController:firstViewController])
            willReturn:@"isValid"];
        [given([dataSource walkthroughViewController:walkthroughController
             enableContinuePropertyForViewController:secondViewController])
            willReturn:@"isValid"];
        [given([dataSource walkthroughViewController:walkthroughController
             enableContinuePropertyForViewController:lastViewController])
            willReturn:@"isValid"];

        walkthroughController.delegate = delegate;
        walkthroughController.dataSource = dataSource;

        // By accessing the view property, we kick off the loadView process
        walkthroughController.view;
    });

    it(@"should initialize with view controllers",
       ^{ expect(walkthroughController.viewControllers).to.haveCountOf(3); });

    it(@"should have proper default values", ^{
        expect(walkthroughController.navigationButtonColor)
            .to.equal(navigationController.navigationBar.tintColor);
        expect(walkthroughController.navigationButtonLineWidth).to.equal(3.0f);
    });

    it(@"should set navigation controller title",
       ^{ expect(navigationController.title).to.equal(@"First"); });

    it(@"should call dataSource method for property name", ^{
        [verify(dataSource) walkthroughViewController:walkthroughController
              enableContinuePropertyForViewController:firstViewController];
    });

    it(@"should call delegate method for going back from first view controller",
       ^{
        FRDLivelyButton *backButton =
            (FRDLivelyButton *)
            walkthroughController.navigationItem.leftBarButtonItem.customView;
        [backButton sendActionsForControlEvents:UIControlEventTouchUpInside];

        [verify(delegate) walkthroughViewController:walkthroughController
                  willGoBackFromFirstViewController:firstViewController];
    });

    it(@"should fail transition to second view controller", ^{
        FRDLivelyButton *continueButton =
            (FRDLivelyButton *)
            walkthroughController.navigationItem.rightBarButtonItem.customView;
        [continueButton
            sendActionsForControlEvents:UIControlEventTouchUpInside];

        [verifyCount(delegate, never())
                 walkthroughViewController:walkthroughController
            willContinueFromViewController:firstViewController
                          toViewController:secondViewController];

        [verify(delegate) walkthroughViewController:walkthroughController
                 couldNotContinueFromViewController:firstViewController];
    });

    it(@"should react to property change and transition to second view "
       @"controller",
       ^AsyncBlock {
      FRDLivelyButton *continueButton =
          (FRDLivelyButton *)
          walkthroughController.navigationItem.rightBarButtonItem.customView;

      expect(continueButton.buttonStyle).to.equal(kFRDLivelyButtonStyleClose);
      firstViewController.isValid = YES;
      expect(continueButton.buttonStyle)
          .to.equal(kFRDLivelyButtonStyleCaretRight);

      [continueButton sendActionsForControlEvents:UIControlEventTouchUpInside];

      [verifyCount(delegate, never())
                   walkthroughViewController:walkthroughController
          couldNotContinueFromViewController:firstViewController];

      [verify(delegate) walkthroughViewController:walkthroughController
                   willContinueFromViewController:firstViewController
                                 toViewController:secondViewController];

      // Wait for transition animation to finish
      dispatch_after(
          dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
          dispatch_get_main_queue(), ^{
              expect(navigationController.title).to.equal(@"Second");
              done();
          });
    });

    it(@"should go back from second to first view controller", ^AsyncBlock {
      FRDLivelyButton *backButton =
          (FRDLivelyButton *)
          walkthroughController.navigationItem.leftBarButtonItem.customView;
      FRDLivelyButton *continueButton =
          (FRDLivelyButton *)
          walkthroughController.navigationItem.rightBarButtonItem.customView;

      firstViewController.isValid = YES;
      [continueButton sendActionsForControlEvents:UIControlEventTouchUpInside];

      dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                   (int64_t)(0.5 * NSEC_PER_SEC)),
                     dispatch_get_main_queue(), ^{
          expect(navigationController.title).to.equal(@"Second");
          [backButton sendActionsForControlEvents:UIControlEventTouchUpInside];

          [verify(delegate) walkthroughViewController:walkthroughController
                         willGoBackFromViewController:secondViewController
                                     toViewController:firstViewController];

          dispatch_after(
              dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
              dispatch_get_main_queue(), ^{
                  expect(navigationController.title).to.equal(@"First");
                  done();
              });
      });
    });

    it(@"should call delegate method for continuing from last view controller",
       ^AsyncBlock {
      FRDLivelyButton *continueButton =
          (FRDLivelyButton *)
          walkthroughController.navigationItem.rightBarButtonItem.customView;
      firstViewController.isValid = secondViewController.isValid = YES;

      [continueButton sendActionsForControlEvents:UIControlEventTouchUpInside];

      dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                   (int64_t)(0.5 * NSEC_PER_SEC)),
                     dispatch_get_main_queue(), ^{
          [continueButton
              sendActionsForControlEvents:UIControlEventTouchUpInside];

          dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                       (int64_t)(0.5 * NSEC_PER_SEC)),
                         dispatch_get_main_queue(), ^{
              expect(navigationController.title).to.equal(@"Last");

              [continueButton
                  sendActionsForControlEvents:UIControlEventTouchUpInside];

              [verify(delegate) walkthroughViewController:walkthroughController
                       willContinueFromLastViewController:lastViewController];

              done();
          });
      });
    });
});

SpecEnd