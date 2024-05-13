//
//  MPImagePickerController.swift
//  BasicProject
//
//  Created by ogawa on 2022/1/11.
//

import UIKit
import Photos
import PhotosUI



public class MPImagePickerController: UIViewController {

    
    
    //MARK: - private property
                
    
    private var imageManager:  MPAssetsManager!
    
    private var flowLayout: UICollectionViewFlowLayout {
        return self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    private var thumbnailSize: CGSize {
        return  CGSize(width: min(self.flowLayout.itemSize.width * screenScale,screenScale * 100),
                       height: min(self.flowLayout.itemSize.height * screenScale,screenScale * 100))
        
    }
    
    private var titleView: MPImagePickerTitleView? {
        return self.navigationItem.titleView as? MPImagePickerTitleView
    }
    
    private weak var albumPicker: MPAlbumsPickerView?
        
    /// 每行显示数量
    private let perRowCount: Int = 3
    
    /// 被选中的indexPath
    private var selectedIndex: [String: Int] = [String: Int]()
    
    /// 最多可选中数量
    private var maxSelectedCount:Int = 9
    
    private var lastDetailIndexPath: IndexPath?
    
    private var previewController: MPAssetsPreviewController?
    
    private var screenScale: CGFloat {
        if let screen = self.view.window?.windowScene?.screen  {
            return screen.scale
        }
        else {
            return UIScreen.main.scale
        }
        
    }
    
    
    
    //MARK: - initial
    
    public static func presentImagePicker() -> UINavigationController {
        let picker = MPImagePickerController()
        let nav = MPAssetsNavigationController(rootViewController: picker)
        nav.modalPresentationStyle = .fullScreen
        return nav
    }
    
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        configNavigationItem()
        setupUI()
        updateItemSizez(size: self.view.bounds.size)
        imageManager = MPAssetsManager(thumbnailSize: thumbnailSize ,collectionView: self.collectionView)
        requestAuthorization()


    }
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateCachedAssets(contentOffset: self.collectionView.contentOffset)
    }
    
    
    //MARK: - private methods
    
    private func requestAuthorization() {
        showLoadingView()
        if #available(iOS 14.0, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self]status in
                DispatchQueue.main.async {
                    switch status {
                    case .notDetermined:
                        self?.hideLoadingView()
                    case .denied,.restricted:
                        self?.hideLoadingView()
                        self?.alertRequestAuthorization()
                    case .authorized,.limited:
                        self?.imageManager.getAllValidAlbum()
                        self?.imageManager.resetCachedAssets()
                        self?.hideLoadingView()
                        self?.collectionView.reloadData()
                        self?.configTitleView()
                    default:
                        break
                    }
                }

            }
        }
        else {
            PHPhotoLibrary.requestAuthorization {[weak self] status in
                
                DispatchQueue.main.async {
                    self?.hideLoadingView()
                    switch status {
                    case .notDetermined:
                        self?.hideLoadingView()
                    case .denied,.restricted:
                        self?.hideLoadingView()
                        self?.alertRequestAuthorization()
                    case .authorized:
                        self?.imageManager.getAllValidAlbum()
                        self?.imageManager.resetCachedAssets()
                        self?.hideLoadingView()
                        self?.collectionView.reloadData()
                        self?.configTitleView()
                    default:
                        break
                    }
                }

            }
        }
    }
        
    private func configNavigationItem() {
        
        if #available(iOS 14.0, *) {
            var items: [UIBarButtonItem] = []

            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch status {
            case .limited:
                let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addItemClickedHandler(item:)))
                items.append(addItem)
    
            default:
                break
            }
            self.navigationItem.rightBarButtonItems = items

        }
        let closeItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(self.closeItemClickedHandler(item:)))
        closeItem.tintColor = .black
        self.navigationItem.leftBarButtonItem = closeItem


    }
    
    private func configTitleView() {
        
        if let first = imageManager.allAlbums.first {
            if self.titleView == nil {
                let titleView = MPImagePickerTitleView(title: first.localizedTitle)
                titleView.addTarget(self, action: #selector(self.titleViewClickedHandler(titleView:)), for: .touchUpInside)
                self.navigationItem.titleView = titleView
            }
        }
    }
    
    private func updateItemSizez(size: CGSize) {
        let validWidth = size.width - self.flowLayout.sectionInset.left - self.flowLayout.sectionInset.right - CGFloat(perRowCount - 1) * self.flowLayout.minimumInteritemSpacing
        let avgWidth =  validWidth / CGFloat(perRowCount)
        self.flowLayout.itemSize = CGSize(width: avgWidth, height: avgWidth)
    }
    
    
    
    
    private func alertRequestAuthorization() {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "相册权限", message: "需要开启相册权限", preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            let confirm = UIAlertAction(title: "设置", style: .default) { _ in
                
                let url = URL(string: UIApplication.openSettingsURLString)!
                UIApplication.shared.open(url, options: [:]) { _ in
                    
                }
            }
            
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    private func showLoadingView() {
        
        let activity = UIActivityIndicatorView(style: .large)
        activity.tag = 999
        activity.color = .lightGray
        activity.startAnimating()
        self.view.addSubview(activity)
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    private func hideLoadingView() {
        if let activity = self.view.viewWithTag(999) {
            activity.removeFromSuperview()
        }
    }
    
    private func updateCachedAssets(contentOffset: CGPoint) {
        guard isViewLoaded && view.window != nil else { return }
        self.imageManager.allowsCachingHighQualityImages = true
        self.imageManager.updateCacheAssets(contentOffset: contentOffset)
    }
    

    
    
    //MARK: - user interactive
    
    @objc private func closeItemClickedHandler(item: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func addItemClickedHandler(item: UIBarButtonItem) {
        
        if #available(iOS 14, *) {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)

        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc private func titleViewClickedHandler(titleView: MPImagePickerTitleView) {
        titleView.isSelected.toggle()
        if titleView.isSelected {
            if !self.imageManager.allAlbums.isEmpty {
                let dataSouce = self.imageManager.allAlbums.map { $0.localizedTitle ?? "Unkonw Album"}
                self.albumPicker = MPAlbumsPickerView.show(controller: self,dataSouce: dataSouce,currentIndex: self.imageManager.currentAlbumsIndex)
                self.albumPicker?.hideCallback = { [weak self] in
                    self?.titleView?.isSelected = false
                }
                self.albumPicker?.didSelectedAlbumBlock = { [weak self] index in
                    guard let self else { return }
                    self.titleView?.isSelected = false
                    if index < self.imageManager.allAlbums.count {
                        let title = self.imageManager.updateCurrentAsset(index: index)
                        self.titleView?.updateTitle(title: title ?? "", animated: true)
                        self.collectionView.reloadData()
                        self.updateCachedAssets(contentOffset: .zero)
                    }
                }

            }

        }
        else {
            self.albumPicker?.hidden()
        }
    }
    
    /// 选中
    /// - Parameter indexPath: indexpath
    /// - Returns: int 当前选中数量，bool 是否选中
    private func selectedIndexPath(_ indexPath: IndexPath) -> (Int,Bool) {
        guard selectedIndex.count < maxSelectedCount else {return (0,false)}
        guard let asset = imageManager.currenFetchtAssetsResult?[indexPath.row] else { return (0,false) }
        guard !selectedIndex.keys.contains(asset.localIdentifier) else {return (0,false)}
        let count = selectedIndex.count + 1
        selectedIndex[asset.localIdentifier] = count
        return (count,true)
    }
    
    
    /// 移除选中
    /// - Parameter indexPath: indexpath
    private func removeIndexPath(_ indexPath: IndexPath) {
        guard let asset = imageManager.currenFetchtAssetsResult?[indexPath.row] else { return  }
        let result = selectedIndex.sorted(by: { $0.value < $1.value}).map { return $0.key}
        if let last = result.last,last == asset.localIdentifier  {
            selectedIndex.removeValue(forKey: last)
        }
        else {
            if let targetIndex = result.firstIndex(where: {$0 == asset.localIdentifier}) {
                for index in targetIndex..<result.count {
                    if index == targetIndex {
                        selectedIndex.removeValue(forKey: result[index])
                    }
                    else {
                        let targetIdentifier = result[index]
                        if let value = selectedIndex[targetIdentifier] {
                            selectedIndex[targetIdentifier] = value - 1
                        }
                        
                    }
                }
            }
            let visibleCells = self.collectionView.indexPathsForVisibleItems
            self.collectionView.reloadItems(at: visibleCells)
        }
    }
    
    
    // MARK: UI
    
    private lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumLineSpacing = 2
        
        layout.minimumInteritemSpacing = 2
        
        layout.scrollDirection = .vertical
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0)
        
        let result = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        
        result.backgroundColor = .white
        result.alwaysBounceVertical = true
        result.allowsMultipleSelection = true
        
        result.dataSource = self
        result.delegate = self
        result.register(MPImagePickerCell.self, forCellWithReuseIdentifier: "MPImagePickerCell-identifier")
        
        return result
        
    }()
    
    private func setupUI() {
        
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

    }
    
    

    

    //MARK: - override methods
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let validWidth = size.width - self.flowLayout.sectionInset.left - self.flowLayout.sectionInset.right - CGFloat(perRowCount - 1) * self.flowLayout.minimumInteritemSpacing
        let avgWidth = validWidth / CGFloat(perRowCount)
        self.flowLayout.itemSize = CGSize(width: avgWidth, height: avgWidth)
        self.flowLayout.invalidateLayout()
    }
    
    deinit {
        debugPrint(Self.self)
    }

}

// MARK: CollectionView datasource
extension MPImagePickerController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageManager.currenFetchtAssetsResult?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MPImagePickerCell-identifier", for: indexPath) as! MPImagePickerCell
        
        cell.delegate = self

        cell.imageManger = imageManager

        if let asset = imageManager.currenFetchtAssetsResult?.object(at: indexPath.item) {
            cell.asset = asset
            if let index = selectedIndex[asset.localIdentifier] {
                cell.setSelectedFlag(index: index, selected: true)
            }
            else {
                cell.setSelectedFlag(index: 0, selected: false)
            }
        }
        
        if let lastDetailIndexPath = self.lastDetailIndexPath,let preview = self.presentedViewController as? MPAssetsPreviewController  {
            if lastDetailIndexPath == indexPath {
                preview.updateSourceView(view: cell.imageView)
                self.lastDetailIndexPath = nil
            }
        }
        
        

        return cell
    }
}

