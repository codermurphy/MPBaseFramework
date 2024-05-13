//
//  UIImageViewExtension.swift
//  BasicProject
//
//  Created by ogawa on 2022/1/11.
//

import UIKit

extension UIImageView {
    
    //MARK: - initial
    public convenience init(imageName: String) {
        let image = UIImage(named: imageName)
        self.init(image: image)
    }
    
    public convenience init(imageData: Data) {
        let image = UIImage(data: imageData)
        self.init(image: image)
    }
}
