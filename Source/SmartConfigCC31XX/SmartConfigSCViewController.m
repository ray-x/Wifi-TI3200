//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import "SmartConfigSCViewController.h"
#import "FirstTimeConfig.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

int const discoveryTimeout = 60;

int const MDNSRestartTime = 15;

@implementation SmartConfigSCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"Smart Config";

    [self detectWifi];

    
    self.discoveryInProgress = NO;
    
    self.modifiedSSID = NO;
    self.ssidWarning.hidden = YES;
    
	// Do any additional setup after loading the view, typically from a nib.

    self.globalConfig = [SmartConfigGlobalConfig getInstance];
    
   
    
    // init mdns service
    self.mdnsService = [SmartConfigDiscoverMDNS getInstance];
    
    // dismiss keyboard handler
    UIGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    self.navigationItem.title = @"Device Configuration";
   
    NSLog(@"Smart Config View Loaded");
    //    [tableView setBackgroundColor:[UIColor clearColor]];


    // hide scPassword field if disabled

    
    // monitor ssid change
    [self.ssid addTarget:self action:@selector(ssidDidChange) forControlEvents:UIControlEventEditingChanged];

    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateParameters) userInfo:nil repeats:YES];
    
    // add notification for discovered device
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceAdded:)
                                                 name:@"deviceFound"
                                               object:nil];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    self.eyeImage.userInteractionEnabled = YES;
    [self.eyeImage addGestureRecognizer:singleTap];
    
    
    
}

-(void)tapDetected{
    
    self.apPass.secureTextEntry = !self.apPass.secureTextEntry;
    
}


// callback for text fields to limit characters and track changes
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // limit ap password field to 32 characters
    if(self.apPass == textField) {
        NSUInteger newLength = [self.apPass.text length] + [string length] - range.length;
        return (newLength > 32) ? NO : YES;
    }
    // limit key field to 32 characters
    else if(self.scPass == textField) {
        NSUInteger newLength = [self.scPass.text length] + [string length] - range.length;
        return (newLength > 32) ? NO : YES;
    }
    // limit device name to 24 characters and filter by aplhanumeric characters only
    else if(self.deviceName == textField) {
//        NSCharacterSet *blockedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        NSString *allowedRegex = @"[A-Za-z0-9-]*";
        NSPredicate *allowedTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", allowedRegex];

        BOOL allowed = [allowedTest evaluateWithObject:string];
        
//        bool inRange = [string rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound;
        NSUInteger newLength = [self.deviceName.text length] + [string length] - range.length;
        return (newLength > 24) || !allowed ? NO : YES;
    }
    else

    {
        return YES;
    }
}


// check for internet and initiate the libary object for further transmit.
-(void) connectLibrary
{
    
    self.debugField.text = @"";
    
    @try {
        [self disconnectFromLibrary];
        
        self.passwordKey = [self.apPass.text length] ? self.apPass.text : nil;
        NSString *paddedEncryptionKey = self.scPass.text;

        NSData *encryptionData = [self.scPass.text length] ? [paddedEncryptionKey dataUsingEncoding:NSUTF8StringEncoding] : Nil;
        
        self.freeData = [NSData alloc];
        if([self.deviceName.text length])
        {
            char freeDataChar[[self.deviceName.text length] + 3];
            // prefix
            freeDataChar[0] = 3;
            
            // device name length
            freeDataChar[1] = [self.deviceName.text length];
            
            for(int i = 0; i < [self.deviceName.text length]; i++)
            {
                freeDataChar[i+2] = [self.deviceName.text characterAtIndex:i];
            }
            
            // added terminator
            freeDataChar[[self.deviceName.text length] + 2] = '\0';
            
            NSString *freeDataString = [[NSString alloc] initWithCString:freeDataChar encoding:NSUTF8StringEncoding];
            NSLog(@"free data char %s", freeDataChar);
            self.freeData = [freeDataString dataUsingEncoding:NSUTF8StringEncoding ];
            
        }
        else
        {
            self.freeData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
        }
        
//        self.debugField.text = [[NSString alloc] initWithData:freeData encoding:NSUTF8StringEncoding];
        NSString *ipAddress = [FirstTimeConfig getGatewayAddress];
        self.firstTimeConfig = [[FirstTimeConfig alloc] initWithData:ipAddress withSSID:self.ssid.text withKey:self.
                                passwordKey withFreeData:self.freeData withEncryptionKey:encryptionData numberOfSetups:4 numberOfSyncs:10 syncLength1:3 syncLength2:23 delayInMicroSeconds:1000];
        
        [self mDnsDiscoverStart];
        // set timer to fire mDNS after 15 seconds
        self.mdnsTimer = [NSTimer scheduledTimerWithTimeInterval:MDNSRestartTime target:self selector:@selector(mDnsDiscoverStart) userInfo:nil repeats:NO];

        
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s exception == %@",__FUNCTION__,[exception description]);
        [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:[exception description] waitUntilDone:NO];
    }
    
}


