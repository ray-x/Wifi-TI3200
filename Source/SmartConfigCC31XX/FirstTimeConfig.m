//
//  FirstTimeConfig.m
//  Dummy TI FirstTimeConfig implementation for the iOS simulator
//
//  Copyright (c) 2015 Julien Vanier.
//  This file is release in the public domain

#if TARGET_IPHONE_SIMULATOR

#import <Foundation/Foundation.h>
#import "FirstTimeConfig.h"

@implementation OSFailureException : NSException

@end

@implementation FirstTimeConfig : NSObject

/* The following procedure can throw an OSFailureException exception */
- (id)init {
    return [super init];
}

/* The following procedure can throw an OSFailureException exception */
- (id)initWithKey:(NSString *)Key {
    return [super init];
}

/* The following procedure can throw an OSFailureException exception */
- (id)initWithKey:(NSString *)Key withEncryptionKey:(NSData *)encryptionKey {
    return [super init];
}

/* The following procedure can throw an OSFailureException exception */
- (id)initWithData:(NSString *)Ip withSSID:(NSString *)Ssid withKey:(NSString *)Key withEncryptionKey:(NSData *)EncryptionKey numberOfSetups:(int)numOfSetups numberOfSyncs:(int)numOfSyncs syncLength1:(int)lSync1 syncLength2:(int)lSync2 delayInMicroSeconds:(useconds_t)uDelay {
    return [super init];
}

/* The following procedure can throw an OSFailureException exception */
- (void)stopTransmitting {
}

/* The following procedure can throw an OSFailureException exception */
- (void)transmitSettings {
    
}

/* The following procedure can throw an OSFailureException exception */
- (bool)waitForAck {
    return NO;
}

- (bool)isTransmitting {
    return NO;
}

- (void)setDeviceName:(const NSString *)deviceName {
    
}

+ (NSString *)getSSID {
    return @"test_ssid";
}

+ (NSString *)getGatewayAddress {
    return @"10.0.0.1";
}

@end

#endif