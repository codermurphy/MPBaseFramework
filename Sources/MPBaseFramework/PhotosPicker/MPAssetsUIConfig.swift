//
//  MPAssetsUIConfig.swift
//
//
//  Created by ogawa on 2024/6/5.
//

import UIKit

public struct MPAssetsUIConfig {
    
    public static var share = MPAssetsUIConfig()
    
    /// 可选的总数
    public var maxSelectCount: Int = 9 {
        didSet {
            if self.maxSelectCount <= 0 {
                self.maxSelectCount = 1
            }
        }
    }
    
    ///  是否为单选
    public var isSingleChoise: Bool { return maxSelectCount == 1}
    
    /// 每行图片个数
    public var rowCount = 3
    
    /// 可自定义image的cell
    public var imageCellType: MPAssetsPickerThumbnailCellProtocol.Type = MPAssetsImageCell.self
    
    /// 可自定义live photo
    public var livePhotoCellType: MPAssetsPickerLivePhotoCellProtocol.Type = MPAssetsLivePhotoCell.self
    
    /// 可自定义video cell
    public var videoCellType: MPAssetsPickerCellVideoCellProtocol.Type = MPAssetsVideoCell.self
    
}
