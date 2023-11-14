//
//  DrawView.swift
//  ObjectDetection
//
//  Created by Inoue Shinichi on 2019/05/02.
//  Copyright © 2019 Inoue Shinichi. All rights reserved.
//

import UIKit
import Vision

// 描画ビュー
class DrawView
    : UIView
{
    // BoundingBoxカラー
    let COLOR_BLUE: UIColor = UIColor.blue
    let COLOR_WHITE: UIColor = UIColor.white
    
    // BoundingBox
    var imageRect: CGRect = CGRect.zero
    var objects: [VNRecognizedObjectObservation]!
    
    
    // 画像サイズをiphoneのViewFrameサイズに変更
    func setImageSize(_ imageSize: CGSize) {
        
        // imageがframeからはみ出ないようにするため, imageの縦横方向のうち外枠のframeに最近接している比率をimageの縦横にかける
        let scale: CGFloat = (self.frame.width / imageSize.width < self.frame.height / imageSize.height) ?
            self.frame.width / imageSize.width : self.frame.height / imageSize.height
        
        // 幅と高さ
        let dw: CGFloat = imageSize.width * scale
        let dh: CGFloat = imageSize.height * scale
        
        self.imageRect = CGRect(x: (self.frame.width - dw) / 2,
                                y: (self.frame.height - dh) / 2,
                                width: dw,
                                height: dh)
    }
    
    
    // 検出結果の描画(DrawViewの描画時に呼ばれる)
    override func draw(_ rect: CGRect) {
        
        if self.objects == nil {
            print("No Objects\n")
            return
        }
        
        // グラフィックコンテキストの生成
        let context = UIGraphicsGetCurrentContext()!
        
        // Non-Maximum Suppressionの適用
        objects = nonMaximumSuppression(self.objects)
        
        // 物体検出の描画
        for object in objects {
            // 領域の描画
            let rect = convertRect(object.boundingBox)
            context.setStrokeColor(COLOR_BLUE.cgColor) // 青枠
            context.setLineWidth(2) // 幅2
            context.stroke(rect)
            
            // ラベルの表示
            let label = object.labels.first!.identifier
            drawText(context, text: label, rect: rect)
        }
    }
    
    // 検出結果の座標系を画面の座標系に変換
    func convertRect(_ rect: CGRect) -> CGRect {
        // 検出領域の座標系: 幅[0, 1], 高さ[0, 1] 左下が原点
        // 画面の座標系: dp単位(density-independent pixels)
        return CGRect(
            x: self.imageRect.minX + rect.minX * self.imageRect.width,
            y: self.imageRect.minY + (1 - rect.maxY) * self.imageRect.height,
            width: self.imageRect.width * rect.width,
            height: self.imageRect.height * rect.height)
    }
    
    
    // IoU(Intersection over Union)の計算
    func IoU(_ targetRect: CGRect, _ compareRect: CGRect) -> Float {
        let intersection = targetRect.intersection(compareRect)
        let union = targetRect.union(compareRect)
        return Float( (intersection.width * intersection.height) / (union.width * union.height) )
    }
    
    
    // テキストの描画
    func drawText(_ context: CGContext, text: String, rect: CGRect) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        context.setFillColor(COLOR_BLUE.cgColor)
        let textRect = CGRect(x: rect.minX, y: rect.minY - 16, width: rect.width, height: 16) // BoundingBoxより16dpだけ上にラベル矩形を描画
        context.fill(textRect)
        attributedString.draw(in: textRect)
    }
    
    
    // Non-Maximum Suppression
    func nonMaximumSuppression(_ objects: [VNRecognizedObjectObservation]) -> [VNRecognizedObjectObservation] {
        
        // IoUの閾値(閾値より高い値を持つBoundingBoxの物体は同一対象とみなす)
        let iouThresh : Float = 0.3
        
        var results : [VNRecognizedObjectObservation] = [] // 配列
        var keep = [Bool](repeating: true, count: objects.count) // 保持グラフ
        
        // 検出したBoundingBox(objectness)を信頼度順(昇順)でソート
        let orderedObjects = objects.sorted {$0.confidence > $1.confidence}
        
        for i in 0..<orderedObjects.count {
            print("Yahoo " + String(i) + "\n")
            if keep[i] {
                // 最も信頼度が高いobjectsを結果配列に追加
                results.append(orderedObjects[i])
                
                // その他のobjectsとIoU計算を行い、閾値以上のobjectsを抑制
                let targetBox = orderedObjects[i].boundingBox
                for j in (i+1)..<orderedObjects.count {
                    if keep[j] {
                        let compareBox = orderedObjects[i].boundingBox
                        if IoU(targetBox, compareBox) > iouThresh {
                            keep[j] = false
                        }
                    }
                }
            }
        }
        return results
    }
}






