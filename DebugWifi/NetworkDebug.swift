//
//  NetworkDebug.swift
//  DebugWifi
//
//  Created by Juan Carlos Moreno on 8/4/15.
//  Copyright (c) 2015 Juan C Moreno. All rights reserved.
//

import Foundation


class NetworkDebug: NSObject, SimplePingDelegate
{
    var defaultGateway:String = "0.0.0.0"
    var pinger:SimplePing = SimplePing()
    
    override init() {
        super.init()
    }
    
    
    func getDefaultGateway() -> String
    {
        var cr = CustomRoute()
        var arr:NSArray = CustomRoute.getRoutes()
        var potential_gateways: [AnyObject] = [];
        var gatewayIP: String = "0.0.0.0"
        
        for route in arr
        {
            if route.getDestination() == "default"
            {
                potential_gateways.append(route.getGateway())
            }
        }
        
        if potential_gateways.count == 0
        {
            return gatewayIP
        }
        else if potential_gateways.count  == 1
        {
            gatewayIP = potential_gateways[0] as! String;
        }
        else
        {
            for item in potential_gateways
            {
                if(ObjCUtils.isAddrInMySubnet(item as! String))
                {
                    gatewayIP = item as! String
                    break
                }
            }
            
            if gatewayIP == "0.0.0.0"
            {
                gatewayIP = potential_gateways[0] as! String;
            }
        }
        
        return gatewayIP;
    }
    
    
// MARK: Lower level functions
    
    func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
            for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
                let flags = Int32(ptr.memory.ifa_flags)
                var addr = ptr.memory.ifa_addr.memory
                
                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
    
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                                if let address = String.fromCString(hostname) {
                                    addresses.append(address)
                                }
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return addresses
    }
    
}


