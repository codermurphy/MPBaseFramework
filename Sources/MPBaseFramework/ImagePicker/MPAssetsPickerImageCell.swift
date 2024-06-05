//
//  MPAssetsPickerImageCell.swift
//  
//
//  Created by ogawa on 2024/6/4.
//

import UIKit
import Photos


class MPAssetsPickerImageCell: UICollectionViewCell,MPAssetsPickerImageCellProtocol {
    
    
    var asset: PHAsset?
    
    var imageRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    var selectedIndex: Int = 0
    
    var isSelectedAssets: Bool = false
    
    var isDegraded: Bool = false
    
    var cellType: MPAssetsPickerCellType = .image
    
    weak var imageManger: MPAssetsManager?
    

    
    
    weak var delegate: MPAssetsPickerCellDelegate?
    
    //MARK: - initial
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(imageView)

        self.contentView.addSubview(flagView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandle(gesture:)))
        tapGesture.delegate = self
        flagView.addGestureRecognizer(tapGesture)
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - tap gesture handler
    
    @objc private func tapGestureHandle(gesture: UIGestureRecognizer) {
    
        if !isSelectedAssets {
            guard let index = delegate?.cellDidSelected(cell: self),index.1 == true else { return }
            setSelectedFlag(index: index.0,selected: index.1)
        }
        else {
            setSelectedFlag(index: 0,selected: false)
            delegate?.cellDidUnSelected(cell: self)
            
        }
        
        
    }
    
    //MARK: - override methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageManger?.cancelRequestImage(requestId: imageRequestID)
        imageManger = nil
        imageRequestID = PHInvalidImageRequestID
        imageView.image = nil
        setSelectedFlag(index: 0,selected: false)
    }

    
    
    func setSelectedFlag(index: Int,selected: Bool) {
        isSelectedAssets = selected
        flagView.setSelected(index: index,selected: isSelectedAssets)
    }
    
    //MARK: - UI
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let flagView: MPAssetsPickerSelectedFlagProtocol = {
        let flag = MPAssetsPickerFlagView()
        return flag
    }()

    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.contentView.bounds
        flagView.frame = self.contentView.bounds
        
    }
}

extension MPAssetsPickerImageCell: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let targeRect = CGRect(x: self.contentView.bounds.width - flagView.selectedView!.frame.width - 10, y: 0, width: flagView.selectedView!.frame.width + 10, height: flagView.selectedView!.frame.width + 10)
        let point = gestureRecognizer.location(in: gestureRecognizer.view)
        if targeRect.contains(point) {
            return true
        }
        else {
            return false
        }
        
    }
}

