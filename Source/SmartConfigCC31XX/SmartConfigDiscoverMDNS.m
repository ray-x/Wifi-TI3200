//
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//


#import "SmartConfigDiscoverMDNS.h"

@implementation SmartConfigDiscoverMDNS
static SmartConfigDiscoverMDNS *instance =nil;

+(SmartConfigDiscoverMDNS *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            
            instance= [SmartConfigDiscoverMDNS new];
            instance.globalConfig = [SmartConfigGlobalConfig getInstance];
        }
    }
    return instance;
}

- (void) emptyMDNSList
{
    [self.globalConfig emptyDeviceList];
}


- (void) startMDNSDiscovery:(NSString*)deviceName {
    NSLog(@"Starting mDNS discovery with device name %@", deviceName);
    
    NSLog(@"Stop discovery prior to starting again");
    [self stopMDNSDiscovery];
    
    self.deviceName = deviceName;
    self.netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    [self.netServiceBrowser setDelegate:self];
    [self.netServiceBrowser searchForServicesOfType:@"_http._tcp" inDomain:@""];
}


-(void) stopMDNSDiscovery {
    NSLog(@"Stop mDNS discovery");

    [self.netServiceBrowser stop];
}

/* callback when found device */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    NSLog(@"Callback %s", __PRETTY_FUNCTION__);
    NSLog(@"%@ %@ %@ %@ %@", aNetService.name, aNetService.hostName, aNetService.addresses, aNetService.type, aNetService.domain);
    if (!self.netServices) {
        self.netServices = [[NSMutableArray alloc] init];
    }
    [self.netServices addObject:aNetService];
    
    [[self.netServices objectAtIndex:([self.netServices count] -1)] setDelegate:self];
    
    [[self.netServices objectAtIndex:([self.netServices count] -1)] resolveWithTimeout:20.0];
    
    // rest of logic is in the resolve callback
    
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    NSLog(@"Callback %s", __PRETTY_FUNCTION__);
    NSLog(@"%@", sender);
    NSLog(@"%@", errorDict);
}

- (void)netServiceWillPublish:(NSNetService *)sender
{
    NSLog(@"Callback %s", __PRETTY_FUNCTION__);
    NSLog(@"%@", sender);
    
}

- (void)netServiceWillResolve:(NSNetService *)sender
{
    NSLog(@"Callback %s", __PRETTY_FUNCTION__);
    NSLog(@"%@", sender);
    
}

- (void)netServiceDidStop:(NSNetService *)sender {
    NSLog(@"Callback %s", __PRETTY_FUNCTION__);
    NSLog(@"%@", sender);
    
}

// logic after the service was resolved, here we add it to devices
- (void)netServiceDidResolveAddress:(NSNetService *)aNetService {
    NSLog(@"Callback %s", __PRETTY_FUNCTION__);
    
    // split by @ to get the device name
    NSArray* serviceNameParts = [aNetService.name componentsSeparatedByString: @"@"];
    NSLog(@"%@ %@ %@ %@ %@", aNetService.name, aNetService.hostName, aNetService.addresses, aNetService.type, aNetService.domain);
    
    // GET DEVICE INFO
    NSString *key = aNetService.name;
    NSDictionary *device = [NSMutableDictionary dictionaryWithCapacity:3];
    NSString *address = [self resolveAddress:aNetService.addresses];
    NSDictionary *dataDict = [NSNetService dictionaryFromTXTRecordData:aNetService.TXTRecordData];
    NSString *srcvers = @"";
    if(dataDict != nil && [dataDict valueForKey:@"srcvers"] != nil)
    {
        srcvers = [[NSString alloc] initWithData:[dataDict valueForKey:@"srcvers"] encoding:NSUTF8StringEncoding];
    }
    
    NSString *expectedSrcvers = @"1D90645";
    
    // if device name exists and the device name equals to the service that we discovered
    // or device name is blank and srcvers is equal to vers
    BOOL foundDevice =  ([self.deviceName length]
                         && [ [serviceNameParts objectAtIndex:([serviceNameParts count] - 1)] isEqualToString:self.deviceName ])
    || (![self.deviceName length] && [srcvers length] && [srcvers isEqualToString:expectedSrcvers]);
    //    [self.deviceName.text length] &&
    if([serviceNameParts count] > 0 && foundDevice)
    {
        
        [device setValue:aNetService.name forKey:@"name"];
        NSDate *now = [NSDate date];
        [device setValue:now forKey:@"date"];
        [device setValue:address forKey:@"url"];
        
        // set recent flag if device name exists and we added it from smartconfig
        if([self.deviceName length])
        {
            [device setValue:[NSNumber numberWithBool:YES] forKey:@"recent"];
        }
        else
        {
            [device setValue:[NSNumber numberWithBool:NO] forKey:@"recent"];
            
        }
        
        int deviceCount = [[self.globalConfig getDevices] count];
        
        [self.globalConfig addDevice:device withKey:key];
        
        // check if we have more than one device
        if([[self.globalConfig getDevices] count] > deviceCount) {
            // a new device was added
            [self deviceWasAdded];
        }
        
    }
    
}


-(NSString*) resolveAddress:(NSArray*)addresses {
    NSLog(@"Callback %s", __PRETTY_FUNCTION__);
    char addressBuffer[INET6_ADDRSTRLEN];
    NSString *address;
    for (NSData *data in addresses)
    {
        memset(addressBuffer, 0, INET6_ADDRSTRLEN);
        
        typedef union {
            struct sockaddr sa;
            struct sockaddr_in ipv4;
            struct sockaddr_in6 ipv6;
        } ip_socket_address;
        
        ip_socket_address *socketAddress = (ip_socket_address *)[data bytes];
        
        if (socketAddress && (socketAddress->sa.sa_family == AF_INET || socketAddress->sa.sa_family == AF_INET6))
        {
            const char *addressStr = inet_ntop(
                                               socketAddress->sa.sa_family,
                                               (socketAddress->sa.sa_family == AF_INET ? (void *)&(socketAddress->ipv4.sin_addr) : (void *)&(socketAddress->ipv6.sin6_addr)),
                                               addressBuffer,
                                               sizeof(addressBuffer));
            
            int port = ntohs(socketAddress->sa.sa_family == AF_INET ? socketAddress->ipv4.sin_port : socketAddress->ipv6.sin6_port);
            
            if (addressStr && port)
            {
                address = [NSString stringWithFormat:@"http://%s:%d", addressStr, port];
            }
        }
    }
    
    return address;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didNotSearch:(NSDictionary *)errorInfo
{
    NSLog(@"Callback %s", __PRETTY_FUNCTION__);
    NSLog(@"%@", errorInfo);
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)netServiceBrowser {
    NSLog(@"Callback %s", __PRETTY_FUNCTION__);
    NSLog(@"%@", netServiceBrowser);
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindDomain:(NSString *)domainName moreComing:(BOOL)moreDomainsComing {
    NSLog(@"Callback %s", __PRETTY_FUNCTION__);
    
    NSLog(@"%@", domainName);
    
}


- (void) deviceWasAdded {
    NSLog(@"Callback %s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceFound" object:self];
}



@end
