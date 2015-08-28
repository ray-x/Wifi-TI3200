//
//  SmartConfigPrivacyPolicyViewController.m
//  Wi-Fi Starter
//
//  Created by Annie Yang on 2014-05-21.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import "SmartConfigPrivacyPolicyViewController.h"

@interface SmartConfigPrivacyPolicyViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;


@end

@implementation SmartConfigPrivacyPolicyViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.scalesPageToFit = YES;
    self.webView.scrollView.bounces = NO;
    [self setUpInitialData];
}

-(void)setUpInitialData{
    
    NSString *privacy = @"<body style=\"background-color:transparent;\"><font face=\"Helvetica\" color=\"black\" style=\"font-size:38\"> <p><br/><b>Texas Instruments (TI) Mobile Applications Privacy Policy</b><br/><br/>We don’t collect any user data.<br/><br/>We don’t store or share your precise location.<br/><br/>Use of social media services are governed by their respective terms of use and policies.<br/><br/>No personal data is stored or can be identified.<br/><br/><center><a href=\"http://www.ti.com/privacy\">Privacy Policy</a><br><br/></center></p></font></body>";
    
    [self.webView loadHTMLString:privacy baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
