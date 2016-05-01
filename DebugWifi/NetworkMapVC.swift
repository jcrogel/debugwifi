//
//  NetworkMapVC.swift
//  DebugWifi
//
//  Created by Juan Carlos Moreno on 8/17/15.
//  Copyright (c) 2015 Juan C Moreno. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import GoogleMaps

class NetworkMapVC:UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate
{
    //From Network Test

    @IBOutlet weak var NetBasicTest: NetworkBasicTestView!
    @IBOutlet weak var mapView_: GMSMapView!
    @IBOutlet weak var progressbar: MBCircularProgressBarView!
    
    var points:[CLLocation] = []
    var loc_mgr:CLLocationManager?
    var gateway_coords:CLLocation?
    
    override func viewDidLoad() {
        /*
        Location Initialize
        */
        var lm = CLLocationManager()
        
        switch CLLocationManager.authorizationStatus()
        {
        case CLAuthorizationStatus.Denied:
            println("Denied")
        case CLAuthorizationStatus.NotDetermined:
            println("Not Determined")
            lm.requestWhenInUseAuthorization()
        default:
            print ("Something else")
            
        }
        
        lm.delegate = self
        
        
        lm.desiredAccuracy = kCLLocationAccuracyBest
        lm.requestAlwaysAuthorization()

        self.loc_mgr = lm

        /* End Location Initializa */
        
        
        mapView_.myLocationEnabled = true
        mapView_.delegate = self

        mapView_.addObserver(self, forKeyPath: "myLocation" , options: nil, context: nil)
        
        
        //self.NetBasicTest =  [self addSubview:
        //    [[[NSBundle mainBundle] loadNibNamed:@"MyCustomTimerView"
        //    owner:self
        //    options:nil] objectAtIndex:0]];
        //println(self.NetBasicTest.subviews)
        self.NetBasicTest.setWifiNetwork()
    }
    
    
    
    private func doNetworkBasicTest()
    {
    
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if (keyPath == "myLocation" && object as! GMSMapView == mapView_)
        {
            var loc:CLLocation = mapView_.myLocation
            var target = CLLocationCoordinate2DMake(loc.coordinate.latitude, loc.coordinate.longitude)
            self.mapView_.animateToLocation(target)
            self.mapView_.animateToZoom(kGMSMaxZoomLevel-1)
            mapView_.removeObserver(self, forKeyPath: "myLocation")
        }
        

        
    }
    
    @IBAction func addPoint(sender: AnyObject) {
        self.loc_mgr?.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        for location in locations as! [CLLocation]
        {
            var marker = GMSMarker()
            
            marker.position = CLLocationCoordinate2DMake(
                                    location.coordinate.latitude ,
                                    location.coordinate.longitude
                                );
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.icon = UIImage(named: "Pin")
            marker.map = mapView_;
            
            println(location.verticalAccuracy)
           
        }
        
        self.loc_mgr?.stopUpdatingLocation()
    }

}