// disconnect libary method involves to release the existing object and assign nil.
-(void) disconnectFromLibrary
{
    
    //    if (updateTimer) {
    //        if([updateTimer isValid]) {
    //            [updateTimer invalidate];
    //            updateTimer= nil;
    //        }
    //    }
    self.firstTimeConfig = nil;
}


-(void) ssidDidChange
{
    NSLog(@"%@", self.ssid.text);
    NSLog(@"%@", self.globalConfig.ssidName);

    if( [self.ssid.text isEqualToString:self.globalConfig.ssidName] )
    {
        self.modifiedSSID = NO;
        self.ssidWarning.hidden = YES;
    }
    else
    {
        self.modifiedSSID = YES;
        self.ssidWarning.hidden = NO;
    }
}
    
-(void) updateDeviceInfo {
    self.globalConfig = [SmartConfigGlobalConfig getInstance];
    self.deviceName.text = self.globalConfig.deviceName;
    self.scPass.text = self.globalConfig.scPass;
}
    
-(void) updateParameters
{
    if(!self.modifiedSSID) {
        self.ssid.text = self.globalConfig.ssidName;
    }
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"Smart Config View Will Appear");
    [self updateParameters];
    //initData
    [self.globalConfig updateValues];
    // hide scPassword field if disabled
    
   
    if(!self.globalConfig.showScPass) {
        self.scPass.hidden = YES;
        self.scPassLabel.hidden = YES;
        self.scPassBG.hidden = YES;
    } else {
        self.scPass.hidden = NO;
        self.scPassLabel.hidden = NO;
        self.scPassBG.hidden = NO;
    }
    
    if(!self.globalConfig.showDeviceName) {
        self.deviceName.hidden = YES;
        self.deviceNameLabel.hidden = YES;
        self.deviceNameDesc.hidden = YES;
        self.deviceNameBG.hidden = YES;
    } else {
        self.deviceName.hidden = NO;
        self.deviceNameLabel.hidden = NO;
        self.deviceNameDesc.hidden = NO;
        self.deviceNameBG.hidden = NO;
    }
    
   
}


                                          
/*!!!!!!
 This is the button action, where we need to start or stop the request
 @param: button ... tag value defines the action !!!!!!!!!
 !!!*/
- (IBAction)buttonAction:(UIButton*)button{

    // detect if we have wifi reachability
    NetworkStatus netStatus = [self.wifiReachability currentReachabilityStatus];
    
    if ( netStatus != ReachableViaWiFi )
    { // No activity if no wifi
        NSLog(@"No Wifi");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No WiFi detected"
                                                        message:@"Switch to AP Provisioning?"
                                                       delegate:self
                                              cancelButtonTitle:@"YES"
                                              otherButtonTitles:@"NO", nil];
        [alert setTag:2];
        [alert show];
        
    }
    else if([self.apPass.text length] == 0) // password is empty
    {
        NSLog(@"Password is empty");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No AP Password entered"
                                                        message:@"Do you want to continue?"
                                                       delegate:self
                                              cancelButtonTitle:@"YES"
                                              otherButtonTitles:@"NO", nil];
        [alert setTag:1];
        [alert show];
        
    }
    else
    {
        [self continueStartAction:button];
    }
    
}


- (void) continueStartAction:(UIButton*)button{
    
        self.discoveryInProgress = YES;
        
        // hide button
        button.hidden = YES;
        self.cancelButton.hidden = NO;
        
        // stop UI interaction
        //    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        // show progress bar
        self.progressBar.hidden = NO;
        self.progressTime = 0;
        self.discoveryTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        [self startTransmitting];
    // start discovery using TI lib
}

/**
    This is the cancel action
 
 */
- (IBAction)cancelAction:(UIButton*)button {
    [self stopDiscovery];
}


/*
 This method start the transmitting the data to connected
 AP. Nerwork validation is also done here. All exceptions from
 library is handled.
 */
- (void)startTransmitting{
    @try {
        [self connectLibrary];
        if (self.firstTimeConfig == nil) {
            return;
        }
        [self sendAction];
  
        // no longer needed
//        [NSThread detachNewThreadSelector:@selector(waitForAckThread:) toTarget:self
//                               withObject:nil];
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s exception == %@",__FUNCTION__,[exception description]);
        [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:[exception description] waitUntilDone:NO];
        
    }
    @finally {
    }
}

