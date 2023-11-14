//
//  ContentView.swift
//  CameraSNS
//
//  Created by Inoue Shinichi on 2023/08/12.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    // 撮影した写真を保存する状態変数
    @State var captureImage: UIImage? = nil
    // 撮影画面(sheet)の開閉状態を管理
    @State var isShowSheet = false
    // フォトライブラリーで選択した写真を管理
    @State var photoPickerSelectedImage: PhotosPickerItem? = nil
    
    // bodyは計算型プロパティ
    var body: some View {
        VStack {
            Spacer()
//
//            // 撮影した写真があるとき
//            if let captureImage {
//                // 撮影写真を表示
//                Image(uiImage: captureImage)
//                    .resizable()
//                    .scaledToFit()
//            }
            
            // カメラ起動ボタン
            Button {
                // カメラが利用可能かチェック
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    print("カメラは利用できます")
                    
                    //　撮影写真の初期化
                    captureImage = nil
                    
                    isShowSheet.toggle()
                } else {
                    print("カメラは利用できません")
                }
            } label: {
                Text("カメラを起動する")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .multilineTextAlignment(.center)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
            } // Button
            .padding()
            // isPresentedで指定した状態変数がtrueのとき実行
            .sheet(isPresented: $isShowSheet) {
                // UIImagePickerController(写真撮影)を表示
//                ImagePickerView(isShowSheet: $isShowSheet, captureImage: $captureImage)
                
                if let captureImage {
                    // 撮影した写真がある -> EffectViewを表示する
                    EffectView(isShowSheet: $isShowSheet, captureImage: captureImage)
                } else {
                    // UIImagePickerController(写真撮影)を表示
                    ImagePickerView(isShowSheet: $isShowSheet, captureImage: $captureImage)
                }
                
            } // Button sheet
            
            // フォトライブラリから選択する
            PhotosPicker(selection: $photoPickerSelectedImage,
                         matching: .images,
                         preferredItemEncoding: .automatic,
                         photoLibrary: .shared())
            {
                // テキスト表示
                Text("フォトライブラリーから選択する")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .padding()
            } // PhotoPicker
            // 選択したアイテムをもとに写真を取り出す
            .onChange(of: photoPickerSelectedImage) { photosPickerItem in
                // 選択した写真があるとき
                if let photosPickerItem {
                    // Data型で写真を取り出す
                    photosPickerItem.loadTransferable(type: Data.self) { result in
                        switch result {
                        case .success(let data):
                            // 写真があるとき
                            if let data {
                                //　撮影写真の初期化
                                captureImage = nil
                                // 写真をcaptureImageに保存
                                captureImage = UIImage(data: data)
                            }
                        case .failure:
                            return
                        }
                    }
                }
            } // .onChange
            
//            // UIImageのアンラップ
//            if let captureImage = captureImage?.resized(),
//               // captureImageから共有する画像を生成する
//               let shareImage = Image(uiImage: captureImage) {
//                // 共有シート
//                ShareLink(item: shareImage, subject: nil, message: nil,
//                          preview: SharePreview("Photo", image: shareImage)) {
//                    // テキストの表示
//                    Text("SNSに投稿する")
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 50)
//                        .background(Color.blue)
//                        .foregroundColor(Color.white)
//                        .padding()
//                } // ShareLink
//            }
            
            
        } // VStack
        .onChange(of: captureImage) { image in
            if let _ = image {
                // 撮影した写真がある -> EffectViewを表示する
                isShowSheet.toggle()
            }
        } // .onChange
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
