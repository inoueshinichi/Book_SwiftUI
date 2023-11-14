//
//  ListVeiwController.swift
//  NewsFeed
//
//  Created by 井上真一 on 2019/03/10.
//  Copyright © 2019年 Inoue. All rights reserved.
//

import UIKit

class ListViewController
: UITableViewController
, XMLParserDelegate
{
    var parser:XMLParser!
    var items = [Item]()
    var item:Item?
    var currentString = ""
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell" , for : indexPath)
        //print("Yahoo")
        
        cell.textLabel?.text = items[indexPath.row].title
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        startDownload()
    }
    
    // RSS形式のデータをwebソースからダウンロード
    func startDownload()
    {
        self.items = []
        if let url = URL(string: "https://news.yahoo.co.jp/pickup/rss.xml") //"https://www.apple.com/jp/newsroom/rss-feed.rss")
        {
            // XMLParserは同期的URL読み込みなので、もう使えない(非推奨)
            if let parser = XMLParser(contentsOf: url) // XMLParserのイニシャライザ
            {
                self.parser = parser // ListViewControllerのparserメソッド
                self.parser.delegate = self
                self.parser.parse()
            }
        }
    }
    
    // XMLParserDelegateで宣言されているメソッド
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI : String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String])
    {
        // 要素名の開始タグが見つかるごとに毎回呼び出されるメソッド
        self.currentString = ""
        if elementName == "item"
        {
            self.item = Item()
        }
    }
    
    // XMLParserDelegateで宣言されているメソッド
    func parser(_ parser: XMLParser,
                foundCharacters string: String)
    {
        // RSS_itemのdescriptionが梱包されているstringから内容を取り出す
        self.currentString += string
    }
    
    // XMLParserDelegateで宣言されているメソッド
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?)
    {
        // 終了タグが見つかるごとに毎回呼び出されるメソッド
        switch elementName
        {
        case "title": self.item?.title = currentString
        case "link":  self.item?.link = currentString
        case "item":  self.items.append(self.item!)
        default:      break
        }
    }
    
    // RSS形式データ(XML)をパースする(4)
    func parserDidEndDocument(_ parser: XMLParser)
    {
        self.tableView.reloadData()
    }
    
    
    // 画面遷移したときに呼び出されるメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // オプショナルバインディング
        if let indexPath = self.tableView.indexPathForSelectedRow
        {
            let item = items[indexPath.row]
            let controller = segue.destination as! DetailViewController
            controller.title = item.title
            controller.link = item.link
        }
    }
    
    
    
}

