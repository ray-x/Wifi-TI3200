//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import "SmartConfigTabBarControllerViewController.h"

@interface SmartConfigTabBarControllerViewController ()

@end

@implementation SmartConfigTabBarControllerViewController

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
	// Do any additional setup after loading the view.
    
    
    self.globalConfig = [SmartConfigGlobalConfig getInstance];
    int devicesTabIndex = 2;
    int smartConfigTabIndex = 1;

    NSMutableArray * vcs = [NSMutableArray
                            arrayWithArray:[self viewControllers]];
    self.oobPageViewController = [vcs objectAtIndex:0];
    
    if(self.globalConfig.enableOOB == NO) {
        // disable oob tab
        [vcs removeObjectAtIndex:0];
        [self setViewControllers:vcs];
        devicesTabIndex = 1;
        smartConfigTabIndex = 0;

        //[self.tabBar setItems]
    }
    
    
    // set devices as default tab
    if(self.globalConfig.openDeviceList) {
        [self setSelectedIndex:devicesTabIndex];

    }// else if skip oob and oob enabled
    else if(self.globalConfig.skipOOB) {
        // set default tab to smart config
        [self setSelectedIndex:smartConfigTabIndex];
        
    }
    
    
    // subscribe to tab change notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTab:) name:@"ChangeTabNotification" object:nil];

    
    NSLog(@"%@", self.globalConfig);
    
    
    

}

-(void) changeTab:(NSNotification*)notification
{
  
    [self setSelectedIndex:(int)[notification.userInfo objectForKey:@"tab"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
