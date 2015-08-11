//
//  ObjCUtils.m
//  DebugWifi
//
//  Created by Juan Carlos Moreno on 7/21/15.
//  Copyright (c) 2015 Juan C Moreno. All rights reserved.
//
#include "ObjCUtils.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <Foundation/Foundation.h>
#include <net/if_dl.h>
#import <sys/sysctl.h>
#import <sys/socket.h>
#include <net/if.h>


#include "route.h"

#define ROUNDUP(a) \((a) > 0 ? (1 + (((a) - 1) | (sizeof(long) - 1))) : sizeof(long))

@implementation ObjCUtils 

+ (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+ (NSData *) ipStringToSockAddr: (NSString *) remote_addr
{
    //struct sockaddr *sa = (struct sockaddr *) malloc(sizeof(struct sockaddr *));
    //sa->sa_family = AF_INET;
    
    //struct sockaddr_in *sa_in = (struct sockaddr_in *) malloc(sizeof(struct sockaddr_in *));
    //struct in_addr *iadd = (struct in_addr *) malloc(sizeof(struct in_addr *));
    struct sockaddr_in sa_in;
    
    assert(inet_pton(AF_INET, [remote_addr cStringUsingEncoding:NSUTF8StringEncoding], &(sa_in.sin_addr))==1);
    //sa_in->sin_addr = *(iadd);
    
    struct sockaddr *sa = (struct sockaddr *) &sa_in;
    
    sa->sa_family = AF_INET;
    NSData *retval = [NSData dataWithBytes:sa length:sizeof(sa)];
    
    return retval;
}

+ (BOOL) isAddrInMySubnet: (NSString *) remote_addr
{
    NSString *local_addr = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    BOOL answer = NO;
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    local_addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    struct in_addr *netmask = &((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr;
                    struct in_addr *remote = (struct in_addr *)malloc(sizeof(struct in_addr *));
                    inet_aton([remote_addr cStringUsingEncoding:NSUTF8StringEncoding],  remote);
                    
                    struct in_addr *result = malloc(sizeof(struct in_addr *));
                    result->s_addr = remote->s_addr & netmask->s_addr;
                    
                    struct in_addr *local_w_mask = (struct in_addr *)malloc(sizeof(struct in_addr *));
                    local_w_mask->s_addr = ((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr.s_addr & netmask->s_addr;
                    if (local_w_mask->s_addr == result->s_addr)
                    {
                        
                        answer = YES;
                    }
                    
                    free(local_w_mask);
                    free(result);
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return answer;
}

@end

