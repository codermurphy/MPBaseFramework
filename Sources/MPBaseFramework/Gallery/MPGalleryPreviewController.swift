//
//  MPGalleryPreviewController.swift
//  
//
//  Created by ogawa on 2024/6/11.
//

import UIKit

public class MPGalleryPreviewController<View: UIView,Resource: MPGalleryResourceProtocol>: UIViewController,
                                                                                           MPGalleryPreviewProtocol,
                                                                                           UICollectionViewDataSource,
                                                                                           UICollectionViewDelegateFlowLayout,
                                                                                           UIGestureRecognizerDelegate{
    
    
    
    // MARK: MPGalleryPreviewProtocol
    private var isPresent: Bool = false
    
    public var isHideNavigationBar: Bool = true {
        didSet {
            
            self.navigationController?.setNavigationBarHidden(isHideNavigationBar, animated: true)
            self.navigationController?.setToolbarHidden(isHideNavigationBar, animated: true)
        }
    }
    
    public var isHideStatusBar: Bool = true {
        didSet {
            if isPresent {
                self.modalPresentationCapturesStatusBarAppearance = isHideStatusBar
                self.setNeedsStatusBarAppearanceUpdate()
            }
            else {
                self.navigationController?.modalPresentationCapturesStatusBarAppearance = isHideStatusBar
                self.navigationController?.setNeedsStatusBarAppearanceUpdate()
            }

        }
    }

    
    public var targetFrame: CGRect { self.view.frame }
    
    public var sourceView: View { currentViewchangeHandle?(currentIndex)  ?? _sourceView }

    
    private(set) var _sourceView: View
    
    public var currentView: View? { (self.contentView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? MPGalleryPreviewDetailCellProtocol)?.imageView as? View}
        
    public var assets: Resource { _assets }
    
    private var _assets: Resource
    
    public var proxy: MPTransitionAnimator? { _animatorProxy }
    
    private var _animatorProxy: MPTransitionAnimator?
     
    public var currentIndex: Int  { _currentIndex }
    public var _currentIndex: Int {
        didSet {
            countLabel.text = "\(_currentIndex + 1)/\(assets.count)"
            countLabel.sizeToFit()
        }
    }
    
    public var currentViewchangeHandle: ((Int) -> View?)?
    
    public override var prefersStatusBarHidden: Bool { isHideStatusBar }
    
    private var isInitialScrolled: Bool = false
    
    // MARK: initial
    
    required public init(isPresent: Bool,sourceView: View,currentIndex: Int,assest: Resource) {
        self.isPresent = isPresent
        self._sourceView = sourceView
        self._assets = assest
        self._currentIndex = currentIndex
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
     
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        configAnimator()
        addUserInteractive()

        self.view.backgroundColor = .black

        layout()

    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !isInitialScrolled else { return }
        isInitialScrolled = true
        self.contentView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: false)

    }
    
    
    // MARK: transition
    private func configAnimator() {
        if self.isPresent {
            let previewInteractive = MPGalleryPercentDrivenInteractiveTransition()
            previewInteractive.prepare(toController: self, fromController: nil)
            self._animatorProxy = MPTransitionAnimator(percentDrivenInteractiveTransition: previewInteractive,
                                                       animateTransitionDelegate: MPGalleryPreviewAnimation(previewDelegate: self))
            self.transitioningDelegate = self.proxy
        }
    }
    
    
    private func addUserInteractive() {

//        let doubleGesture = UITapGestureRecognizer(target: self, action: #selector(self.doubleGestureHandle(gesture:)))
//        doubleGesture.numberOfTapsRequired = 2
//        doubleGesture.numberOfTouchesRequired = 1
////        doubleGesture.delaysTouchesBegan = false
////        doubleGesture.cancelsTouchesInView = false
//       self.view.addGestureRecognizer(doubleGesture)

    }
    
    
    
    //MARK: - user interactive handler
    
    
    @objc public func doubleGestureHandle(gesture: UITapGestureRecognizer) {
        guard let cell = contentView.visibleCells.first as? MPGalleryPreviewDetailCellProtocol else { return }
        if cell.scrollView.zoomScale != 1 {
            
            cell.scrollView.setZoomScale(1.0, animated: true)
        }
        else {
            let point = gesture.location(in: cell.scrollView)
            var zoomRect: CGRect = .zero
            zoomRect.size.width = cell.scrollView.frame.width / cell.scrollView.maximumZoomScale
            zoomRect.size.height = cell.scrollView.frame.height / cell.scrollView.maximumZoomScale
            zoomRect.origin.x = point.x - zoomRect.width * 0.5
            zoomRect.origin.y = point.y - zoomRect.height * 0.5
            cell.scrollView.zoom(to: zoomRect, animated: true)
        }
    }
    
    
    //MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        fatalError("override subclass")
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("override subclass")
    }
    
    
    //MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = collectionView.frame
        return collectionView.bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = contentView.visibleCells.first as? MPGalleryPreviewDetailCellProtocol else { return }
        if cell.scrollView.zoomScale == 1.0 {
            
            if let nav = self.navigationController {
                if nav.topViewController == self && nav.viewControllers.count == 1 {
                    nav.dismiss(animated: true, completion: nil)
                }
                else {
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if self.view.window != nil && !self.view.isHidden {
            let point = targetContentOffset.pointee
            let index = Int(round(point.x / scrollView.bounds.width))
            if index != currentIndex {
                _currentIndex = index
                currentViewchangeHandle?(currentIndex)
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let offset = CGFloat(self.currentIndex) * collectionView.frame.size.width

        return CGPoint(x: offset, y: 0)
    }
  
    
    //MARK: - UI
    
    public lazy var contentView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceHorizontal  = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.delaysContentTouches = false
        collectionView.canCancelContentTouches = false
//
        return collectionView
    }()
    
    public lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }()
    
    public func layout() {
        
        
        self.view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        
        self.view.addSubview(countLabel)
        countLabel.text = "\(currentIndex + 1)/\(assets.count)"
        
        countLabel.sizeToFit()
        let height = countLabel.frame.size.height
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        countLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        countLabel.heightAnchor.constraint(equalToConstant: height).isActive = true
        countLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,constant: -20).isActive = true
    }
    
    // MARK: deinit
    deinit {
        debugPrint(Self.self)
    }

}


