//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ZBarSDK/ZBarSDK.h"
#import "ZBarReaderView.h"
#import "SmartConfigOOBPageViewController.h"
#import "SmartConfigSCViewController.h"
#import "SmartConfigGlobalConfig.h"


@interface SmartConfigOOBPage2ViewController : UIViewController <ZBarReaderViewDelegate>

@property (weak, nonatomic) IBOutlet ZBarReaderView *zBarView;
@property (weak, nonatomic) NSString *resultText;
@property (nonatomic) ZBarCameraSimulator *cameraSim;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, atomic) SmartConfigGlobalConfig *globalConfig;
@property (weak, nonatomic) IBOutlet UIView *successView;

- (IBAction)nextButtonClicked:(id)sender;
- (IBAction)skipOOBChanged:(UISwitch *) sender;

@end
