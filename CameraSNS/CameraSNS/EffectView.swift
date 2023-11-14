//
//  EffectView.swift
//  CameraSNS
//
//  Created by Inoue Shinichi on 2023/08/17.
//

import SwiftUI

struct EffectView: View {
    // エフェクト編集画面(sheet)の開閉状態を管理
    @Binding var isShowSheet: Bool
    // 撮影した写真
    let captureImage: UIImage
    // 表示する写真
    @State var showImage: UIImage?
    
    // フィルタの種類(Array)
    // 0. Mono
    // 1. Chrome
    // 2. Fade
    // 3. Instant
    // 4. Noir
    // 5. Process
    // 6. Tonal
    // 7. Transfer
    // 8. SepiaTone
    let filterArray = [
        "CIPhotoEffectMono",
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstance",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone",
    ]
    // 選択中のエフェクト
    @State var filterNumber = 0
    
    var body: some View {
        VStack {
            Spacer()
            
            if let showImage {
                // 表示する写真がある場合画面に表示
                Image(uiImage: showImage)
                    .resizable()
                    .scaledToFit()
            }
            
            Spacer()
            
            // エフェクト
            Button {
                // フィルタ名を指定
                let filterName = filterArray[filterNumber]
                
                // 次回のフィルタ処理番号
                filterNumber += 1
                if filterNumber == filterArray.count {
                    filterNumber = 0
                }
                
                // 元々の画像の回転角度を取得
                let rotate = captureImage.imageOrientation
                
                // UIImage形式の画像をCIImageに変換
                let inputImage = CIImage(image: captureImage)
                
                // フィルタクラスのインスタンス化
                guard let effectFilter = CIFilter(name: filterName) else { return }
                
                // フィルタパラメータの初期化
                effectFilter.setDefaults()
                
                // インスタンスにフィルタ加工する画像をInput
                effectFilter.setValue(inputImage, forKey: kCIInputImageKey)
                
                // フィルタ加工後の画像情報を収集(この時点で, まだ実行されていない)
                guard let outputImage = effectFilter.outputImage else { return }
                
                // CIContextインスタンスを生成 (DIB Device Image Bit)を作る
                let ciContext = CIContext(options: nil)
                
                // 描画用画像を生成
                // 加工後の画像をCIContext上に描画して, cgImageとして取得
                // このタイミングで画像の加工(フィルタ)が行われる.
                guard let cgImage = ciContext.createCGImage(
                    // CIImage
                    outputImage,
                    // レンダリングする画像領域
                    from: outputImage.extent
                )
                else
                {
                    return
                }
                
                // CGImage -> UIImage
                showImage = UIImage(
                    cgImage: cgImage,
                    scale: 1.0,
                    orientation: rotate
                    )
                
            } label: {
                Text("エフェクト")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .multilineTextAlignment(.center)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
            } // Button
            .padding()
            
            // シェア
            if let showImage = showImage?.resized(), // width: 1024にリサイズ
               let shareImage = Image(uiImage: showImage) {
                // 共有シート
                ShareLink(item: shareImage, subject: nil, message: nil,
                          preview: SharePreview("Photo", image: shareImage)) {
                    Text("シェア")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                } // ShareLink
                .padding()
            }
            
            // 閉じる
            Button {
                // エフェクト画面を閉じる
                isShowSheet.toggle()
            } label: {
                Text("閉じる")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .multilineTextAlignment(.center)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
            } // Button
            .padding()
        } // VStack
        .onAppear {
            // 撮影した写真を表示する写真に設定
            showImage = captureImage
        }
        
        
        
    } // body
}


struct EffectView_Preview: PreviewProvider {
    static var previews: some View {
        EffectView(
            isShowSheet: .constant(true),
            captureImage: UIImage(named: "preview_use")!
        )
    }
}
