//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface SmartConfigGlobalConfig : NSObject {
    NSString *deviceName;
    NSString *scPass;
    NSString *ssidName;
    
}
@property(nonatomic,retain)NSDate *launchTime;

@property(nonatomic,retain)NSString *deviceName;
@property(nonatomic,retain)NSString *scPass;
@property(nonatomic,retain)NSString *ssidName;

    @property(nonatomic) BOOL showDeviceName;
    @property(nonatomic) BOOL openDeviceList;
    @property(nonatomic) BOOL showScPass;
    @property(nonatomic) BOOL enableOOB;
    @property(nonatomic) BOOL skipOOB;



+(SmartConfigGlobalConfig*)getInstance;

-(void) updateValues;

-(void) emptyDeviceList;
-(void) addDevice:(NSDictionary * )device withKey:(NSString *)key;
-(void) setValue:(BOOL)value forOption:(NSString*)name;

-(NSMutableDictionary*) getDevices;

@end