/*
 This method begins configuration transmit
 In case of a failure the method throws an OSFailureException.
 */
-(void) sendAction{
    @try {
        NSLog(@"%s begin", __PRETTY_FUNCTION__);
        [self.firstTimeConfig transmitSettings];
        NSLog(@"%s end", __PRETTY_FUNCTION__);
    }
    @catch (NSException *exception) {
        NSLog(@"exception === %@",[exception description]);
        [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:[exception description] waitUntilDone:NO];
    }
    @finally {
        
    }
}
    
-(void)updateProgress {
    self.progressTime ++;
    self.progressBar.progress = (float) self.progressTime / discoveryTimeout;
    if(self.progressTime >= discoveryTimeout) {
        [self discoveryTimedOut];
    }
    
}
    
    
    /* timeout discovery */
-(void) discoveryTimedOut {
    [self stopDiscovery];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Configuration process timed out."
                                                    message:@"Switch to AP Provisioning?"
                                                   delegate:self
                                          cancelButtonTitle:@"YES"
                                          otherButtonTitles:@"NO", nil];
    [alert show];
}

-(void) stopDiscovery {
    [self.mdnsTimer invalidate];
    self.discoveryInProgress = NO;
//    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [self.firstTimeConfig stopTransmitting];
    self.progressBar.hidden = YES;
    self.startButton.hidden = NO;
    self.cancelButton.hidden = YES;
    self.progressBar.progress = 0;
    [self.discoveryTimer invalidate];
    [self mDnsDiscoverStop];

    
}
    
#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:
(NSInteger)buttonIndex{
    int devicesTabIndex = 2;
    if(self.globalConfig.enableOOB == NO) {
        devicesTabIndex = 1;
    }
    
    if(alertView.tag == 1) // password popup
    {
        switch (buttonIndex) {
            case 0:
                NSLog(@"Yes button clicked");
                
                [self continueStartAction:self.startButton];
                
                break;
            case 1:
                NSLog(@"No button clicked");
                break;
                
            default:
                break;
        }
        
    }
    else if (alertView.tag == 2) // ap mode popup
    {
        switch (buttonIndex) {
            case 0:
                NSLog(@"Yes button clicked");
                
                [self.tabBarController setSelectedIndex:devicesTabIndex];
                [self performSegueWithIdentifier:@"openApMode" sender:self];
                
                break;
            case 1:
                NSLog(@"No button clicked");
                break;
                
            default:
                break;
        }
    }
    

}
    
    
/* handler for leaving the text page */
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
    {
        [self.view endEditing:YES];
}


/**
 MDNS Discovery 
 */



- (void) mDnsDiscoverStart {
    [self.mdnsService startMDNSDiscovery:self.deviceName.text];
}

- (void) mDnsDiscoverStop {
    [self.mdnsService stopMDNSDiscovery];
    
}



/**
 handler for next text field
 **/
-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        UITextField *nextTextField = (UITextField*) nextResponder;
        if(nextTextField.hidden == NO)
        {
            [nextResponder becomeFirstResponder];
            
        }
        else
        {
                // try to go to the next field
                nextTag++;
                UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
                if (nextResponder) {
                    UITextField *nextTextField = (UITextField*) nextResponder;
                    if(nextTextField.hidden == NO)
                    {
                        [nextResponder becomeFirstResponder];
                        
                    }
                    else
                    {
                        // remove the keyboard
                        [textField resignFirstResponder];
                    }
                    // Found next responder, so set it.
                }
                else
                {
                    
                    // remove the keyboard
                    [textField resignFirstResponder];
                    
                }
        }
        // Found next responder, so set it.
    }
    else
    {
        
            // remove the keyboard
            [textField resignFirstResponder];
        

    }
    return NO; // We do not want UITextField to insert line-breaks.
}

-(void)deviceAdded:(id)sender
{
    if(self.discoveryInProgress == YES)
    {
        [self stopDiscovery];
        [self alertWithMessage:@"A new device was discovered. Please go to the Devices tab to access your device"];
    }
}



-(void) alertWithMessage :( NSString *) message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SimpleLink Notification" message:message delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark wifi reachability
- (void)detectWifi
{
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiStatusChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    
    [self.wifiReachability connectionRequired];
	[self.wifiReachability startNotifier];
    
    NetworkStatus netStatus = [self.wifiReachability currentReachabilityStatus];
    NSLog(@"Net Status: %d", netStatus);
    
}


@end
