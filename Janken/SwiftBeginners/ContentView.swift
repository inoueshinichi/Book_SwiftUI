//
//  ContentView.swift
//  SwiftBeginners
//
//  Created by Inoue Shinichi on 2023/07/09.
//

import SwiftUI

struct ContentView: View {
    
    @State var answerNumber : Int = 0
    
    var body: some View {
        VStack {
            Spacer()
            
            if answerNumber == 0 {
                Text("これからじゃんけんをします")
//                    .padding(.bottom)
                    .padding(
                        EdgeInsets(top: 0,
                                   leading: 16,
                                   bottom: 80,
                                   trailing: 16)
                        )
                
            } else if answerNumber == 1 {
                Image("gu")
                    .resizable()
                    .scaledToFit()
                Text("グー")
                    .padding(.bottom)
            } else if answerNumber == 2 {
                Image("choki")
                    .resizable()
                    .scaledToFit()
                Text("チョキ")
                    .padding(.bottom)
            } else {
                Image("pa")
                    .resizable()
                    .scaledToFit()
                Text("パー")
                    .padding(.bottom)
            }
            
            Button {
                print("タップされた")
                var newAnswerNumber = 0
                
                repeat {
                    newAnswerNumber = Int.random(in: 1...3)
                } while answerNumber == newAnswerNumber
                
                answerNumber = newAnswerNumber
            } label: {
                Text("じゃんけんする")
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .font(.title)
                    .background(Color.pink)
                    .foregroundColor(Color.white)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
