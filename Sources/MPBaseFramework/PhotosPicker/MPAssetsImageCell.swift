//
//  MPAssetsImageCell.swift
//  
//
//  Created by ogawa on 2024/6/4.
//

import UIKit
import Photos


class MPAssetsImageCell: UICollectionViewCell,MPAssetsPickerThumbnailCellProtocol {
    
    
    var asset: PHAsset?
    
    var imageRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    var selectedIndex: Int = 0
    
    var isSelectedAssets: Bool = false
    
    var isDegraded: Bool = false
    
    var cellType: MPAssetsPickerCellType = .image
    
    var isSingleChoise: Bool = false {
        didSet {
            if isSingleChoise {
                flagView?.removeFromSuperview()
                flagView = nil
            }
        }
    }
    
    weak var imageManger: MPAssetsManager?
    

    
    
    weak var delegate: MPAssetsPickerCellDelegate?
    
    //MARK: - initial
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(imageView)

        if flagView != nil {
            flagView?.isUserInteractionEnabled = false
            self.contentView.addSubview(flagView!)
        }
        

        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    //MARK: - override methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageManger?.cancelRequestImage(requestId: imageRequestID)
        imageManger = nil
        imageRequestID = PHInvalidImageRequestID
        imageView.image = nil
        setSelectedFlag(index: 0,selected: false)
        self.contentView.isHidden = false
    }

    
    
    func setSelectedFlag(index: Int,selected: Bool) {
        isSelectedAssets = selected
        flagView?.setSelected(index: index,selected: isSelectedAssets)
    }
    
    //MARK: - UI
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private(set) var flagView: MPAssetsPickerSelectedFlagProtocol? = MPAssetsPickerFlagView()

    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.contentView.bounds
        flagView?.frame = self.contentView.bounds
        
    }
}


