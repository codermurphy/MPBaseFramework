//
//  MPImagePreviewController.swift
//  BasicProject
//
//  Created by ogawa on 2022/1/4.
//

import UIKit
import Photos

public class MPImagePreviewController: UIViewController,MPImagePreviewProtocol {
    
    
    
    public struct PreviewType: RawRepresentable,Equatable{
        public var rawValue: String
        
        public static let imageNames = PreviewType(rawValue: "imageNames")
        
        public static let images = PreviewType(rawValue: "images")
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    public init(souceView: UIImageView,imags: [UIImage],currentIndex: Int,pageChangeHanlder: ((IndexPath) -> UIImageView?)? = nil) {
        
        super.init(nibName: nil, bundle: nil)
        self.previewType = .imageNames
        self.modalPresentationStyle = .overFullScreen
        self.sourceView = souceView
        self.images = imags
        self.pageChangeHanlder = pageChangeHanlder
        self.currentIndex = currentIndex

    }
    
    
    public init(souceView: UIImageView,imageNames: [String],currentIndex: Int,pageChangeHanlder: ((IndexPath) -> UIImageView?)? = nil) {
        
        super.init(nibName: nil, bundle: nil)
        self.previewType = .imageNames
        self.modalPresentationStyle = .overFullScreen
        self.sourceView = souceView
        self.imageContents = imageNames
        self.pageChangeHanlder = pageChangeHanlder
        self.currentIndex = currentIndex

    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        configAnimator()
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        // Do any additional setup after loading the view.
        if #available(iOS 11.0, *) {
            contentView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false

        }
        addUserInteractive()
        layout()
        self.contentView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: false)

    }
        
    
    
    //MARK: - property
    
    public var previewType: PreviewType = .imageNames
    
    public var proxy: MPPrecentAndDismissTransitiongingProxy?
    
    public var currentIndex: Int = 0
    
    public var imageContents: [String] = []
    
    private var images: [UIImage] = []
    
    
    private var firstImage: UIImage?
    
    public weak var sourceView: UIImageView?
    
    public var pageChangeHanlder: ((IndexPath) -> UIImageView?)?
    
    public var currentImageView: UIImageView? {
        return (self.contentView.visibleCells.first as? MPImagePreviewCell)?.imageView
    }
        

    //MARK: - private methods
    
    public func configAnimator() {
        let animator = MPControllerAnimator()
        
        animator.animation = MPTransitioningAnimations.imagePreview(controller: self).animation
        let previewInteractive = MPPreviewInteractiveTransition()
        previewInteractive.prepare(toController: self, fromController: nil)
        self.proxy = MPPrecentAndDismissTransitiongingProxy(animator: animator,
                                                  percentDrivenInteractiveTransition: previewInteractive,
                                                  presentationClass: nil)
        self.transitioningDelegate = self.proxy
        

    }
    
    private func addUserInteractive() {
        if self.navigationController == nil {
//            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureHandler(gesture:)))
//            self.view.addGestureRecognizer(panGesture)
        }

                
        let doubleGesture = UITapGestureRecognizer(target: self, action: #selector(self.doubleGestureHandle(gesture:)))
        doubleGesture.numberOfTapsRequired = 2
        doubleGesture.numberOfTouchesRequired = 1
       self.view.addGestureRecognizer(doubleGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler(gesture:)))
        tapGesture.delegate = self
        tapGesture.delaysTouchesBegan = true
        self.view.addGestureRecognizer(tapGesture)
    }
    
    
    //MARK: - user interactive handler
    
    @objc private func panGestureHandler(gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            self.modalPresentationCapturesStatusBarAppearance = false
            self.setNeedsStatusBarAppearanceUpdate()
        case  .changed:
            let point = gesture.translation(in: gesture.view)
            guard let imageView = self.contentView.visibleCells.first as? MPImagePreviewCell else { return }
            let percent = point.y / (self.view.frame.height)

            imageView.transform = CGAffineTransform(a: 1 - abs(percent), b: 0, c: 0, d: 1 - abs(percent), tx: point.x, ty: point.y)

            self.view.backgroundColor = .black.withAlphaComponent(1 - abs(percent))
        case .ended:
            guard let imageView = self.contentView.visibleCells.first as? MPImagePreviewCell else { return }
            let percent = imageView.transform.ty / (self.view.frame.height)
            if abs(percent) >= 0.2  {
                self.dismiss(animated: true, completion: nil)
                
            }
            else {
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.view.backgroundColor = .black
                    imageView.transform  = CGAffineTransform.identity
                    self?.modalPresentationCapturesStatusBarAppearance = true
                    self?.setNeedsStatusBarAppearanceUpdate()
                }
            }

            break
        
        default:
            self.modalPresentationCapturesStatusBarAppearance = true
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    @objc private func tapGestureHandler(gesture: UITapGestureRecognizer) {
        guard let cell = contentView.visibleCells.first as? MPImagePreviewCell else { return }
        if cell.scrollView.zoomScale == 1.0 {
            
            if self.navigationController != nil {
                self.navigationController?.popViewController(animated: true)
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    @objc private func doubleGestureHandle(gesture: UITapGestureRecognizer) {
        guard let cell = contentView.visibleCells.first as? MPImagePreviewCell else { return }
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
    

    //MARK: - UI
    
    public lazy var contentView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.register(MPImagePreviewCell.self, forCellWithReuseIdentifier: "MPImagePreviewCell-identifier")
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceHorizontal  = true
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
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
        switch self.previewType {
        case .imageNames:
            countLabel.text = "\(currentIndex + 1)/\(imageContents.count)"
        case .images:
            countLabel.text = "\(currentIndex + 1)/\(images.count)"
        default:
            break
        }
        
        countLabel.sizeToFit()
        let height = countLabel.frame.size.height
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        countLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        countLabel.heightAnchor.constraint(equalToConstant: height).isActive = true
        if #available(iOS 11.0, *) {
            countLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,constant: -20).isActive = true
        } else {
            countLabel.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.bottomAnchor,constant: -20).isActive = true
        }
    }
    
    //MARK: - override property
    
    
    public override var prefersStatusBarHidden: Bool { true }
    
    //MARK: - override methods
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        self.contentView.collectionViewLayout.invalidateLayout()
        guard let imageViewCell = (self.contentView.visibleCells.first as? MPImagePreviewCell) else { return }
        self.countLabel.isHidden = true
        self.contentView.isHidden = true
        let currentImageView = UIImageView(image: imageViewCell.imageView.image)
        currentImageView.mp_setScaleFitFrame(sourceFrame: self.view.bounds, isPreview: true)
        self.view.addSubview(currentImageView)
        coordinator.animate { _ in
            currentImageView.mp_setScaleFitFrame(sourceFrame: CGRect(origin: .zero, size: size), isPreview: true)
        } completion: { [weak self]_ in
            self?.countLabel.isHidden = false
            self?.contentView.isHidden = false
            currentImageView.removeFromSuperview()
        }
    }
    
    deinit {
        debugPrint(Self.self)
    }
}

