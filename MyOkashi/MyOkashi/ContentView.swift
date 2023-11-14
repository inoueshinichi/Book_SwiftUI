//
//  ContentView.swift
//  MyOkashi
//
//  Created by Inoue Shinichi on 2023/08/18.
//

import SwiftUI

struct ContentView: View {
    
    // OkashiDataを参照する状態変数
    @StateObject var okashiDataList = OkashiData()
    
    // 入力された文字列を保持する状態変数
    @State var inputText = ""
    
    // SafariViewの表示有無を管理する変数
    @State var showSafari = false
    
    var body: some View {
        VStack {
            TextField("キーワード",
                      text: $inputText,
                      prompt: Text("キーワードを入力してください"))
            .onSubmit {
                // 入力完了直後に検索する
                okashiDataList.searchOkashi(keyword: inputText)
            } // .onSumbit
            // キーボードの改行を検索に変更する
            .submitLabel(.search)
            .padding()
            
            // Listを表示する
            List(okashiDataList.okashiList) { okashi in
                
                // ボタン
                Button {
                    // 選択したリンクを保存する
                    okashiDataList.okashiLink = okashi.link
                    
                    // SafariViewを表示する
                    showSafari.toggle()
                } label : {
                    HStack {
                        // 非同期でURL画像を読み込む
                        AsyncImage(url : okashi.image) { image in
                            // 画像を表示する
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height : 40)
                        } placeholder: {
                            // 読み込み中はインジケータを表示する
                            ProgressView()
                        } // AsyncImage
                        
                        Text(okashi.name)
                    } // HStack
                } // Button
            } // List
            .sheet(isPresented: $showSafari) {
                // SafariViewを表示する
                SafariView(url : okashiDataList.okashiLink!)
                    // 画面下部がセーフエリア外までいっぱいになるように指定
                    .ignoresSafeArea(edges : [.bottom])
            } // .sheet
            
        } // VStack
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
