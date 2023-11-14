//
//  ViewController.swift
//  Camera
//
//  Created by Inoue Shinichi on 2019/03/09.
//  Copyright © 2019 Inoue Shinichi. All rights reserved.
//

import UIKit

class ViewController:
    UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
{
    
    // イメージビュー
    @IBOutlet weak var imageView: UIImageView!
    
    // カメラボタン起動時
    @IBAction func launchCamera(_ sender: UIBarButtonItem) {
            let camera = UIImagePickerController.SourceType.camera
        
        // カメラが使用できる場合
        if UIImagePickerController.isSourceTypeAvailable(camera)
        {
            let picker = UIImagePickerController()
            picker.sourceType = camera
            picker.delegate = self
            self.present(picker, animated: true)
        }
    }
    
    // 撮影後に起動
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        self.imageView.image = image
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

