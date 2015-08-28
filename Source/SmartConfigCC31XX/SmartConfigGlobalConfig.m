//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import "SmartConfigGlobalConfig.h"

@implementation SmartConfigGlobalConfig

@synthesize deviceName;
@synthesize scPass;
@synthesize ssidName;
static SmartConfigGlobalConfig *instance =nil;

+(SmartConfigGlobalConfig *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            NSDictionary *userDefaultsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithBool:YES], @"show_device_name",
                                                  [NSNumber numberWithBool:NO], @"open_device_list",
                                                  [NSNumber numberWithBool:NO], @"show_sc_pass",
                                                  nil];
            [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
            
            
            
            instance= [SmartConfigGlobalConfig new];
            
            // temp empty device table
            NSMutableDictionary *devices = [[NSMutableDictionary alloc] init];
            [[NSUserDefaults standardUserDefaults] setObject:devices forKey:@"devices"];
            
        }
    }
    [instance updateValues];
    return instance;
}

-(void) emptyDeviceList
{
    NSMutableDictionary *devices = [[NSMutableDictionary alloc] init];
    [[NSUserDefaults standardUserDefaults] setObject:devices forKey:@"devices"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"devices"]);
}

-(void) updateValues
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.showDeviceName = [[NSUserDefaults standardUserDefaults] boolForKey:@"show_device_name"];
    self.openDeviceList = [[NSUserDefaults standardUserDefaults] boolForKey:@"open_device_list"];
    self.showScPass = [[NSUserDefaults standardUserDefaults] boolForKey:@"show_sc_pass"];
    self.enableOOB = [[NSUserDefaults standardUserDefaults] boolForKey:@"enable_oob"];
    self.skipOOB = [[NSUserDefaults standardUserDefaults] boolForKey:@"skip_oob"];

}

-(void) setValue:(BOOL)value forOption:(NSString*)name
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:name];
    [self updateValues];
    
}

-(void) addDevice:(NSDictionary * )device withKey:(NSString *)key
{
    NSMutableDictionary *devices = [self getDevices];
    
    [devices setValue:device forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:devices forKey:@"devices"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    
}

-(NSMutableDictionary*) getDevices {
    return[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"devices"] mutableCopy];
}


@end
