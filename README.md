# MFWalkthrough

[![Version](http://cocoapod-badges.herokuapp.com/v/MFWalkthrough/badge.png)](http://cocoadocs.org/docsets/MFWalkthrough)
[![Platform](http://cocoapod-badges.herokuapp.com/p/MFWalkthrough/badge.png)](http://cocoadocs.org/docsets/MFWalkthrough)

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

## Demo

![Demo](https://dl.dropboxusercontent.com/u/1803181/MFWalkthroughDemoOptimized.gif)

## Requirements

## Installation

MFWalkthrough is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "MFWalkthrough", "~> 0.1.0"

## Author

Mark Fayngersh, phunny.phacts@gmail.com

## License

MFWalkthrough is available under the MIT license. See the LICENSE file for more info.
