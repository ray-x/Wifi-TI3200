//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import "SmartConfigOOBPage1ViewController.h"

@interface SmartConfigOOBPage1ViewController ()

@end

@implementation SmartConfigOOBPage1ViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextButtonClicked:(id)sender {
    
    SmartConfigOOBPageViewController *pageViewController = (SmartConfigOOBPageViewController*) self.parentViewController;
    
    [pageViewController setViewControllers:@[pageViewController.pages[1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){}];
    
    
    
}
@end
