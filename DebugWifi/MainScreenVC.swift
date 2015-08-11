//
//  MainScreenVC.swift
//  DebugWifi
//
//  Created by Juan Carlos Moreno on 8/11/15.
//  Copyright (c) 2015 Juan C Moreno. All rights reserved.
//

import Foundation


class MainScreenVC: UIViewController {
    var networkTest: UIViewController?
    var speedTest: UIViewController?
    
    @IBAction func loadNetworkTestAction(sender: AnyObject)
    {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        networkTest = storyboard.instantiateViewControllerWithIdentifier("NetworkTestVC") as? UIViewController
        self.presentViewController(networkTest!, animated: true, completion: { () -> Void in
            
        });
    }

    
    @IBAction func speedTestAction(sender: AnyObject)
    {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        networkTest = storyboard.instantiateViewControllerWithIdentifier("SpeedTestVC") as? UIViewController
        self.presentViewController(networkTest!, animated: true, completion: { () -> Void in
            
        });
    }

}