//
//  NetworkBasicTestView.swift
//  DebugWifi
//
//  Created by Juan Carlos Moreno on 8/19/15.
//  Copyright (c) 2015 Juan C Moreno. All rights reserved.
//

import Foundation


class NetworkBasicTestView: UIView, NetworkDebugStatusDelegate
{

    @IBOutlet weak var state_label: UILabel!
    @IBOutlet weak var progressbar: MBCircularProgressBarView!
    @IBOutlet weak var rerun_button: UIButton!
    
    var original_frame: CGRect?
    
    var timer:NSTimer?
    var t_tmp = 0;
    var step_array = []
    var steps:[NetworkDebugStatus] = [HasWifi() , CheckIp(), PingGateway(),
        PingExternalIP(), PingGoogle()]
    var step_index:Int = 0


    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.addSubview(NSBundle.mainBundle().loadNibNamed("NetworkBasicTestView", owner: self, options: nil).first as! UIView)

        
        for step in steps
        {
            step.delegate = self
        }
        
        self.progressbar.emptyLineWidth = 1.0
        self.progressbar.progressLineWidth = 1.0
        self.progressbar.progressAngle = 60
        self.progressbar.progressRotationAngle = 0
        self.progressbar.percent = 0
        
        self.rerun_button.layer.borderColor = UIColor.redColor().CGColor
        self.rerun_button.layer.borderWidth = 1
        
        self.progressbar.layer.borderColor = UIColor.redColor().CGColor
        self.progressbar.layer.borderWidth = 1
        self.progressbar.backgroundColor = UIColor.redColor()

        println(self.subviews.first?.subviews)
        println(self.progressbar.frame)
        
    }
    
    
    
    @IBAction func rerun_test(sender: UIButton) {
        println("HERE")
        var new_frame = self.frame
        new_frame.size.height = self.frame.size.height + 300
        
        self.step_index = 0
        self.progressbar.percent = 0
        for step in self.steps
        {
            step.reset()
        }
        
        self.runNextStep()
        
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
                self.completeTest()
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
    
    func stepWillRun()
    {
    }
    
    func completeTest()
    {
        var time = dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(3 * Double(NSEC_PER_SEC))
        )//DISPATCH_TIME_NOW + (10000 * NSEC_PER_SEC)
        dispatch_after(
            time,
            dispatch_get_main_queue(),
            { () -> Void in
                self.state_label.text = NetworkDebug().getWifiNetwork()
        })
    }
    
    func setWifiNetwork()
    {
        self.state_label.text = NetworkDebug().getWifiNetwork()
    }
}