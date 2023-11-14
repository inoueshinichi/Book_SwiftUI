//
//  ContentView.swift
//  MyMap
//
//  Created by Inoue Shinichi on 2023/08/07.
//

import SwiftUI

struct ContentView: View {
    
    // 入力中の文字列を保持する状態変数
    @State var inputText: String = ""
    // 検索キーワード
    @State var displaySearchKey: String = ""
    // マップ種類 最初は標準から
    @State var displayMapType: MapType = .standard
    
    var body: some View {
        VStack {
            // テキストフィールド
            TextField("キーワード", text: $inputText, prompt: Text("キーワードを入力してください"))
                .onSubmit {
                    // 入力が完了したので検索キーワードに設定
                    displaySearchKey = inputText
                }
                .padding()
            
            // 奥から手前方向にレイアウト(右下基準)
            ZStack(alignment: .bottomTrailing) {
                // マップを表示
                MapView(searchKey: displaySearchKey, mapType: displayMapType)
                
                // マップ種類切り替えボタン
                Button {
                    // 標準 -> 衛星写真 -> 衛星写真+交通機関ラベル
                    if displayMapType == .standard {
                        displayMapType = .satelite // 標準 -> 衛星写真
                    } else if displayMapType == .satelite {
                        displayMapType = .hybird
                    } else {
                        displayMapType = .standard
                    }
                    print("マップ種類切り替えボタン タップ")
                } label: {
                    // マップアイコンの表示
                    Image(systemName: "map")
                        .resizable()
                        .frame(width: 35.0, height: 35.0)
                } // Button
                .padding(.trailing, 20.0)
                .padding(.bottom, 30.0)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
