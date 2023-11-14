//
//  ViewController.swift
//  SequenceClassifyDogorCat
//
//  Created by Inoue Shinichi on 2019/04/29.
//  Copyright © 2019 Inoue Shinichi. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController
    : UIViewController
    , AVCaptureVideoDataOutputSampleBufferDelegate
{
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var drawView: UIView!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        // カメラキャプチャの開始
        startCapture()
    }
    
    
    func showAlert(_ text: String!) {
        let alert = UIAlertController(title: text, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    

    // カメラキャプチャ
    func startCapture() {
        // セッション初期化
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo // 動画品質の指定
        
        // 入力指定
        let captureDevice: AVCaptureDevice! = self.device(false)
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { fatalError("デバイス入力を受け取れません") }
        guard captureSession.canAddInput(input) else { fatalError("セッションにデバイス入力を追加できません") }
        captureSession.addInput(input)
        
        // 出力指定
        let output: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoQueue"))
        guard captureSession.canAddOutput(output) else { fatalError("セッションに出力画像を追加できません") }
        captureSession.addOutput(output)
        let videoConnection = output.connection(with: AVMediaType.video)
        videoConnection!.videoOrientation = .portrait // カメラ映像の向きを指定
        
        // プレビュー(画面表示)の指定
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = self.drawView.frame
        self.view.layer.insertSublayer(previewLayer, at: 0)
        
        // カメラキャプチャの開始
        captureSession.startRunning()
    }
    
    
    // フロントカメラまたはバックカメラを利用する
    func device(_ frontCamera: Bool) -> AVCaptureDevice! {
        // AVCaptureDeviceリストの取得
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        // 指定したポジションをもつAVCaptureDeviceの検索
        let position: AVCaptureDevice.Position = frontCamera ? .front : .back
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    
    // ビデオフレームの更新ごとに呼ばれる(デリゲートメソッド)
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // 画像解析
        predict(sampleBuffer)
    }
    
    
    // 予測
    func predict(_ sampleBuffer: CMSampleBuffer) {
        
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
                    self.lblText.text = text
                    print(text)
                }
                
            })
            
            // 解析画像のリサイズ
            request.imageCropAndScaleOption = .centerCrop
            
            // CMSampleBufferをCVImageBufferに変換
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { fatalError("CMSampleBufferをCVImageBufferに変換できません") }
            
            // ハンドラの生成と実行(cvPixelBufferはCVImageBufferのエイリアス)
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            guard (try? handler.perform([request])) != nil else { fatalError("VNImageRequestHandlerの実行に失敗しました") }
            
        }
    }
}

