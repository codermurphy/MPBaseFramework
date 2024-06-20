//
//  MPAssetsModel.swift
//  
//
//  Created by ogawa on 2024/6/14.
//

import UIKit
import Photos

public class MPAssetsFetchResult: NSObject,MPGalleryResourceProtocol {
    
    public var count: Int {  fetchResult.count }
    
    public var selectedCount: Int { assetSelects.count }
    
    public var firstIndexPath: IndexPath? {
        
        return assetSelects.values.filter { $0.0 == 1}.first?.1
    }
    
    init(fetchResult: PHFetchResult<PHAsset>) {
        self.fetchResult = fetchResult
    }
    
    public var fetchResult: PHFetchResult<PHAsset>
    
    private(set) var assetSelects: [String: (Int,IndexPath,UIImage?)] = [String: (Int,IndexPath,UIImage?)]()
    
    
    subscript(index: Int) -> PHAsset {
        
        return fetchResult.object(at: index)
    }
    
    subscript(identifier: String) -> (isSelected: Bool,index: Int) {
        
        if let value = assetSelects[identifier],value.0 > 0 {
            return (true,value.0)
        }
        else {
            return (false,0)
        }
    }
    
    
    public func selectedAsset(identifier: String,indexPath: IndexPath,thumbnail: UIImage?) {
        assetSelects[identifier] = (assetSelects.count + 1,indexPath,thumbnail)
    }
    
    public func unSelectAsset(identifier: String) {
        guard let removeNumber = assetSelects.removeValue(forKey: identifier) else { return }
        
        let temp = assetSelects.filter { $0.value.0 > removeNumber.0}.keys
        for identifierString in temp {
            if let oldValue = assetSelects[identifierString] {
                assetSelects[identifierString] = (oldValue.0 - 1,oldValue.1,oldValue.2)
            }
        }
    }
    

}
