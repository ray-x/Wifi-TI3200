//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SmartConfigGlobalConfig.h"
#import "SmartConfigOOBPageViewController.h"

@interface SmartConfigTabBarControllerViewController : UITabBarController

    @property (nonatomic, retain) SmartConfigGlobalConfig *globalConfig;
@property (strong, retain) SmartConfigOOBPageViewController *oobPageViewController;

    
@end
