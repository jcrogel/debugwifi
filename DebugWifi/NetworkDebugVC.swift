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
                        UITableViewDataSource,
                        UITableViewDelegate,
                        NetworkDebugStatusDelegate{
    
    @IBOutlet weak var statusTable: UITableView!
    @IBOutlet weak var progressbar: MBCircularProgressBarView!
    
    
    var timer:NSTimer?
    var t_tmp = 0;
    var step_array = []
    var steps:[NetworkDebugStatus] = [HasWifi() , CheckIp(), PingGateway(),
                                    PingExternalIP(), PingGoogle()]
    var step_index:Int = 0
    
    
    @IBAction func rerun_test(sender: UIButton) {
        self.step_index = 0
        for step in steps
        {
            step.reset()
        }
        
        self.statusTable.reloadData()
        self.runNextStep()
    }
    
    @IBAction func dismiss_vc(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    override func viewDidAppear(animated: Bool) {
        self.runNextStep()
    }
    
    override func viewDidLoad() {
        
        self.statusTable.delegate = self;
        self.statusTable.dataSource = self;
        
        for step in steps
        {
            step.delegate = self
        }
        
        self.progressbar.emptyLineWidth = 1.0
        self.progressbar.progressLineWidth = 1.0
        self.progressbar.progressAngle = 60
        self.progressbar.progressRotationAngle = 0
        self.progressbar.percent = 0
        self.timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(3), target: self, selector: Selector("removeme"), userInfo: nil, repeats: true)
        
    }
    
    func removeme()
    {
        if self.progressbar.percent<100
        {
            self.progressbar.percent += CGFloat(100 / self.steps.count);
        }
        else
        {
            timer?.invalidate()
        }

    }
    
    func runNextStep() -> Void
    {
        if (step_index != self.steps.count)
        {
            self.steps[step_index].delegate = self
            self.statusTable.reloadData()
            self.steps[step_index].run()
            self.statusTable.reloadData()
        }
    }
    
    func stepHasCompleted()->Void
    {
        if self.steps[step_index].status == true
        {
            self.step_index++

            var time = DISPATCH_TIME_NOW + (1000 * NSEC_PER_SEC)
            dispatch_after(
                time,
                dispatch_get_main_queue(),
                { () -> Void in
                    self.runNextStep()
                })
            
        }
        self.statusTable.reloadData()
    }
    
    func stepWillRun()->Void
    {
    
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("NetworkDebugCell", forIndexPath: indexPath) as! CustomTableCell

        if indexPath.item < self.step_index + 1 && indexPath.item < self.steps.count
        {
            var step:NetworkDebugStatus = self.steps[indexPath.item] as NetworkDebugStatus
            cell.nameLabel.text = step.step_label

            if step.complete
            {
                if step.status == true
                {
                    cell.accessoryImage.image = UIImage(named:"thumbs_up")
                }
                else
                {
                    cell.accessoryImage.image = UIImage(named:"thumbs_down")
                }
            }
        }
        
        return cell;
    }
    
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int
    {
        if (step_index) < steps.count
        {
            return step_index + 1;
        }
        else
        {
            return steps.count
        }
    }
}

class CustomTableCell:UITableViewCell {
    @IBOutlet private weak var nameLabel:UILabel!
    @IBOutlet weak var accessoryImage: UIImageView!
}
