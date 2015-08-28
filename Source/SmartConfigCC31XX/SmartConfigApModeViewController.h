//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SmartConfigAPModePageViewController.h"
#import "SmartConfigGlobalConfig.h"

@interface SmartConfigApModeViewController : UIViewController

@property (nonatomic, retain) SmartConfigGlobalConfig *globalConfig;

- (IBAction)nextButtonPressed:(id)sender;

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)openUrlPressed:(id)sender;

@end
