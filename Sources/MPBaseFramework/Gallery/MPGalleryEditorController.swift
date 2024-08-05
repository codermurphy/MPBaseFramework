//
//  MPGalleryEditorController.swift
//  
//
//  Created by ogawa on 2024/6/26.
//

import UIKit

internal class MPGalleryEditorController: UIViewController {
    
    // MARK: property
    
    private var isLayouted: Bool = false
    
    private var isToolBarItemsLayouted: Bool = false
    
    private let sourceImage: UIImage
    
    
    init(image: UIImage) {
        self.sourceImage = image
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.imageView.image = sourceImage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        configToolBar()

        self.view.addSubview(scrollView)
        self.view.addSubview(blurView)
        self.view.addSubview(bottomToolBar)
        self.view.addSubview(topToolBar)
        scrollView.addSubview(imageView)
        self.view.addSubview(croppingGridView)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
                
        if !isLayouted {
            
            setupUI()

            isLayouted = true
        }

    }
    
    // MARK: user interactive
    
    @objc private func cancelItemHandle(item: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @objc private func completionItemHandle(item: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @objc private func croppingItemHandle(item: UIBarButtonItem) {
        
    }
    
    @objc private func backwardItemHandle(item: UIBarButtonItem) {
        
    }
    
    @objc private func foreardItemHandle(item: UIBarButtonItem) {
        
    }
    
    // MARK: UI
    
    private lazy var bottomToolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.tintColor = .white
        
        let standardAppearance = UIToolbarAppearance()
        standardAppearance.configureWithTransparentBackground()
        toolBar.standardAppearance = standardAppearance

        return toolBar
    }()
    
    private let topToolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.tintColor = .white
        let standardAppearance = UIToolbarAppearance()
        standardAppearance.configureWithTransparentBackground()
        toolBar.standardAppearance = standardAppearance
        return toolBar
    }()
        
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = true
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.clipsToBounds = false
        scrollView.backgroundColor = .black
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let blurView: UIVisualEffectView = {
        let style = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: style)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let croppingGridView = MPGalleryEditorCroppingGridView()
    
    
    
    private func configToolBar() {
        let cancelItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(Self.cancelItemHandle(item:)))
        let croppingItem = UIBarButtonItem(image: UIImage(systemName: "crop.rotate"), style: .plain, target: self, action: #selector(Self.croppingItemHandle(item:)))
        let bottomToolFlexiableItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let bottomToolFlexiableItem2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let completionItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(Self.completionItemHandle(item:)))
        completionItem.setTitleTextAttributes([.foregroundColor: UIColor.green], for: .normal)
        bottomToolBar.items = [cancelItem,bottomToolFlexiableItem,croppingItem,bottomToolFlexiableItem2,completionItem]
        
        let backwardItem =  UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.backward")?.withTintColor(.brown, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(Self.backwardItemHandle(item:)))
        
        
        
        let forwardItem =  UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.forward")?.withTintColor(.brown, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(Self.foreardItemHandle(item:)))
        
        topToolBar.items = [backwardItem,forwardItem]
    }
    
    private func setupUI() {
        


        blurView.frame = self.view.bounds
        
        topToolBar.frame = CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.bounds.width, height: 44)
        bottomToolBar.frame = CGRect(x: 0, y: self.view.bounds.height - self.view.safeAreaInsets.bottom - 44, width: self.view.bounds.width, height: 44)

        scrollView.delegate = self
        let maxWidth = self.view.frame.width - 40
        let maxHeight = self.view.frame.height - topToolBar.frame.height - bottomToolBar.frame.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - 40
        let scale = sourceImage.size.width / sourceImage.size.height
        var targetWidth = maxHeight * scale
        var targerHegiht: CGFloat = 0
        if targetWidth > maxWidth {
            targetWidth = maxWidth
            targerHegiht = maxWidth / scale
            let scrollViewX = 20.0
            let scrollViewY = (maxHeight - targerHegiht) * 0.5 + topToolBar.frame.maxY
            scrollView.frame = CGRect(x: scrollViewX, y: scrollViewY, width: targetWidth, height: targerHegiht)

        }
        else {
            targetWidth = maxHeight * scale
            targerHegiht = maxHeight
            let scrollViewX = (self.view.bounds.width - targetWidth) * 0.5
            let scrollViewY = 20 + topToolBar.frame.maxY
            scrollView.frame = CGRect(x: scrollViewX, y: scrollViewY, width: targetWidth, height: targerHegiht)
        }
        
        croppingGridView.frame = scrollView.frame
        imageView.frame = scrollView.bounds
        
        let targetFrame = scrollView.frame
        let maskLayer = CAShapeLayer()
        
        let maskPath1 = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: targetFrame.minY))
        let maskPath2 = UIBezierPath(rect: CGRect(x: 0, y: targetFrame.maxY, width: self.view.bounds.width, height: self.view.bounds.height -  targetFrame.maxY))
        let maskPath3 = UIBezierPath(rect: CGRect(x: 0, y: 0, width: targetFrame.minX , height: self.view.bounds.height))
        let maskPath4 = UIBezierPath(rect: CGRect(x: targetFrame.maxX, y: 0, width: targetFrame.minX , height: self.view.bounds.height))
        maskPath2.append(maskPath1)
        maskPath3.append(maskPath2)
        maskPath4.append(maskPath3)
        maskLayer.path = maskPath4.cgPath
        blurView.layer.mask = maskLayer
        
    }
    

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        isLayouted = false

        
    }
    

}



extension MPGalleryEditorController: UIScrollViewDelegate {
    

    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
