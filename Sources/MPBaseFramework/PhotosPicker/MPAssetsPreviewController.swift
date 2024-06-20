//
//  MPAssetsPreviewController.swift
//  BasicProject
//
//  Created by ogawa on 2022/1/17.
//

import UIKit
import Photos

public class MPAssetsPreviewController: MPGalleryPreviewController<UIImageView,MPAssetsFetchResult> {
        
    
    // MARK: property
    
    public override var isHideNavigationBar: Bool {
        
        didSet {
            self.navigationController?.setNavigationBarHidden(isHideNavigationBar, animated: true)
            self.navigationController?.setToolbarHidden(isHideNavigationBar, animated: true)
            
            let totalHeight = (self.navigationController?.toolbar.frame.height ?? 0) + self.selectedPreview.intrinsicContentSize.height
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self else { return }
                if self.isHideNavigationBar {
                    self.selectedPreview.transform = CGAffineTransform(translationX: 0, y: totalHeight)
                }
                else {
                    self.selectedPreview.transform = CGAffineTransform.identity
                }
            }
        }
    }
    
    
    private let imageCacheManager: PHCachingImageManager = PHCachingImageManager()
    private var screenScale: CGFloat {
        if let screen = self.view.window?.windowScene?.screen  {
            return screen.scale
        }
        else {
            return UIScreen.main.scale
        }
        
    }
    
    public var selectedChangeCallback: ((Bool,IndexPath) -> Void)?
    
    public override var targetFrame: CGRect {
 
        return super.targetFrame
        
    }
        
    public override var prefersStatusBarHidden: Bool { isHideStatusBar }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .slide}
    
    private var targetSize: CGSize {

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
    

    // MARK: life cycle
    public override func viewDidLoad() {
        self.contentView.register(MPAssetsPrevivewCell.self, forCellWithReuseIdentifier: MPAssetsPrevivewCell.description())
        super.viewDidLoad()
        cachingImamges(currentIndex: currentIndex)
        udpateSelectedView()
//        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        

        
    }

    public override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        isHideStatusBar = true
        isHideNavigationBar = true


    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isHideStatusBar = false
        isHideNavigationBar = false

    }
    
    public override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        isHideNavigationBar = false
        
    }
    
    // MARK: update selected View
    
    private func udpateSelectedView() {
        selectedPreview.updateImageInfos(infos: assets.assetSelects)
    }
    
    // MARK: UI
    
    private let tickSelectedView: MPTickSelectedView = MPTickSelectedView(size: .init(width: 25, height: 25))
    
    private let selectedPreview: MPAssetSelectedPreview = MPAssetSelectedPreview()
    
    
    // MARK: layout
    
    public override func layout() {
        
 
        self.view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        
        self.view.addSubview(selectedPreview)
        selectedPreview.delegate = self
        selectedPreview.translatesAutoresizingMaskIntoConstraints = false
        selectedPreview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        selectedPreview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        selectedPreview.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
  
        
        countLabel.text = "\(currentIndex + 1)/\(assets.count)"
        
        self.navigationItem.titleView = self.countLabel
        let info = assets[assets[currentIndex].localIdentifier]
        tickSelectedView.isTickSelected = info.isSelected
        tickSelectedView.addTarget(self, action: #selector(Self.selectedItemChangeHandle(item:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: tickSelectedView)

    }
    
    // MARK: user interactive

    
    @objc private func selectedItemChangeHandle(item: MPTickSelectedView) {
        item.isTickSelected.toggle()
        selectedChangeCallback?(item.isTickSelected,IndexPath(item: currentIndex, section: 0))
        let currentAssets = self.assets[currentIndex]
        if !item.isTickSelected {
            selectedPreview.removeAsset(identifier: currentAssets.localIdentifier)

        }
        else {
            let identifier = currentAssets.localIdentifier
            guard let info = self.assets.assetSelects[identifier] else { return }
            selectedPreview.addAssets(identifier: identifier, info: info)
        }
    }
    
    
    // MARK: caching image
    
    private func cachingImamges(currentIndex: Int) {
        imageCacheManager.stopCachingImagesForAllAssets()
        if assets.count > 0 {
            
            if assets.count <= 5 {
                let result = (0..<assets.count).map { self.assets[$0]}
                imageCacheManager.startCachingImages(for: result, targetSize: targetSize, contentMode: .aspectFit, options: imageOptions)
            }
            else {
                if currentIndex <= 1 {
                    let result = (0..<5).map { self.assets[$0]}
                    imageCacheManager.startCachingImages(for: result, targetSize: targetSize, contentMode: .aspectFit, options: imageOptions)
                }
                else if currentIndex == assets.count - 1 || currentIndex == assets.count - 2 {
                    let result = (assets.count-5..<assets.count).map { self.assets[$0]}
                    imageCacheManager.startCachingImages(for: result, targetSize: targetSize, contentMode: .aspectFit, options: imageOptions)
                }
                else {
                    let pre = (currentIndex-2...currentIndex).map { self.assets[$0]}
                    let next = (currentIndex+1..<currentIndex+2).map { self.assets[$0]}
                    let result = pre + next
                    imageCacheManager.startCachingImages(for: result, targetSize: targetSize, contentMode: .aspectFit, options: imageOptions)
                }
            }
        }
    }
    
    
    //MARK: - UICollectionViewDataSource
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return assets.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MPAssetsPrevivewCell.description(), for: indexPath) as! MPAssetsPrevivewCell
        
        let currentAssets = self.assets[indexPath.item]
        cell.assetIdentifier = currentAssets.localIdentifier
        return cell
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    public  override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MPAssetsPrevivewCell else { return }
        let currentAssets = self.assets[indexPath.item]
        imageCacheManager.requestImage(for: currentAssets, targetSize: targetSize, contentMode: .aspectFit, options: imageOptions) { image, _ in
            if cell.assetIdentifier == currentAssets.localIdentifier {
                cell.imageView.image = image
            }

        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MPAssetsPrevivewCell else { return }
        isHideStatusBar.toggle()
        isHideNavigationBar.toggle()
        

    }
    
    
    public override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        super.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        cachingImamges(currentIndex: currentIndex)
        let info = assets[assets[currentIndex].localIdentifier]
        tickSelectedView.isTickSelected = info.isSelected
        selectedPreview.updateCurrentIndex(identifier: assets[currentIndex].localIdentifier)
    }
    
    // MARK: UI
    
    
}


extension MPAssetsPreviewController: MPAssetSelectedPreviewDelegate {
    
    func didSelectedCell(targeIndexPath: IndexPath) {
        _currentIndex = targeIndexPath.item
        let info = assets[assets[currentIndex].localIdentifier]
        tickSelectedView.isTickSelected = info.isSelected
        self.contentView.scrollToItem(at: targeIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    
}


// MARK: cell

class MPAssetsPrevivewCell: MPGalleryPreviewDetailBaseCell {
    
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
