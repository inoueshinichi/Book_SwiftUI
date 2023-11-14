//
//  OkashiData.swift
//  MyOkashi
//
//  Created by Inoue Shinichi on 2023/08/18.
//

import Foundation

// お菓子の情報をまとめる構造体
struct OkashiItem : Identifiable {
    let id = UUID()
    let name : String
    let link : URL
    let image : URL
}

// お菓子データ検索用クラス
class OkashiData : ObservableObject {
    
    // Swiftで受け取るJSONデータ構造
    struct ResultJson : Codable {
        // JSONのitem内のデータ構造
        struct Item : Codable {
            // お菓子の名称
            let name : String?
            // 掲載URL
            let url : URL?
            // 画像URL
            let image : URL?
        }
        
        // 配列
        let item : [Item]?
    }
    
    // プロパティラッパー : Publisher - Sucscriber モデル
    @Published var okashiList : [OkashiItem] = []
    
    // クリックされたWebページのURL
    var okashiLink : URL?
    
    // Web API検索用メソッド
    func searchOkashi(keyword : String) {
        print("searchOkashiメソッドで受け取った値: \(keyword)")
        
        // 非同期処理
        Task {
            // 非同期関数searchの同期を取るためにawaitを用いる
            await search(keyword: keyword)
        } // Task
    }
    
    // 非同期関数 : Web API
    private func search(keyword : String) async {
        print("非同期関数: searchメソッドで受け取った値: \(keyword)")
        
        // お菓子の検索キーワードをURL用にエンコードする(UTF-8? Base64?)
        guard let keywordEncode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else {
            return
        }
        
        // リクエストURLの作成
        guard let requestUrl = URL(string : "https://sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keywordEncode)&max=10&order=r")
        else {
                return
        }
        
//        print(requestUrl)
        
        
        // レスポンスURLからJsonデータを取得する
        do {
            // リクエストURLからダウンロード
            let (data, _) /* (Data, ResponseURL) */ = try await URLSession.shared.data(from : requestUrl)
            
            let decoder = JSONDecoder()
            
            // Parse
            let json = try decoder.decode(ResultJson.self, from : data)
            
//            print(json)
            
            // お菓子の情報が取得できているかチェック
            guard let items = json.item else { return }
            
            self.okashiList.removeAll()
            
            // 特定のお菓子に関するデータを抽出
            for item in items {
                if let name = item.name,
                   let link = item.url,
                   let image = item.image {
                    let okashi = OkashiItem(name : name, link : link, image : image)
                    self.okashiList.append(okashi)
                }
            }
            
//            print(self.okashiList)
            
        } catch {
            print("エラーが出ました")
        }
    }
    
}


