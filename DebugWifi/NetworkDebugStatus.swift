//
//  NetworkDebugStatus.swift
//  DebugWifi
//
//  Created by Juan Carlos Moreno on 8/11/15.
//  Copyright (c) 2015 Juan C Moreno. All rights reserved.
//

import Foundation

protocol NetworkDebugStatusDelegate: NSObjectProtocol
{
    func stepHasCompleted()->Void;
    func stepWillRun()->Void;
}


class NetworkDebugStatus: NSObject
{
    var step_label:String = ""
    var status:Bool = false
    var complete: Bool = false
    var delegate:NetworkDebugStatusDelegate?
    
    func run() -> Void
    {
        self.complete = false
        self.delegate?.stepWillRun()
        self._run();
    }
    
    func reset() -> Void
    {
    
    }
    
    func _run() -> Void
    {
        
    }
}

class HasWifi: NetworkDebugStatus
{
    
    override init()
    {
        super.init()
        self.step_label = "Is Wifi On"
    }
    
    override func _run()->Void
    {
        let reachability: Reachability = Reachability.reachabilityForInternetConnection()
        var isWifi:Bool = reachability.currentReachabilityStatus().value == ReachableViaWiFi.value
        self.status = false
        
        if  isWifi
        {
            self.status = true
        }
        
        self.complete = true
        self.delegate?.stepHasCompleted()
    }
}


class CheckIp: NetworkDebugStatus
{
    override init()
    {
        super.init()
        self.step_label = "Has IP"
    }
    
    override func _run()->Void
    {
        var address:String = ObjCUtils.getIPAddress()
        self.status = true
        
        if address == "error"
        {
            self.status = false
        }
        self.complete = true
        self.delegate?.stepHasCompleted()
    }
}

class PingStatus: NetworkDebugStatus, SimplePingDelegate
{
    var pinger:SimplePing!
    
    override func reset() -> Void{
        self.pinger = nil
    }
    
    func simplePing(pinger: SimplePing!, didSendPacket packet: NSData!) {
    }
    
    func simplePing(pinger: SimplePing!, didStartWithAddress address: NSData!) {
        pinger.sendPingWithData(nil)
    }
    
    func simplePing(pinger: SimplePing!, didReceivePingResponsePacket packet: NSData!) {
        self.status = true
        self.complete = true
        //self.pinger.stop()
        self.delegate?.stepHasCompleted()
    }
    
    func simplePing(pinger: SimplePing!, didFailToSendPacket packet: NSData!, error: NSError!) {
        self.status = false
        self.complete = true
        //self.pinger.stop()
        self.delegate?.stepHasCompleted()
    }
}

class PingExternalIP: PingStatus
{
    override init()
    {
        super.init()
        self.step_label = "Pinging External IP"
    }
    
    override func _run() ->Void
    {
        if (pinger == nil)
        {
            var gwipData: NSData = ObjCUtils.ipStringToSockAddr("8.8.8.8")
            pinger = SimplePing(hostAddress: gwipData)
        }

        pinger.delegate = self;
        
        pinger.start()
    }
}


class PingGateway: PingStatus
{
    override init()
    {
        super.init()
        self.step_label = "Pinging Gateway"
    }
    
    override func _run() ->Void
    {
        if (pinger == nil)
        {
            var nd: NetworkDebug = NetworkDebug()
            var gwipData: NSData = ObjCUtils.ipStringToSockAddr(nd.getDefaultGateway())
            
            pinger = SimplePing(hostAddress: gwipData)
        }
        
        pinger.delegate = self;
        
        pinger.start()
    }
}

class PingGoogle: PingStatus
{
    override init()
    {
        super.init()
        self.step_label = "Pinging Google"
    }
    
    override func _run() ->Void
    {
        if (pinger == nil)
        {
            self.pinger = SimplePing(hostName: "www.google.com")
            self.pinger.delegate = self
        }
        
        pinger.start()
    }
    
}