//
//  SafariView.swift
//  MyOkashi
//
//  Created by Inoue Shinichi on 2023/08/18.
//

import SwiftUI
import SafariServices

// SFSafariViewControllerを起動する構造体
struct SafariView : UIViewControllerRepresentable {
    // 表示するURL
    let url : URL
    

    // Init view
    func makeUIViewController(context: Context) -> SFSafariViewController {
        // Safariの起動
        return SFSafariViewController(url : url)
    }
    
    // Update view
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // nothing
    }
}
