//
//  DetailViewController.swift
//  NewsFeed
//
//  Created by 井上真一 on 2019/04/07.
//  Copyright © 2019年 Inoue. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController
    : UIViewController
{
    
    @IBOutlet weak var webView: WKWebView!
    var link:String!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let url = URL(string: self.link)
        {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }
    
}
