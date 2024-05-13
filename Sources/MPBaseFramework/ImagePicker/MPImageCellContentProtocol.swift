//
//  MPImageCellContentProtocol.swift
//  BasicProject
//
//  Created by ogawa on 2024/4/29.
//

import UIKit
import Photos


public protocol MPImagePickerCellDelegate: NSObject {
    
    
    func cellDidSelected(cell: UICollectionViewCell) -> (Int,Bool)
    
    func cellDidUnSelected(cell: UICollectionViewCell)
}


public protocol MPImageCellContentProtocol: UICollectionViewCell {
    
    var asset: PHAsset? {set get}
    
    var selectedIndex: Int {set get}
    
    var selectedImage: Bool {set get}
    
    var isDegraded: Bool {set get}
    
    var imageRequestID: PHImageRequestID {set get}
    
    var imageView: UIImageView {  get }
    
    var flagView: MPImagePickerSelectedFlagProtocol { get}
    
    var delegate: MPImagePickerCellDelegate? {set get}
    
    var imageManger: MPAssetsManager? {set get}
    
    var durationLabel: UILabel { get }
}

public protocol MPImagePickerSelectedFlagProtocol: UIView {
    
    var selectedView: MPTickSelectedProtocol? {set get}
    
    var selectedIndexLabel: UILabel { set get}
    
    func setSelected(index: Int,selected: Bool) -> Void
}

public protocol MPTickSelectedProtocol: UIView {
    
    var isSelected: Bool {set get}
}


