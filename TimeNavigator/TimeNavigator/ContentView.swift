//
//  ContentView.swift
//  TimeNavigator
//
//  Created by Inoue Shinichi on 2023/08/08.
//

import SwiftUI

struct ContentView: View {
    
    @State var timerHandler: Timer?
    @State var count = 0
    @AppStorage("timer_value") var timerValue = 10
    
    @State var showAlert = false
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                Image("backgroundTimer")
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                
                VStack(spacing: 30.0) {
                    Text("残り\(timerValue - count)秒")
                        .font(.largeTitle)
                    
                    HStack {
                        // スタートボタン
                        Button {
                            // タイマーカウントダウン開始関数
                            startTimer()
                        } label: {
                            Text("スタート")
                                .font(.title)
                                .foregroundColor(Color.white)
                                .frame(width: 140, height:140)
                                .background(Color("startColor"))
                                .clipShape(Circle())
                        } // スタートボタン
                        
                        // ストップボタン
                        Button {
                            if let unwrapledTimerHandler = timerHandler {
                                if unwrapledTimerHandler.isValid == true {
                                    // タイマーストップ
                                    unwrapledTimerHandler.invalidate()
                                }
                            }
                            
                        } label: {
                            Text("ストップ")
                                .font(.title)
                                .foregroundColor(Color.white)
                                .frame(width: 140, height: 140)
                                .background(Color("stopColor"))
                                .clipShape(Circle())
                        } // ストップボタン
                    } // HStack
                } // VStack
            } // ZStack
            .onAppear {
                // 画面が表示されるときに1だけ実行される
                count = 0
            }
            .toolbar {
                // ナビゲーション画面の右側にボタンを追加
                ToolbarItem(placement: /*.navigationBarTrailing*/
                    /*.bottomBar*/
                    /*.navigationBarLeading*/
                    /*.automatic*/
                    .navigation) {
                    // ナビゲーション遷移
                    NavigationLink {
                        SettingView()
                    } label: {
                        // テキストを表示
                        Text("秒数設定")
                    } // NavigationLink
                } // ToolbarItem
            } // .toolbar
            .alert("終了", isPresented: $showAlert) {
                Button("OK") {
                    print("OKタップがおされました")
                }
            } message: {
                Text("タイマー終了時間です")
            } // .alert
        } // NavigationStack
    } // body
    
    // 定期タイマーハンドラ
    func countDownTimer() {
        count += 1
        
        if timerValue - count <= 0 {
            // タイマー停止
            timerHandler?.invalidate()
            
            // アラートを表示する
            showAlert = true
        }
    }
    
    // 開始タイマーハンドラ
    func startTimer() {
        // timerHandlerをアンラップしてunwrapedTimerHandlerに代入
        if let unwrapedTimerHandler = timerHandler {
            // タイマー実行中は何もしない
            if unwrapedTimerHandler.isValid == true {
                // 何もしない
                return
            }
        }
        
        // 経過時間が0以下のとき0にセット
        if timerValue - count <= 0 {
            count = 0
        }
        
        // タイマーをスタート
        timerHandler = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            // クロージャ&定期ハンドラ
            countDownTimer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
