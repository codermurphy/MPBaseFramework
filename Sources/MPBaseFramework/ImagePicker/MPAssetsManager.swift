//
//  MPAssetsManager.swift
//  BasicProject
//
//  Created by ogawa on 2024/4/20.
//

import Foundation
import Photos

extension UICollectionView {
    func mp_indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}


public class MPAssetsManager: NSObject {
    
    // MARK: initial
    public init(thumbnailSize: CGSize,collectionView: UICollectionView) {
        self.thumbnailSize = thumbnailSize
        self.collectionView = collectionView
        super.init()
        
        PHPhotoLibrary.shared().register(self)
        
    }
    
    // MARK: property
    
    private let thumbnailSizeCachingManager: PHCachingImageManager = PHCachingImageManager()
        
    private let thumbnailSize: CGSize
    
    var allowsCachingHighQualityImages: Bool {
        set {
            thumbnailSizeCachingManager.allowsCachingHighQualityImages = newValue
        }
        get {
            return thumbnailSizeCachingManager.allowsCachingHighQualityImages
        }
    }
    
    private weak var collectionView: UICollectionView!
    
    private(set) var allAlbums: [PHAssetCollection] = []
        
    var currentAlbumsIndex: Int = 0
    
    private(set) var currenFetchtAssetsResult: PHFetchResult<PHAsset>?
    
    private var previousPreheatRect: CGRect = .zero
    
    private var lastImageRequestID: PHImageRequestID?
    
    
    // MARK: load all album
    func getAllValidAlbum() {
        var result: [PHAssetCollection] = []
        let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        smartAlbum.enumerateObjects { collection, index, _ in
            if collection.assetCollectionSubtype != .smartAlbumAllHidden {
                let asset = PHAsset.fetchAssets(in: collection, options: nil)
                if asset.count > 0 {
                    result.append(collection)
                }
            }
   
        }
        
        let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        album.enumerateObjects { collection, index, _ in
            let asset = PHAsset.fetchAssets(in: collection, options: nil)
            if asset.count > 0 {
                result.append(collection)
            }
        }
        self.allAlbums = result
        if let first = result.first {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            self.currenFetchtAssetsResult = PHAsset.fetchAssets(in: first, options: allPhotosOptions)
        }


    }
    
    func updateCurrentAsset(index: Int) -> String? {
        let selectedAsset = self.allAlbums[index]
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.currentAlbumsIndex = index
        self.currenFetchtAssetsResult = PHAsset.fetchAssets(in: selectedAsset, options: allPhotosOptions)
        self.resetCachedAssets()

        return selectedAsset.localizedTitle
        
    }
    
    // MARK: request image
    
    func requestImage(asset: PHAsset,completion: @escaping (PHAsset,UIImage?,Bool)->Void) -> PHImageRequestID {
        let imageOptions = PHImageRequestOptions()
        imageOptions.deliveryMode = .opportunistic
        imageOptions.version = .current
        imageOptions.resizeMode = .fast
        imageOptions.isNetworkAccessAllowed = false
                
        return thumbnailSizeCachingManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: imageOptions) { [weak self]image, info in
            var downloadFinished = false
            let requestId = info?[PHImageResultRequestIDKey] as? PHImageRequestID
            if let info  {
                downloadFinished = !(info[PHImageCancelledKey] as? Bool ?? false) && (info[PHImageErrorKey] == nil)
               
            }
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? true)
            if downloadFinished {
                completion(asset,image,isDegraded)

            }
            else {
                self?.cancelRequestImage(requestId: requestId)
              
            }
        }
    }
    
    func  cancelRequestImage(requestId: PHImageRequestID?) {
        guard let requestId,requestId != PHInvalidImageRequestID else { return }
        thumbnailSizeCachingManager.cancelImageRequest(requestId)
    }
    
    // MARK: caching image
    func updateCacheAssets(contentOffset: CGPoint,comletion: (()->Void)? = nil) {
        
        
        let imageOptions = PHImageRequestOptions()
        imageOptions.deliveryMode = .opportunistic
        imageOptions.version = .current
        imageOptions.resizeMode = .fast
        imageOptions.isNetworkAccessAllowed = false
        
        guard let nonilAssets = currenFetchtAssetsResult  else { return }
        let visibleRect = CGRect(origin: contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > collectionView.bounds.height / 3 else { return }
        
        // Compute the assets to start and stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.mp_indexPathsForElements(in: rect) }
            .map { indexPath in nonilAssets.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.mp_indexPathsForElements(in: rect) }
            .map { indexPath in nonilAssets.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        thumbnailSizeCachingManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: imageOptions)
        
        
        thumbnailSizeCachingManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: imageOptions)

        

        previousPreheatRect = preheatRect
        
        comletion?()
    }
    
    private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
       if old.intersects(new) {
           var added = [CGRect]()
           if new.maxY > old.maxY {
               added += [CGRect(x: new.origin.x, y: old.maxY,
                                width: new.width, height: new.maxY - old.maxY)]
           }
           if old.minY > new.minY {
               added += [CGRect(x: new.origin.x, y: new.minY,
                                width: new.width, height: old.minY - new.minY)]
           }
           var removed = [CGRect]()
           if new.maxY < old.maxY {
               removed += [CGRect(x: new.origin.x, y: new.maxY,
                                  width: new.width, height: old.maxY - new.maxY)]
           }
           if old.minY < new.minY {
               removed += [CGRect(x: new.origin.x, y: old.minY,
                                  width: new.width, height: new.minY - old.minY)]
           }
           return (added, removed)
       } else {
           return ([new], [old])
       }
   }
    
    func resetCachedAssets() {
        thumbnailSizeCachingManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    deinit {
        resetCachedAssets()
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}


extension MPAssetsManager: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let currenFetchtAssetsResult else { return }
        guard let changes = changeInstance.changeDetails(for: currenFetchtAssetsResult)
            else { return }
        
        // Change notifications may originate from a background queue.
        // As such, re-dispatch execution to the main queue before acting
        // on the change, so you can update the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            self.currenFetchtAssetsResult = changes.fetchResultAfterChanges
            // If we have incremental changes, animate them in the collection view.
            if changes.hasIncrementalChanges {
                guard let collectionView = self.collectionView else { fatalError() }
                // Handle removals, insertions, and moves in a batch update.
                collectionView.performBatchUpdates({
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
                // We are reloading items after the batch update since `PHFetchResultChangeDetails.changedIndexes` refers to
                // items in the *after* state and not the *before* state as expected by `performBatchUpdates(_:completion:)`.
                if let changed = changes.changedIndexes, !changed.isEmpty {
                    collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                }
            } else {
                // Reload the collection view if incremental changes are not available.
                collectionView.reloadData()
            }
            resetCachedAssets()
        }
    }
    
    
}
