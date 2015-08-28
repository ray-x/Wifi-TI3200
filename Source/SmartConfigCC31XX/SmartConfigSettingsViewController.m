//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import "SmartConfigSettingsViewController.h"
#import "SmartConfigTabBarControllerViewController.h"

@interface SmartConfigSettingsViewController ()

@end

@implementation SmartConfigSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"Settings";
    self.buildLabel.text = @"Build 0.20 June 10th 2014";

    self.globalSettings = [SmartConfigGlobalConfig getInstance];
    
    self.show_device_name.on = self.globalSettings.showDeviceName;
    self.open_device_list.on = self.globalSettings.openDeviceList;
    self.show_sc_pass.on = self.globalSettings.showScPass;
    self.enable_oob.on = self.globalSettings.enableOOB;
    

   
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewDidLayoutSubviews
{
    // configure scrolling
    self.scrollView.contentSize = self.scrollViewContent.frame.size;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)switchChange:(id)sender {
    if([sender isEqual:self.show_device_name])
    {
        [self.globalSettings setValue:self.show_device_name.on forOption:@"show_device_name"];
    }
    else if([sender isEqual:self.open_device_list])
    {
        [self.globalSettings setValue:self.open_device_list.on forOption:@"open_device_list"];
        
    }
    else if([sender isEqual:self.show_sc_pass])
    {
        [self.globalSettings setValue:self.show_sc_pass.on forOption:@"show_sc_pass"];
        
    }
    else if([sender isEqual:self.enable_oob])
    {
        [self.globalSettings setValue:self.enable_oob.on forOption:@"enable_oob"];
        NSMutableArray *tbViewControllers = [NSMutableArray arrayWithArray:[self.tabBarController viewControllers]];
        SmartConfigTabBarControllerViewController *tabBar = (SmartConfigTabBarControllerViewController*) self.tabBarController;
        
        if(self.enable_oob.on)
        {
            [tbViewControllers insertObject:tabBar.oobPageViewController atIndex:0];
        }
        else
        {
            tabBar.oobPageViewController = [tbViewControllers objectAtIndex:0];
            [tbViewControllers removeObjectAtIndex:0];
        }
        [self.tabBarController setViewControllers:tbViewControllers];
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"main_embed"]) {
        self.mainViewController = [segue destinationViewController];
    }
}

- (IBAction)brandButtonAction:(id)sender {
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.panda-os.com"]];
}
- (IBAction)apProvisioningButtonClick:(id)sender {
    int devicesTabIndex = 2;
    if(self.globalSettings.enableOOB == NO) {
        devicesTabIndex = 1;
    }

    [self.mainViewController setSelectedIndex:devicesTabIndex];
    [self performSegueWithIdentifier:@"settingsApMode" sender:self];
    
}
@end
