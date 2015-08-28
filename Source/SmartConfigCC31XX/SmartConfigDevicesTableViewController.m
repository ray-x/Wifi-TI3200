//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import "SmartConfigDevicesTableViewController.h"
#import "SmartConfigGlobalConfig.h"

@implementation SmartConfigDevicesTableViewController


- (void)viewWillAppear:(BOOL)animated {
    self.tableView.rowHeight = 70.0;
    [super viewDidAppear:animated];
    
    NSLog(@"Devices view will appear");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"Devices view did appear");

    // setup pull to refresh
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    //    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    
    [refresh addTarget:self action:@selector(refreshMDNS) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
}



- (void)viewDidLoad
{
    self.tableView.rowHeight = 70.0;
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"Devices";

    
    [self populateDevicesList];

    // setup statusbar
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        
//        self.tableView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
    }
    
    [NSTimer scheduledTimerWithTimeInterval:5
                                                      target:self selector:@selector(refreshTable)
                                                    userInfo:nil repeats:YES];
    

    self.mdnsService = [SmartConfigDiscoverMDNS getInstance];
}


- (void)populateDevicesList
{
    self.recentDevices = [[NSMutableDictionary alloc] init];
    self.devices = [[NSMutableDictionary alloc] init];
//    bool recent;
    SmartConfigGlobalConfig *globalConfig = [SmartConfigGlobalConfig getInstance];
    NSMutableDictionary *devices = [globalConfig getDevices];
//    NSDate *date;
//    NSDate *afterInitialLaunch = [globalConfig.launchTime dateByAddingTimeInterval:30];
//    NSDate *now = [NSDate date];

    
    for(id key in devices) {
        NSMutableDictionary *device = [devices objectForKey:key];
        BOOL recent = [[device objectForKey:@"recent"] boolValue];
        if(recent == YES) {
            if(self.recentDevices == nil) {
                self.recentDevices = [[NSMutableDictionary alloc] initWithObjectsAndKeys:device,key,nil];
            } else {
                [self.recentDevices setObject:device forKey:key];
            }
        } else {
            if(self.devices == nil) {
                self.devices = [[NSMutableDictionary alloc] initWithObjectsAndKeys:device,key,nil];
            } else {
                [self.devices setObject:device forKey:key];
            }
            
        }
        
    }
    
    [self.tableView reloadData];


}

- (void) refreshTable {
    [self populateDevicesList];

}


- (void)stopRefresh:(id)sender

{
    [self.refreshControl endRefreshing];
    self.refreshTimer = nil;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 0) {
        return [self.recentDevices count];
    }
    else {
        return [self.devices count];
    }
}
    
    
    

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // open safari page
    int section = indexPath.section;
    NSMutableDictionary *device;
    NSString *key;
    if(section == 0) {
        key = [self.recentDevices allKeys][indexPath.row];
        device = [self.recentDevices objectForKey:key];
    }
    else {
        key = [self.devices allKeys][indexPath.row];
        device = [self.devices objectForKey:key];
    }
    
    cell.textLabel.text = [device objectForKey:@"name"];
    cell.imageView.image = [UIImage imageNamed:@"Devices"];
    
    // Configure the cell...
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // open safari page
    int section = indexPath.section;
    NSMutableDictionary *device;
    NSString *key;
    if(section == 0) {
        key = [self.recentDevices allKeys][indexPath.row];
        device = [self.recentDevices objectForKey:key];
    }
    else {
        key = [self.devices allKeys][indexPath.row];
        device = [self.devices objectForKey:key];
    }

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[device objectForKey:@"url"]]];

    
}
    
    
    
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
    {
        if(section == 0) {
            return @"Recently Added";
        } else {
            return @"Devices";
        }
    }



//#pragma mark scroll delegates and load more entries
//- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
//    CGPoint offset = aScrollView.contentOffset;
//    CGRect bounds = aScrollView.bounds;
//    CGSize size = aScrollView.contentSize;
//    UIEdgeInsets inset = aScrollView.contentInset;
//    float y = offset.y + bounds.size.height - inset.bottom;
//    float h = size.height;
//    // NSLog(@"offset: %f", offset.y);
//    // NSLog(@"content.height: %f", size.height);
//    // NSLog(@"bounds.height: %f", bounds.size.height);
//    // NSLog(@"inset.top: %f", inset.top);
//    // NSLog(@"inset.bottom: %f", inset.bottom);
//    // NSLog(@"pos: %f of %f", y, h);
//    
//    float reload_distance = -20;
//    if(h > 0 && y > h + reload_distance) {
//        [self refreshMDNS];
//    }
//}


- (void) refreshMDNS
{
    [self populateDevicesList];
    [self.mdnsService emptyMDNSList];
    [self refreshTable];
    [self.mdnsService startMDNSDiscovery:@"" ];
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:8.0 target:self selector:@selector(stopRefresh:) userInfo:nil repeats:NO];


}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
