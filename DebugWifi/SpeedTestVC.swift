//
//  ViewController.swift
//  DebugWifi
//
//  Created by Juan Carlos Moreno on 7/20/15.
//  Copyright (c) 2015 Juan C Moreno. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration.CaptiveNetwork

class SpeedTestVC: UIViewController, UICollectionViewDataSource,
                        UICollectionViewDelegate, ScanLANDelegate {
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var wifi_label: UILabel!
    @IBOutlet weak var scanNetworkButton: UIButton!
    
    var discovery: Discovery!
    var found_users: [AnyObject] = []
    var lanitems: [AnyObject] = []
    var lanscanner: ScanLAN!
    let uuid = "5E064AB7-9D77-48D9-B207-C98DAC24E267"
    var username = UIDevice.currentDevice().name;
    var is_scanning: Bool = false;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.collectionview.delegate = self;
        self.collectionview.dataSource = self;
        
        // Do any additional setup after loading the view, typically from a nib.
        let interfaces = CNCopySupportedInterfaces()
        if interfaces != nil {
            
            let interfacesArray = interfaces.takeRetainedValue() as! [String]

            if interfacesArray.count > 0 {
                
                let interfaceName = interfacesArray[0] as String
                
                let unsafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName)
                
                if unsafeInterfaceData != nil {
                    
                    let interfaceData = unsafeInterfaceData.takeRetainedValue() as Dictionary!
                    var ssid = interfaceData["SSID"] as! String
                    self.wifi_label.text = ssid
                    
                }
            }
        }
        
        print (CNCopyCurrentNetworkInfo(nil))
    }
    
    func scanLAN() -> Void
    {
        if (self.lanscanner == nil)
        {
            self.lanscanner = ScanLAN(delegate: self)
        }
        
        if (is_scanning == false)
        {
            self.scanNetworkButton.setTitle("Stop Scan", forState: UIControlState.Normal)
            self.lanscanner.startScan()
            is_scanning = true
        }
        else
        {
            self.scanNetworkButton.setTitle("Scan Network", forState: UIControlState.Normal)
            self.lanscanner.stopScan()
            is_scanning = false
        }
    }

    
    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int
    {
         return self.lanitems.count;
    }
    
    func scanLANDidFindNewAdrress(address: String!, havingHostName hostName: String!) {
        var device = Device()
        device.name = hostName
        device.address = address
        self.lanitems.append(device)
        self.collectionview.reloadData()
    }
    @IBAction func ScanLANButtonPressed(sender: AnyObject)
    {

        /*
        var ip = self.getIFAddresses().first!
        var user = ip + "," + username
        self.discovery = Discovery(UUID: CBUUID(string: self.uuid)!, username: user, usersBlock:{ (users, changed) -> Void in
            if(users.count>0 && changed)
            {
                self.found_users = users
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionview.reloadData()
                })
            }
        })
        */
        self.scanLAN()
    }
    
    
    func scanLANDidFinishScanning() {
        print ("Scan finished!")
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {

        var cell: NearbyDeviceCollectionViewCell = collectionview.dequeueReusableCellWithReuseIdentifier("NearbyDeviceCollectionViewCell", forIndexPath: indexPath) as! NearbyDeviceCollectionViewCell
        
        var device:Device = self.lanitems[indexPath.row] as! Device;
        
        //var raw_uname_data:[String] = raw_username.componentsSeparatedByString(",");
        cell.DeviceName.text = device.name;
        return cell;
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func findNearby(sender: AnyObject) {
        
        //Discovery.
        //label2.text = "Hello " + NSHost
        //label2.text = NSHost.currentHost()
        
    }
    
    
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