//MARK: - UICollectionViewDataSource
extension MPImagePreviewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.previewType {
        case .imageNames:
            return imageContents.count
        case .images:
            return images.count
        default:
            return 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MPImagePreviewCell-identifier", for: indexPath) as! MPImagePreviewCell
        
        switch self.previewType {
        case .imageNames:
            cell.imageView.image = UIImage(named: imageContents[indexPath.row])
        case .images:
            cell.imageView.image = images[indexPath.row]
        default:
            break
        }
        
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension MPImagePreviewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.bounds.size
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollView.isHidden {
            let point = scrollView.contentOffset
            let index = Int(round(point.x / scrollView.bounds.width))
            if index != currentIndex {
                switch self.previewType {
                case .images:
                    countLabel.text = "\(index + 1)/\(images.count)"
                case .imageNames:
                    countLabel.text = "\(index + 1)/\(imageContents.count)"
                default:
                    break

                }
                currentIndex = index

                if let view = pageChangeHanlder?(IndexPath(item: currentIndex, section: 0)) {
//                    sourceView?.isHidden = false
                    sourceView?.alpha = 1
                    sourceView = view
                    sourceView?.alpha = 0
//                    sourceView?.isHidden = true
                }
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let offset = CGFloat(self.currentIndex) * collectionView.frame.size.width

        return CGPoint(x: offset, y: 0)
    }
    
}

//MARK: - UIGestureRecognizerDelegate
extension MPImagePreviewController: UIGestureRecognizerDelegate {
    

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = otherGestureRecognizer as? UITapGestureRecognizer,gesture.numberOfTapsRequired == 2 {

            return true
        }
        return false
    }
}

