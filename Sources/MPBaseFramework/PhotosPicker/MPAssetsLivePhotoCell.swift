//
//  MPAssetsLivePhotoCell.swift
//  
//
//  Created by ogawa on 2024/6/4.
//

import UIKit

class MPAssetsLivePhotoCell: MPAssetsImageCell,MPAssetsPickerLivePhotoCellProtocol {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        liveIcon.contentMode = .scaleAspectFit
        liveIcon.tintColor = .white
        self.contentView.addSubview(liveIcon)
        if self.flagView != nil {
            self.contentView.bringSubviewToFront(self.flagView!)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let liveIcon: UIImageView =  UIImageView(image: UIImage(systemName: "livephoto"))
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        liveIcon.frame = CGRect(x: 5, y: 5, width: 20, height: 20)
    }
    
    
}
