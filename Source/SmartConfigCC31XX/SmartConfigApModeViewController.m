//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import "SmartConfigApModeViewController.h"

@interface SmartConfigApModeViewController ()

@end

@implementation SmartConfigApModeViewController

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

- (IBAction)nextButtonPressed:(id)sender {
    
    SmartConfigAPModePageViewController *pageViewController = (SmartConfigAPModePageViewController*) self.parentViewController;
    NSUInteger nextPage = [pageViewController.pages indexOfObject:self] + 1;
    
    [pageViewController setViewControllers:@[pageViewController.pages[nextPage]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){}];}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)openUrlPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://mysimplelink.net/setup.html"]];
}
@end
