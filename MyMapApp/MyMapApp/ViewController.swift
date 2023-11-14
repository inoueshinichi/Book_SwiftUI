//
//  ViewController.swift
//  MyMapApp
//
//  Created by 井上真一 on 2019/04/24.
//  Copyright © 2019年 Inoue. All rights reserved.
//

import UIKit
import MapKit

class ViewController
    : UIViewController
    , UITextFieldDelegate
{
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        inputText.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // キーボードのリターン //
        textField.resignFirstResponder() // キーボードを引っ込める
        
        if let searchKeyword = textField.text
        {
            print(searchKeyword)
            
            // 住所名から緯度・経度を求める
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(searchKeyword, completionHandler: { (placemarks: [CLPlacemark]?, error:Error?) in
                
                    if let placemark = placemarks?[0]
                    {
                        if let targetCoordinate = placemark.location?.coordinate
                        {
                            print(targetCoordinate)
                            
                            // 緯度・経度からMapにピンを立てる
                            let pin = MKPointAnnotation()
                            pin.coordinate = targetCoordinate
                            pin.title = searchKeyword
                            self.displayMap.addAnnotation(pin)
                            self.displayMap.region = MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
                            
                        }
                    }
                })
            
        }
        
        return true
    }
    
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var displayMap: MKMapView!
    
    
}

