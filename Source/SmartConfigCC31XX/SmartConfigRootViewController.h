//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "SmartConfigGlobalConfig.h"
#import "SmartConfigAPModePageViewController.h"
#import "SmartConfigDiscoverMDNS.h"

@interface SmartConfigRootViewController : UIViewController <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *wifiRequiredView;
@property (weak, nonatomic) IBOutlet UIView *detectionView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak,nonatomic) UITabBarController *mainViewController;

@property BOOL alertOpen;
@property (nonatomic, retain) SmartConfigGlobalConfig *globalConfig;
@property (strong, nonatomic) SmartConfigDiscoverMDNS *mdnsService;

@property (nonatomic, retain) Reachability *wifiReachability;
- (IBAction)apButtonAction:(id)sender;

@property (retain) NSTimer *updateTimer;


-(void) updateNetworkName;

-(void) wifiStatusChanged:(NSNotification *)notification;

- (void)detectWifi;

-(id)fetchSSIDInfo;

@end
