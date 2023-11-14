//
//  SettingView.swift
//  TimeNavigator
//
//  Created by Inoue Shinichi on 2023/08/08.
//

import SwiftUI

struct SettingView: View {
    
//    @State var timerValue = 10
    @AppStorage("timer_value") var timerValue = 10
    
    var body: some View {
        // 奥から手前方向にレイアウト
        ZStack {
            // 背景色
            Color("backgourndSetting")
                .ignoresSafeArea()
            
            // 垂直レイアウト
            VStack {
                
                Spacer()
                
                Text("\(timerValue)秒")
                    .font(.largeTitle)
                
                Spacer()
                
                // Pickerの表示
                Picker(selection: $timerValue) {
                    Text("10").tag(10)
                    Text("20").tag(20)
                    Text("30").tag(30)
                    Text("40").tag(40)
                    Text("50").tag(50)
                    Text("60").tag(60)
                } label: {
                    Text("選択")
                }
                
                // Pickerホイールを表示
                .pickerStyle(
                    .wheel
                    /*.segmented*/
                    /*.menu*/
                )
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
