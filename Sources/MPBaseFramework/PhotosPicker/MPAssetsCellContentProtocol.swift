//
//  MPAssetsCellContentProtocol.swift
//  BasicProject
//
//  Created by ogawa on 2024/4/29.
//

import UIKit
import Photos

public enum MPAssetsPickerCellType {
    case image
    case live
    case video
}


public protocol MPAssetsPickerCellDelegate: NSObject {
    
    
    func cellDidSelected(cell: UICollectionViewCell) -> (Int,Bool)
    
    func cellDidUnSelected(cell: UICollectionViewCell)
}

public protocol MPAssetsPickerCellBaseProtocol: UICollectionViewCell {
    
    var cellType: MPAssetsPickerCellType { set get}
    
    var asset: PHAsset? {set get}
    
    var isSelectedAssets: Bool { set get }
    
    var selectedIndex: Int {set get}
    
    var imageRequestID: PHImageRequestID { set get}
    
    var isDegraded: Bool { set get}
    
    var isSingleChoise: Bool { set get}
    
    var flagView: MPAssetsPickerSelectedFlagProtocol? { get}
    
    var delegate: MPAssetsPickerCellDelegate? {set get}
    
    var imageManger: MPAssetsManager? {set get}
    
    var imageView: UIImageView {  get }
    
    func setSelectedFlag(index: Int,selected: Bool) 
}

public protocol MPAssetsPickerThumbnailCellProtocol: MPAssetsPickerCellBaseProtocol {
    
    

}

public protocol MPAssetsPickerLivePhotoCellProtocol: MPAssetsPickerCellBaseProtocol {
    
    var liveIcon: UIImageView { get }
}


public protocol MPAssetsPickerCellVideoCellProtocol: MPAssetsPickerCellBaseProtocol {
    
    var durationLabel: UILabel { get }
}




public protocol MPImageCellContentProtocol: UICollectionViewCell {
    
    var asset: PHAsset? {set get}
    
    var selectedIndex: Int {set get}
    
    var selectedImage: Bool {set get}
    
    var isDegraded: Bool {set get}
    
    var imageRequestID: PHImageRequestID {set get}
    
    var imageView: UIImageView {  get }
    
    var flagView: MPAssetsPickerSelectedFlagProtocol { get}
    
    var delegate: MPAssetsPickerCellDelegate? {set get}
    
    var imageManger: MPAssetsManager? {set get}
    
   
}

public protocol MPAssetsPickerSelectedFlagProtocol: UIView {
    
    var selectedView: MPTickSelectedProtocol? {set get}
    
    var selectedIndexLabel: UILabel { set get}
    
    func setSelected(index: Int,selected: Bool) -> Void
}

public protocol MPTickSelectedProtocol: UIView {
    
    var isTickSelected: Bool {set get}
}


