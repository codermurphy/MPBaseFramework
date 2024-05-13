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
            let maxWidth = max(imageSize.width, titleSize.width)
            let topOffset = abs((imageSize.height - titleSize.height) * 0.5)
            if maxWidth == imageSize.width {
                let centerX = imageSize.width * 0.5
                titleEdgeInsets = UIEdgeInsets(top: imageSize.height + spacing - topOffset, left: -(centerX + titleSize.width * 0.5), bottom: -(imageSize.height + spacing - topOffset), right: centerX + titleSize.width * 0.5)
                contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: imageSize.height + spacing - topOffset * 2, right: -titleSize.width)
            }
            else {
                let centerX = titleSize.width * 0.5
                imageEdgeInsets = UIEdgeInsets(top: 0, left: centerX - imageSize.width * 0.5, bottom: 0, right: 0)
                titleEdgeInsets = UIEdgeInsets(top: imageSize.height + spacing - topOffset, left: -imageSize.width, bottom: -(imageSize.height + spacing - topOffset), right: imageSize.width)
                contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: imageSize.height + spacing - topOffset * 2, right: -imageSize.width)
            }
            
        case .bottom:
            break
        }
    }

}
