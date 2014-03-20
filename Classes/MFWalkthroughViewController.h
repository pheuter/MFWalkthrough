//
//  MFWalkthroughViewController.h
//  MFWalkthrough
//
//  Created by Mark Fayngersh on 3/15/14.
//  Copyright (c) 2014 Mark Fayngersh. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MFWalkthroughDelegate;
@protocol MFWalkthroughDataSource;

@interface MFWalkthroughViewController : UIViewController

@property(nonatomic, weak) id<MFWalkthroughDelegate> delegate;
@property(nonatomic, weak) id<MFWalkthroughDataSource> dataSource;

/**
 *  Read-only property representing array of loaded view controllers
 */
@property(readonly) NSArray *viewControllers;

/**
 *  The color of the left, right and X buttons in the nav bar. Defaults to
 *  navigationBar.tintColor;
 */
@property(nonatomic) UIColor *navigationButtonColor;

/**
 *  The width of the lines used to render the navigation buttons. Defaults to
 *  3.0f.
 */
@property(nonatomic) CGFloat navigationButtonLineWidth;

/**
 *  Main initializer
 *
 *  @param viewControllers The array of view controllers that will be used in
 *  the walkthrough.
 *
 *  @return MFWalkthroughViewController instance
 */
- (id)initWithViewControllers:(NSArray *)viewControllers;

@end

@protocol MFWalkthroughDataSource <NSObject>

@required

/**
 *  Used by walkthrough controller to observe for changes and determine if
 *  continue is enabled.
 *
 *  @param walkthroughViewController MFWalkthroughViewController instance
 *  @param viewController            The view controller whose property will be
 *  observed
 *
 *  @return A string representing the property name on the viewController
 */
- (NSString *)walkthroughViewController:
                  (MFWalkthroughViewController *)walkthroughViewController
    enableContinuePropertyForViewController:(UIViewController *)viewController;

@end

@protocol MFWalkthroughDelegate <NSObject>

@optional

/**
 *  Occurs when the right bar button (continue) is tapped but
 *  enableContinuePropertyForViewController has a false value.
 *
 *  @param walkthroughViewController MFWalkthroughViewController instance
 *  @param currentViewController            The current view controller
 */
- (void)walkthroughViewController:
            (MFWalkthroughViewController *)walkthroughViewController
    couldNotContinueFromViewController:
        (UIViewController *)currentViewController;

/**
 *  Occurs when the right bar button (continue) is tapped and
 *  enableContinuePropertyForViewController has a true value. Called right
 *  before transition will take place.
 *
 *  @param walkthroughViewController MFWalkthroughViewController instance
 *  @param currentViewController     The current view controller
 *  @param newViewController         The next view controller that is about to
 *  be shown
 */
- (void)walkthroughViewController:
            (MFWalkthroughViewController *)walkthroughViewController
    willContinueFromViewController:(UIViewController *)currentViewController
                  toViewController:(UIViewController *)newViewController;

/**
 *  Just like willContinueFromViewController:toViewController:, but going back.
 *
 *  @param walkthroughViewController MFWalkthroughViewController instance
 *  @param currentViewController     The current view controller
 *  @param newViewController         The previous view controller that is about
 *  to be shown
 */
- (void)walkthroughViewController:
            (MFWalkthroughViewController *)walkthroughViewController
     willGoBackFromViewController:(UIViewController *)currentViewController
                 toViewController:(UIViewController *)newViewController;

@required

/**
 *  Occurs when the left bar button (back) is tapped on the very first view
 *  controller.
 *
 *  @param walkthroughViewController MFWalkthroughViewController instance
 *  @param firstViewController       The first view controller
 */
- (void)walkthroughViewController:
            (MFWalkthroughViewController *)walkthroughViewController
    willGoBackFromFirstViewController:(UIViewController *)firstViewController;

/**
 *  Occurs when the right bar button (continue) is tapped on the very last view
 *  controller.
 *
 *  @param walkthroughViewController MFWalkthroughViewController instance
 *  @param lastViewController        The last view controller
 */
- (void)walkthroughViewController:
            (MFWalkthroughViewController *)walkthroughViewController
    willContinueFromLastViewController:(UIViewController *)lastViewController;

@end
