//
//  MPGalleryImagePreviewController.swift
//  
//
//  Created by ogawa on 2024/6/11.
//

import UIKit

extension Array: MPGalleryResourceProtocol {
    
}


// MARK: navigationController

public class MPGalleryImagePreviewNavigationController: UINavigationController {
    
    // MARK: property
    private let rootController: any MPGalleryPreviewProtocol
    
    private var proxy: MPTransitionAnimator?
    
    // MARK: initial
    
    public init(rootController: any MPGalleryPreviewProtocol) {
        self.rootController = rootController
        super.init(rootViewController: rootController)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.isNavigationBarHidden = true
        configAnimator()
    }
    
    // MARK: TransitionAnimator
    private func configAnimator() {
        let previewInteractive = MPGalleryPercentDrivenInteractiveTransition()
        previewInteractive.prepare(toController: rootController, fromController: nil)
        self.proxy = MPTransitionAnimator(percentDrivenInteractiveTransition: previewInteractive,
                                                   animateTransitionDelegate: MPGalleryPreviewAnimation(previewDelegate: rootController))
        self.transitioningDelegate = self.proxy
        
        
    }
    
    deinit {
        debugPrint(Self.self)
    }
}

// MARK: image previe
public class MPGalleryImagePreviewController: MPGalleryPreviewController<UIImageView,[UIImage]> {

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.contentView.register(MPGalleryPreviewDetailBaseCell.self, forCellWithReuseIdentifier: MPGalleryPreviewDetailBaseCell.description())
    }
    

    //MARK: - UICollectionViewDataSource
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return assets.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MPGalleryPreviewDetailBaseCell.description(), for: indexPath) as! MPGalleryPreviewDetailCellProtocol
        cell.imageView.image = assets[indexPath.row]
        return cell
    }
}


// MARK: image names preview
public class MPGalleryImageNamePreviewController: MPGalleryPreviewController<UIImageView,[String]> {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.contentView.register(MPGalleryPreviewDetailBaseCell.self, forCellWithReuseIdentifier: MPGalleryPreviewDetailBaseCell.description())
    }
    
    //MARK: - UICollectionViewDataSource
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return assets.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MPGalleryPreviewDetailBaseCell.description(), for: indexPath) as! MPGalleryPreviewDetailCellProtocol
        cell.imageView.image = UIImage(named: assets[indexPath.row])
        return cell
    }
}
