//
//  MPAssetsPreviewController.swift
//  BasicProject
//
//  Created by ogawa on 2022/1/17.
//

import UIKit
import Photos

extension MPImagePreviewController.PreviewType {
    
    public static let assets = MPImagePreviewController.PreviewType(rawValue: "assets")
}

public class MPAssetsPreviewController: MPImagePreviewController {
    
    // MARK: property
    
    private var isHideStatusBar = false
    
    private let imageCacheManager: PHCachingImageManager = PHCachingImageManager()
    
    private var imageAssets: PHFetchResult<PHAsset>
    
    private var screenScale: CGFloat {
        if let screen = self.view.window?.windowScene?.screen  {
            return screen.scale
        }
        else {
            return UIScreen.main.scale
        }
        
    }
    
    public override var prefersStatusBarHidden: Bool { isHideStatusBar }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .slide}
    
    private var targetSize: CGSize {
//        return CGSize(width: self.flowLayout.itemSize.width * screenScale, height: self.flowLayout.itemSize.height * screenScale)
        return  CGSize(width: self.view.bounds.width * screenScale,
                       height: self.view.bounds.height * screenScale)
    }
    
    private let imageOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        options.version = .current
        options.resizeMode = .fast
        return options
    }()
    
    
    // MARK: initial
    public init(souceView: UIImageView,assets: PHFetchResult<PHAsset>,currentIndex: Int,pageChangeHandle: ((IndexPath) -> UIView?)? = nil) {
        self.imageAssets = assets
        super.init(nibName: nil, bundle: nil)
        self.previewType = .assets
        self.modalPresentationStyle = .currentContext
        self.sourceView = souceView
        self.pageChangeHandle = pageChangeHandle
        self.currentIndex = currentIndex
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {

        self.cachingImamges(currentIndex: self.currentIndex)

        self.contentView.register(MPAssetsPrevivewCell.self, forCellWithReuseIdentifier: MPAssetsPrevivewCell.description())
        
        super.viewDidLoad()
        
        self.contentView.scrollToItem(at: IndexPath(item: self.currentIndex, section: 0), at: .centeredHorizontally, animated: false)

        self.view.backgroundColor = .black
        

    }
    
    public override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)

        isHideStatusBar = true
        
        self.setNeedsStatusBarAppearanceUpdate()


    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    
    
    // MARK: caching image
    
    private func cachingImamges(currentIndex: Int) {
        imageCacheManager.stopCachingImagesForAllAssets()
        if imageAssets.count > 0 {
            
            if imageAssets.count <= 5 {
                let result = (0..<imageAssets.count).map { self.imageAssets.object(at: $0)}
                imageCacheManager.startCachingImages(for: result, targetSize: targetSize, contentMode: .aspectFit, options: imageOptions)
            }
            else {
                if currentIndex <= 1 {
                    let result = (0..<5).map { self.imageAssets.object(at: $0)}
                    imageCacheManager.startCachingImages(for: result, targetSize: targetSize, contentMode: .aspectFit, options: imageOptions)
                }
                else if currentIndex == imageAssets.count - 1 || currentIndex == imageAssets.count - 2 {
                    let result = (imageAssets.count-5..<imageAssets.count).map { self.imageAssets.object(at: $0)}
                    imageCacheManager.startCachingImages(for: result, targetSize: targetSize, contentMode: .aspectFit, options: imageOptions)
                }
                else {
                    let pre = (currentIndex-2...currentIndex).map { self.imageAssets.object(at: $0)}
                    let next = (currentIndex+1..<currentIndex+2).map { self.imageAssets.object(at: $0)}
                    let result = pre + next
                    imageCacheManager.startCachingImages(for: result, targetSize: targetSize, contentMode: .aspectFit, options: imageOptions)
                }
            }
        }
    }
    

    
    public override func layout() {
        countLabel.text = "\(currentIndex + 1)/\(imageAssets.count)"

        super.layout()
        
        
    }
    
}

// MARK: UICollection dataSource
extension MPAssetsPreviewController {
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageAssets.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell { 
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MPAssetsPrevivewCell.description(), for: indexPath) as! MPAssetsPrevivewCell
        let currentAssets = self.imageAssets.object(at: indexPath.item)
        cell.assetIdentifier = currentAssets.localIdentifier

    
        return cell
    }
    
    public  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MPAssetsPrevivewCell else { return }
        let currentAssets = self.imageAssets.object(at: indexPath.item)
        imageCacheManager.requestImage(for: currentAssets, targetSize: targetSize, contentMode: .aspectFit, options: imageOptions) { image, _ in
            if cell.assetIdentifier == currentAssets.localIdentifier {
                cell.imageView.image = image
            }
            
        }
    }
}

// MARK: UICollectionView delegate
extension MPAssetsPreviewController {
    
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !scrollView.isHidden {
            let point = scrollView.contentOffset
            let index = Int(round(point.x / scrollView.bounds.width))
            if index != currentIndex {
                countLabel.text = "\(index + 1)/\(imageAssets.count)"
                currentIndex = index
                self.cachingImamges(currentIndex: currentIndex)
                guard let newSourceView = pageChangeHandle?(IndexPath(item: currentIndex, section: 0)) as? UIImageView else { return }
                self.updateSourceView(view: newSourceView)
            }
        }
    }
    
}


// MARK: cell

class MPAssetsPrevivewCell: MPImagePreviewCell {
    
    var assetIdentifier: String?
    
    var imageRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    weak var imageManger: MPAssetsManager?
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageManger?.cancelRequestImage(requestId: imageRequestID)
        imageManger = nil
        imageRequestID = PHInvalidImageRequestID
    }
}
