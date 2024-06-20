//
//  MPAssetSelectedPreview.swift
//  
//
//  Created by ogawa on 2024/6/17.
//

import UIKit
 
protocol MPAssetSelectedPreviewDelegate: NSObjectProtocol {
    
    func didSelectedCell(targeIndexPath: IndexPath)
}


class MPAssetSelectedPreview: UIView {
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override var intrinsicContentSize: CGSize { CGSize(width: -1, height: 100)}
    
    
    private var imagesnInfo: [String: (Int,IndexPath,UIImage?)] = [String: (Int,IndexPath,UIImage?)]()
    
    private var identifiers: [String] = []
    
    private var currentIndex: Int = 0
    
    
    weak var delegate: MPAssetSelectedPreviewDelegate?
    
    // MARK: update dataSource
    
    func updateImageInfos(infos: [String: (Int,IndexPath,UIImage?)]) {
        imagesnInfo = infos
        identifiers = infos.sorted(by:  { $0.value.0 < $1.value.0}).map { $0.key}
        
        self.collectionView.reloadData()
    }
    
    func removeAsset(identifier: String) {
        guard let index = identifiers.firstIndex(of: identifier) else { return }
        imagesnInfo.removeValue(forKey: identifier)
        identifiers.remove(at: index)
        let indexPath = IndexPath(item: index, section: 0)
        currentIndex = -1
        self.collectionView.deleteItems(at: [indexPath])
    }
    
    func addAssets(identifier: String,info: (Int,IndexPath,UIImage?)) {
        let oldIndexPath: IndexPath? = currentIndex != -1 ? IndexPath(item: currentIndex, section: 0) : nil
        self.identifiers.append(identifier)
        imagesnInfo[identifier] = info
        let indexPath = IndexPath(item: self.identifiers.count - 1, section: 0)
        currentIndex = self.identifiers.count - 1
        self.collectionView.performBatchUpdates {
            self.collectionView.insertItems(at: [indexPath])
            if let oldIndexPath {
                self.collectionView.reloadItems(at: [oldIndexPath])
            }
            
        }

 
    }
    
    func updateCurrentIndex(identifier: String) {
        if let index = identifiers.firstIndex(of: identifier) {
            let indexPath = IndexPath(item: index, section: 0)
            currentIndex = index
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        }
        else {
            currentIndex = -1
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        }

    }
    
    
    // MARK: UI

    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceHorizontal  = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MPAssetSelectedPreviewCell.self, forCellWithReuseIdentifier: MPAssetSelectedPreviewCell.description())
        return collectionView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = self.bounds
    }
    
}


class MPAssetSelectedPreviewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.clipsToBounds = true
        self.contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // MARK: UI
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.contentView.bounds
        
    }
    
    
}

extension MPAssetSelectedPreview: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesnInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MPAssetSelectedPreviewCell.description(), for: indexPath) as! MPAssetSelectedPreviewCell
        
        let infos = imagesnInfo[identifiers[indexPath.item]]
        cell.imageView.image = infos?.2
        
        if indexPath.item == currentIndex {
            cell.imageView.layer.borderWidth = 5
            cell.imageView.layer.borderColor = UIColor.green.cgColor
        }
        else {
            cell.imageView.layer.borderWidth = 0
        }

        
        return cell
    }
    
    
}

extension MPAssetSelectedPreview: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 70, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        guard  currentIndex != indexPath.item else { return }
        currentIndex = indexPath.row
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        
        guard let infos = imagesnInfo[identifiers[indexPath.item]] else { return }
        delegate?.didSelectedCell(targeIndexPath: infos.1)
    }
    
    
}
