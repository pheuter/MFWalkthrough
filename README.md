# MFWalkthrough

[![Build Status](https://travis-ci.org/pheuter/MFWalkthrough.svg?branch=master)](https://travis-ci.org/pheuter/MFWalkthrough)
[![Version](http://cocoapod-badges.herokuapp.com/v/MFWalkthrough/badge.png)](http://cocoadocs.org/docsets/MFWalkthrough)

## Blog post

[MFWalkthrough: A Container View Controller for iOS](http://blog.markfayngersh.com/mfwalkthrough-container-view-controller-for-ios)

## Installation

MFWalkthrough is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "MFWalkthrough", "~> 0.0.2"

## Demo

You can find the sample project in **Example/WalkthroughDemo**.

![Demo](https://dl.dropboxusercontent.com/u/1803181/MFWalkthroughDemo.gif)

## Usage

### Display walkthrough containing 3 view controllers

- `MFWalkthroughDataSource` - Used to determine what property to observe to enable transitions
- `MFWalkthroughDelegate` - React to various transitions and states

```objective-c
#import <MFWalkthrough/MFWalkthroughViewController.h>

@interface ViewController : UIViewController <MFWalkthroughDataSource, MFWalkthroughDelegate>
```

In the implementation,

```objective-c
// Initialize your view controllers
UIViewController *firstController;
UIViewController *secondController;
UIViewController *lastController;

// Create the MFWalkthroughViewController instance
MFWalkthroughViewController *walkthroughController =
      [[MFWalkthroughViewController alloc]
          initWithViewControllers:@[ firstController, secondController, lastController ]];

// Present the walkthrough controller
[self.navigationController pushViewController:walkthroughController
                                       animated:YES];
```

Required data source method:

```objective-c
- (NSString *)walkthroughViewController:(MFWalkthroughViewController *)walkthroughViewController enableContinuePropertyForViewController:(UIViewController *)viewController {
  return @"somePropertyThatDeterminesIfContinueIsEnabled";
}
```

Required delegate methods:

```objective-c
- (void)walkthroughViewController:(MFWalkthroughViewController *)walkthroughViewController willGoBackFromFirstViewController:(UIViewController *)firstViewController {
  NSLog(@"I'm at the very beginning!");
}

- (void)walkthroughViewController:(MFWalkthroughViewController *)walkthroughViewController willContinueFromLastViewController:(UIViewController *)lastViewController {
  NSLog(@"I'm at the very end!");
}
```

The following delegate methods are optional:

- `- (void)walkthroughViewController:couldNotContinueFromViewController:`
- `- (void)walkthroughViewController:willContinueFromViewController:toViewController:`
- `- (void)walkthroughViewController:willGoBackFromViewController:toViewController:`

Refer to source documentation for more detail

## Customization

MFWalkthrough is designed to be used in conjunction with UINavigationController, simplifying conditional transitions between view controllers depending on some intermediate state.

[FRDLivelyButton](https://github.com/sebastienwindal/FRDLivelyButton) is used to render the navigation buttons. You can customize the button colors and line widths via the following `MFWalkthroughViewController` properties:

- `(UIColor *)navigationButtonColor` - Defaults to `navigationBar.tintColor`
- `(CGFloat)navigationButtonLineWidth` - Defaults to `3.0f`

## Testing

To run the unit tests:

    $ cd Example
    $ make install
    $ make ci

## Author

Mark Fayngersh, phunny.phacts@gmail.com

## License

MFWalkthrough is available under the MIT license. See the LICENSE file for more info.
