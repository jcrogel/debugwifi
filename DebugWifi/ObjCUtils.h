//
//  ObjCUtils.h
//  DebugWifi
//
//  Created by Juan Carlos Moreno on 7/21/15.
//  Copyright (c) 2015 Juan C Moreno. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef DebugWifi_ObjCUtils_h
#define DebugWifi_ObjCUtils_h

@interface ObjCUtils : NSObject

+ (NSString *)getIPAddress;
+ (BOOL) isAddrInMySubnet: (NSString *) remote_addr;
+ (NSData *) ipStringToSockAddr: (NSString *) remote_addr;

@end

#endif
