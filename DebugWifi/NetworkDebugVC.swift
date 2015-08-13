//
//  NetworkDebugVC.swift
//  DebugWifi
//
//  Created by Juan Carlos Moreno on 8/4/15.
//  Copyright (c) 2015 Juan C Moreno. All rights reserved.
//

import Foundation
import UIKit
import Foundation
import SystemConfiguration.CaptiveNetwork

class NetworkDebugVC: UIViewController,
                        NetworkDebugStatusDelegate{
    
    @IBOutlet weak var progressbar: MBCircularProgressBarView!
    
    @IBOutlet weak var state_label: UILabel!
    
    var timer:NSTimer?
    var t_tmp = 0;
    var step_array = []
    var steps:[NetworkDebugStatus] = [HasWifi() , CheckIp(), PingGateway(),
                                    PingExternalIP(), PingGoogle()]
    var step_index:Int = 0
    
    
    @IBAction func rerun_test(sender: UIButton) {
        self.step_index = 0
        self.progressbar.percent = 0
        for step in steps
        {
            step.reset()
        }
        
        self.runNextStep()
    }
    
    @IBAction func dismiss_vc(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    override func viewDidAppear(animated: Bool) {
        self.runNextStep()
    }
    
    override func viewDidLoad() {
        
        for step in steps
        {
            step.delegate = self
        }
        
        self.progressbar.emptyLineWidth = 1.0
        self.progressbar.progressLineWidth = 1.0
        self.progressbar.progressAngle = 60
        self.progressbar.progressRotationAngle = 0
        self.progressbar.percent = 0
        
    }
    
    func _runStep() -> Void
    {
        self.state_label.text = self.steps[step_index].step_label
        self.steps[step_index].run()
    }
    
    
    func runNextStep() -> Void
    {
        if (step_index != self.steps.count)
        {
            self.steps[step_index].delegate = self
            self.timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.2), target: self, selector: Selector("_runStep"), userInfo: nil, repeats: false)
        }
    }
    
    func stepHasCompleted()->Void
    {
        if self.steps[step_index].status == true
        {
            self.progressbar.percent += CGFloat(100 / self.steps.count);
            self.step_index++
            
            if (self.step_index == self.steps.count)
            {
                self.state_label.text = "Success!"
            }
            else
            {
                var time = DISPATCH_TIME_NOW + (1000 * NSEC_PER_SEC)
                dispatch_after(
                    time,
                    dispatch_get_main_queue(),
                    { () -> Void in
                        self.runNextStep()
                })
            }
        }
    }
    
    func stepWillRun()->Void
    {
    
    }
    
}

