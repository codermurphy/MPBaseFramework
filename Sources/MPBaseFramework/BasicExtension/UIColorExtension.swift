//
//  UIColorExtension.swift
//  
//
//  Created by ogawa on 2024/6/29.
//

import UIKit

extension UIColor {
    
    var image: UIImage? {
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false
        
        let render = UIGraphicsImageRenderer(size: .init(width: 10, height: 10), format: format)
        
        let image = render.image { context in
            self.setFill()

            let path = UIBezierPath(rect: CGRect(origin: .zero, size: .init(width: 10, height: 10)))
            path.fill()

        }
        
        return image
    }
}
