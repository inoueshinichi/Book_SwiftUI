//
//  ViewController.swift
//  SNS
//
//  Created by 井上真一 on 2018/07/19.
//  Copyright © 2018年 Inoue. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func showActivityView(_ sender: UIBarButtonItem) {
        
        func showMessage() { print("表示完了") }
        
        let controller = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        
        //self.present(controller, animated: true, completion: nil)
        //self.present(controller, animated: true, completion: showMessage)
        //self.present(controller, animated: true, completion: { print("表示完了ですよ") })
        self.present(controller, animated: true, completion: {
            () -> Void in
                print("苔は美しい")
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