//MARK: - CollectionView delgate

extension MPImagePickerController:UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MPImagePickerCell else { return }
        if isViewLoaded && view.window != nil {
            if let asset = imageManager.currenFetchtAssetsResult?.object(at: indexPath.item) {
                cell.imageRequestID = imageManager.requestImage(asset: asset) { [weak cell] asset, image,isDegraded in
                    if let image,let cellAssetsIdentifier = cell?.asset?.localIdentifier,asset.localIdentifier == cellAssetsIdentifier {
                        cell?.imageView.image = image
                        cell?.isDegraded = isDegraded
                    }
                }
            }
        }

    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        guard let cell = collectionView.cellForItem(at: indexPath) as? MPImagePickerCell else { return }
        guard let nonilAssets = self.imageManager.currenFetchtAssetsResult else { return }
        let preview = MPAssetsPreviewController(souceView: cell.imageView,
                                                assets: nonilAssets,
                                                currentIndex: indexPath.row) { [weak self] indexPath in
            if let cell = self?.collectionView.cellForItem(at: indexPath) as? MPImagePickerCell {
                self?.lastDetailIndexPath = nil
                return cell.imageView
            }
            else {
                collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)

                self?.lastDetailIndexPath = indexPath
                return nil
            }
           
        }
        
        self.navigationController?.pushViewController(preview, animated: true)
//        self.present(preview, animated: true, completion: nil)

    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.imageManager.allowsCachingHighQualityImages = false
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        self.updateCachedAssets(contentOffset: targetContentOffset.pointee)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        self.updateCachedAssets(contentOffset: CGPoint(x: 0, y: self.view.safeAreaInsets.top))
        return true
    }
    
}


//MARK: - MPImagePickerCellDelegate
extension MPImagePickerController: MPImagePickerCellDelegate {
    
    public func cellDidSelected(cell: UICollectionViewCell) -> (Int,Bool) {
        guard let indexPath = self.collectionView.indexPath(for: cell) else { return (0,false)}

        return selectedIndexPath(indexPath)
    }
    
    public func cellDidUnSelected(cell: UICollectionViewCell) {
        guard let indexPath = self.collectionView.indexPath(for: cell) else { return }

        removeIndexPath(indexPath)
    }
    

}

