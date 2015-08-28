//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SmartConfigGlobalConfig.h"
#import "SmartConfigOOBPageViewController.h"

@interface SmartConfigSettingsViewController : UIViewController

@property (strong) SmartConfigGlobalConfig * globalSettings;

- (IBAction)switchChange:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *show_device_name;
@property (weak, nonatomic) IBOutlet UISwitch *open_device_list;
@property (weak, nonatomic) IBOutlet UISwitch *show_sc_pass;
@property (weak, nonatomic) IBOutlet UISwitch *enable_oob;
@property (weak, nonatomic) IBOutlet UILabel *buildLabel;

- (IBAction)brandButtonAction:(id)sender;
@property (strong) SmartConfigOOBPageViewController *oobTabViewController;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollViewContent;
@property (weak,nonatomic) UITabBarController *mainViewController;

- (IBAction)apProvisioningButtonClick:(id)sender;

@end
