//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import <UIKit/UIKit.h>
#include <arpa/inet.h>
#import "Reachability.h"
#import "SmartConfigGlobalConfig.h"
#import "SmartConfigDiscoverMDNS.h"
#import "FirstTimeConfig.h"


@interface SmartConfigSCViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate>
extern int const MDNSRestartTime;

@property (weak, nonatomic) IBOutlet UIView *deviceNameBG;

@property (weak, nonatomic) IBOutlet UIView *scPassBG;


@property ( nonatomic) FirstTimeConfig *firstTimeConfig;
@property (nonatomic) BOOL discoveryInProgress;
@property (retain, atomic) IBOutlet UITextField *ssid;
@property (retain, atomic) IBOutlet UITextField *apPass;
@property (retain, atomic) IBOutlet UITextField *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameDesc;

@property (weak, nonatomic) IBOutlet UIImageView *eyeImage;

@property (weak, atomic) IBOutlet UITextField *debugField;



@property (retain, atomic) IBOutlet UITextField *scPass;
@property (retain, atomic) IBOutlet UILabel *scPassLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;

@property (retain, atomic) NSData *freeData;
@property (retain, atomic) NSString *passwordKey;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
    @property (weak, nonatomic) IBOutlet UILabel *ssidWarning;
    @property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@property (nonatomic, retain) Reachability *wifiReachability;


@property (nonatomic) SmartConfigDiscoverMDNS *mdnsService;

@property (weak, nonatomic) id ssidInfo;
@property (retain, atomic) SmartConfigGlobalConfig *globalConfig;

@property (nonatomic) BOOL modifiedSSID;
    

@property (weak, nonatomic) NSTimer *mdnsTimer;
@property (weak, nonatomic) NSTimer *updateTimer;
@property (weak, nonatomic) NSTimer *discoveryTimer;
    
    @property int progressTime;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

/* button action, where we need to start or stop the request
 @param: button ... tag value defines the action
 */
- (IBAction)buttonAction:(UIButton*)button;
- (IBAction)cancelAction:(UIButton*)button;

-(void) updateDeviceInfo;

-(BOOL)textFieldShouldReturn:(UITextField*)textField;


@end
