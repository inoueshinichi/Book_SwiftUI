//
//  ViewController.swift
//  ImgClassifyDogorCat
//
//  Created by Inoue Shinichi on 2019/04/28.
//  Copyright © 2019 Inoue Shinichi. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController
    : UIViewController
    , UINavigationControllerDelegate
    , UIImagePickerControllerDelegate
    , UIGestureRecognizerDelegate
{

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    override func viewDidAppear(_ animated: Bool) {
        if self.imageView.image == nil {
            showActionSheet()
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        showActionSheet()
    }
    
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "カメラ", style: .default, handler: { action in self.openPicker(sourceType: .camera) }))
        
        actionSheet.addAction(UIAlertAction(title: "フォトライブラリ", style: .default, handler: { action in self.openPicker(sourceType: .photoLibrary )}))
        
        actionSheet.addAction(UIAlertAction(title: "キャンセル", style: .default, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    func showAlert(_ text: String!) {
        let alert = UIAlertController(title: text, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func openPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard var image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { fatalError("画像の取得ができません")}
        
        // 画像向きの補正
        let size = image.size
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // 解析画像の指定
        self.imageView.image = image
        
        picker.presentingViewController!.dismiss(animated: true, completion: nil)
        
        // ラベル予測
        predict(image)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    
    func predict(_ image: UIImage) {
        
        // ディスパッチで単一スレッドに以下のタスクを実行してもらう
        DispatchQueue.global(qos: .default).async {
            
            // モデル
            guard let model = try? VNCoreMLModel(for: ImageClassification().model) else { fatalError("モデルの読み込みに失敗しました") }
            
            // リクエストの生成
            let request = VNCoreMLRequest(model: model, completionHandler: { request, error in
                
                // エラー処理
                if error != nil {
                    self.showAlert(error!.localizedDescription)
                    return
                }
                
                // 検出結果の取得(テンプレート)
                guard let observations = request.results as? [VNClassificationObservation] else { fatalError("リクエストに失敗しました") }
                var text: String = "\n"
                for i in 0..<min(3, observations.count) {
                    let probability = Int(observations[i].confidence*100)
                    let label = observations[i].identifier
                    text += "\(label) : \(probability)%\n"
                }
                
                // UIの更新
                DispatchQueue.main.async {
                    //self.lblText.text = text
                    print(text)
                }
                
            })
                
            // 解析画像のリサイズ
            request.imageCropAndScaleOption = .centerCrop
                
            // UIImageをCIImageに変換
            guard let ciImage = CIImage(image: image) else { fatalError("UIImageをCIImageに変換できません") }
                
            // 画像向きの取得
            guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) else { fatalError("画像向きを取得できません") }
                
            // ハンドラの生成と実行
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            guard (try? handler.perform([request])) != nil else { fatalError("VNImageRequestHandlerの実行に失敗しました") }
                
        }
    }
}

