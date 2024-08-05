//
//  UIButtonExtension.swift
//  BasicProject
//
//  Created by ogawa on 2022/1/11.
//

import UIKit

extension UIButton {
    public enum UIButtonTextAndImageType {
        case `default`
        case right
        case top
        case bottom
    }
    
    public func mp_centerTextAndImage(type: UIButtonTextAndImageType,spacing: CGFloat) {
        switch type {
        case .default:
            let insetAmount = spacing / 2
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
        case .right:
            guard
                let imageSize = self.currentImage?.size,
                let text = self.currentTitle,
                let font = titleLabel?.font
                else { return }
            let titleSize = text.size(withAttributes: [.font: font])
            let insetAmount = spacing / 2
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageSize.width + insetAmount), bottom: 0, right: insetAmount + imageSize.width)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: titleSize.width + insetAmount, bottom: 0, right: -(insetAmount + titleSize.width))
            contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
        case .top:
            guard
                let imageSize = self.currentImage?.size,
                let text = self.currentTitle,
                let font = titleLabel?.font
                else { return }
            let titleSize = text.size(withAttributes: [.font: font])
            let originContentWidth = imageSize.width + titleSize.width
            let originContentHeight = max(imageSize.height, titleSize.height)
            let newContentWidth = max(imageSize.width,titleSize.width)
            let newContentHeight = imageSize.height + titleSize.height + spacing
            let diff_width = newContentWidth - originContentWidth
            let diff_height = newContentHeight - originContentHeight
            let diff_image_height = newContentHeight - imageSize.height
            let diff_title_height = newContentHeight - titleSize.height


            contentEdgeInsets = UIEdgeInsets(top: diff_height / 2 , left: diff_width / 2, bottom: diff_height / 2, right: diff_width / 2)
            titleEdgeInsets = UIEdgeInsets(top: diff_title_height, left:  -imageSize.width, bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: -diff_image_height, left:-diff_width * 0.5 + (newContentWidth - imageSize.width) * 0.5 , bottom: 0, right: 0)

            
        case .bottom:
            guard
                let imageSize = self.currentImage?.size,
                let text = self.currentTitle,
                let font = titleLabel?.font
                else { return }
            
            let titleSize = text.size(withAttributes: [.font: font])
            let originContentWidth = imageSize.width + titleSize.width
            let originContentHeight = max(imageSize.height, titleSize.height)
            let newContentWidth = max(imageSize.width,titleSize.width)
            let newContentHeight = imageSize.height + titleSize.height + spacing
            let diff_width = newContentWidth - originContentWidth
            let diff_height = (newContentHeight - originContentHeight)
            let diff_image_height = newContentHeight - imageSize.height
            let diff_title_height = newContentHeight - titleSize.height
            contentEdgeInsets = UIEdgeInsets(top: diff_height / 2 , left: diff_width / 2, bottom: diff_height / 2, right: diff_width / 2)
            titleEdgeInsets = UIEdgeInsets(top: -diff_title_height, left:  -imageSize.width, bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left:-diff_width * 0.5 + (newContentWidth - imageSize.width) * 0.5 , bottom: -diff_image_height, right: 0)
            
        }
    }

}
