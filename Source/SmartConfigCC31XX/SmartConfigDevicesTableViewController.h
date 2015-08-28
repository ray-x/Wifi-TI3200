//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SmartConfigDiscoverMDNS.h"

@interface SmartConfigDevicesTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSMutableDictionary *devices;
@property (nonatomic, retain) NSMutableDictionary *recentDevices;


@property (atomic, retain) SmartConfigDiscoverMDNS *mdnsService;

@property (nonatomic, retain) NSTimer *refreshTimer;


- (void)stopRefresh:(id)sender;


@end
