//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import "SmartConfigOOBPage2ViewController.h"

@interface SmartConfigOOBPage2ViewController ()
    
    @end

@implementation SmartConfigOOBPage2ViewController
    
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"OOB Page 2");
    // Do any additional setup after loading the view.
    
    self.zBarView.readerDelegate = self;
    
    // you can use this to support the simulator
    if(TARGET_IPHONE_SIMULATOR) {
        self.cameraSim = [[ZBarCameraSimulator alloc]
                          initWithViewController: self];
        self.cameraSim.readerView = self.zBarView;
    }
    
    
    self.successView.hidden = YES;
    
}
    
    
- (void) viewDidAppear: (BOOL) animated {
    // run the reader when the view is visible
    [self.zBarView start];
    self.successView.hidden = YES;
    
}
    
- (void) viewWillDisappear: (BOOL) animated {
    [self.zBarView stop];
    self.successView.hidden = YES;
}
    
    
    
- (void) readerView: (ZBarReaderView*) view
     didReadSymbols: (ZBarSymbolSet*) syms
          fromImage: (UIImage*) img  {
    // do something useful with results
    for(ZBarSymbol *sym in syms) {
        NSLog(@"QR Data %@", sym.data);
        NSError *localError = nil;
        
        NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:[sym.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&localError];
        
        if (localError != nil) {
            NSLog(@"%@", localError);
        }
        
        if([self validateQRData:parsedData])
        {
            [self.zBarView stop];
            self.successView.hidden = NO;
            self.globalConfig = [SmartConfigGlobalConfig getInstance];
            self.globalConfig.deviceName = [parsedData objectForKey:@"name"];
            self.globalConfig.scPass = [[parsedData objectForKey:@"keys"] objectForKey:@"0"];
            
            [self setSkipOOB:YES];
            
//            NSArray *vcs = [self.tabBarController viewControllers];
            SmartConfigSCViewController *smartConfigViewController = (SmartConfigSCViewController*) [self backViewController];
            
            [smartConfigViewController updateDeviceInfo];
            
            break;
        }
    }
    
}


- (UIViewController *)backViewController
{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    
    if (numberOfViewControllers < 2)
        return nil;
    else
        return [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
}

    // validate all necessary fields
    
- (BOOL) validateQRData:(NSDictionary*)data {
    BOOL valid = YES;
    
    NSDictionary *keys = [data objectForKey:@"keys"];
    NSString *ver = [data objectForKey:@"ver"];
    NSString *vid = [data objectForKey:@"vid"];
    NSString *pid = [data objectForKey:@"pid"];
    NSString *dgst = [data objectForKey:@"dgst"];
    
    
    if( keys == nil || [keys count] == 0 || [[keys objectForKey:@"0"] length] == 0)
    {
        valid = NO;
    }
    
    
    if(!ver)
    {
        valid = NO;
    }
    
    if(!vid)
    {
        valid = NO;
    }

    
    if(!pid)
    {
        valid = NO;
    }

    if(!dgst)
    {
        valid = NO;
    }
    
    
    return valid;
}
    
    
- (void) setSkipOOB:(BOOL)value {
    
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:@"skip_oob"];
}

    
    
//    
//- (IBAction)nextButtonClicked:(id)sender {
//    /* go to Smart Config Tab */
//    UITabBarController *tabBarController = self.tabBarController;
//    [tabBarController setSelectedIndex:1];
//    
//    
//    
//}

-(void)closeMyself {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


/* close the modal */
- (IBAction)nextButtonClicked:(id)sender {
    [self closeMyself];
    
    
}


- (IBAction)skipOOBChanged:(UISwitch *)sender {
    [self setSkipOOB:(BOOL)sender.on];
}
    
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
    @end
