//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import "SmartConfigRootViewController.h"

@interface SmartConfigRootViewController ()

@end

@implementation SmartConfigRootViewController

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
    self.wifiRequiredView.hidden = YES;
    
    self.alertOpen = NO;

    self.mainView.hidden = NO;

    self.globalConfig = [SmartConfigGlobalConfig getInstance];
    
    

    [self detectWifi];
    
    // start MDNS discovery
    self.mdnsService = [SmartConfigDiscoverMDNS getInstance];
    [self.mdnsService startMDNSDiscovery:@""];

    
}


- (void)detectWifi
{
    
    self.mainView.hidden = NO;
    self.loadingView.hidden = YES;
    self.wifiRequiredView.hidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiStatusChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    
    [self.wifiReachability connectionRequired];
	[self.wifiReachability startNotifier];
    /// retain is just for safety
    
    //    [gidButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    //    [gidButton setTitle:@"GID" forState:UIControlStateNormal];
    
    NetworkStatus netStatus = [self.wifiReachability currentReachabilityStatus];
    NSLog(@"Net Status: %d", netStatus);
    
    // show or hide main view
    [self checkWifiReachibility:netStatus];

    self.activityIndicator.hidden = YES;
    
    [self updateNetworkName];


    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateNetworkName) userInfo:nil repeats:YES];

}


/*
 Notification method handler when status of wifi changes
 @param the fired notification object
 */
- (void)wifiStatusChanged:(NSNotification *)notification{

    NSLog(@"%s", __func__);
    NSLog(@"%@", notification);
    Reachability *verifyConnection = [notification object];
    NSAssert(verifyConnection != NULL, @"currentNetworkStatus called with NULL verifyConnection Object");
    NetworkStatus netStatus = [verifyConnection currentReachabilityStatus];
    NSLog(@"New net Status: %d", netStatus);
    
    // show or hide main view
    [self checkWifiReachibility:netStatus];
    [self updateNetworkName];
    
    //    NSLog(@"ssid %@, gatewayAddress %@", [[Reachability alloc] , [FirstTimeConfig getGatewayAddress]);
    
    //[wifiReachability stopNotifier];
    
    // [wifiReachability performSelector:@selector(startNotifier) withObject:nil afterDelay:3.0];
    
}

- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    //    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        //        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
  //  NSLog(@"Network info: %@", info);
    return info;
}

- (IBAction)apButtonAction:(id)sender {

    
}

- (void) checkWifiReachibility:(int)netStatus
{
    if ( netStatus != ReachableViaWiFi && !self.alertOpen ) { // No activity if no wifi
        NSLog(@"No Wifi");
        self.alertOpen = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No WiFi detected"
                                                        message:@"Switch to AP Provisioning?"
                                                       delegate:self
                                              cancelButtonTitle:@"YES"
                                              otherButtonTitles:@"NO", nil];
        [alert show];
        
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"main_embed"]) {
        self.mainViewController = [segue destinationViewController];
    }
}

#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:
(NSInteger)buttonIndex{
    int devicesTabIndex = 2;
    if(self.globalConfig.enableOOB == NO) {
        devicesTabIndex = 1;
    }
    
    switch (buttonIndex) {
        case 0:
            NSLog(@"Yes button clicked");
            
            [self.mainViewController setSelectedIndex:devicesTabIndex];
            [self performSegueWithIdentifier:@"rootApModeSegue" sender:self];
            
            break;
        case 1:
            NSLog(@"No button clicked");
            break;
            
        default:
            break;
    }
    
    self.alertOpen = NO;
}


- (void)showHideMainView:(int)netStatus
{
    if ( netStatus != ReachableViaWiFi ) { // No activity if no wifi
        NSLog(@"No Wifi");
        self.loadingView.hidden = NO;
        self.mainView.hidden = YES;
        self.wifiRequiredView.hidden = NO;
        
        
    } else {
        // remove detection view
        NSLog(@"Wifi Detected");
        self.mainView.hidden = NO;
        self.loadingView.hidden = YES;
        self.wifiRequiredView.hidden = YES;
        
        
    }
}


- (void)updateNetworkName
{
    id ssidInfo = [self fetchSSIDInfo];
    id ssidName = [ssidInfo objectForKey:@"SSID"];
    if(![self.globalConfig.ssidName isEqual:ssidName])
    {
        self.globalConfig.ssidName = ssidName;
        NSLog(@"Setting new SSID Name: %@", self.globalConfig.ssidName);
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
