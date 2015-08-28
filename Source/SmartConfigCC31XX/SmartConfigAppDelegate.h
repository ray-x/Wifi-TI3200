//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SmartConfigDiscoverMDNS.h"

@interface SmartConfigAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, atomic) SmartConfigDiscoverMDNS *mdnsService;

@end
