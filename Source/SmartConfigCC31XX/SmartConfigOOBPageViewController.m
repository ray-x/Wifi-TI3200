//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import "SmartConfigOOBPageViewController.h"

@interface SmartConfigOOBPageViewController ()


@end

@implementation SmartConfigOOBPageViewController

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
    self.navigationController.navigationBar.topItem.title = @"Out of the Box";
    UIViewController *oob1 = [self.storyboard instantiateViewControllerWithIdentifier:@"OOBPage1"];
    UIViewController *oob2 = [self.storyboard instantiateViewControllerWithIdentifier:@"OOBPage2"];
//    UIViewController *oob3 = [self.storyboard instantiateViewControllerWithIdentifier:@"OOBPage3"];
    
    self.dataSource = self;
    
    self.pages = [NSMutableArray arrayWithObjects:oob1,oob2,nil];
    
}


- (void) viewWillAppear:(BOOL)animated
{
    [self setViewControllers:@[self.pages[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){}];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (nil == viewController) {
        return self.pages[0];
    }
    NSInteger idx = [self.pages indexOfObject:viewController];
    NSParameterAssert(idx != NSNotFound);
    if (idx >= [self.pages count] - 1) {
        // we're at the end of the _pages array
        return nil;
    }
    // return the next page's view controller
    return self.pages[idx + 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (nil == viewController) {
        return self.pages[0];
    }
    NSInteger idx = [self.pages indexOfObject:viewController];
    NSParameterAssert(idx != NSNotFound);
    if (idx <= 0) {
        // we're at the end of the _pages array
        return nil;
    }
    // return the previous page's view controller
    return self.pages[idx - 1];
}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pages count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pages indexOfObject:self.viewControllers[0]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
