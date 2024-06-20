//
//  MPGalleryPreviewDetailBaseCell.swift


import UIKit

public class MPGalleryPreviewDetailBaseCell: UICollectionViewCell,MPGalleryPreviewDetailCellProtocol {
    
    //MARK: - initial
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        setupUI()
        scrollView.delegate = self
        scrollView.isUserInteractionEnabled = false
        self.contentView.addGestureRecognizer(self.scrollView.panGestureRecognizer)
        if let pinch = self.scrollView.pinchGestureRecognizer {
            self.contentView.addGestureRecognizer(pinch)
        }
        
        let doubleGesture = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapGestureHandle(gesture:)))
        doubleGesture.numberOfTapsRequired = 2
        doubleGesture.numberOfTouchesRequired = 1
        doubleGesture.delaysTouchesBegan = true
        doubleGesture.cancelsTouchesInView = false
        contentView.addGestureRecognizer(doubleGesture)

        
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
     
    // MARK: override
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.isHidden = false
        imageView.image = nil
        scrollView.setZoomScale(1.0, animated: false)
        scrollView.contentOffset = .zero
        scrollView.contentSize = .zero
    }
    
    //MARK: - UI
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    public let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    @objc private func tapGestureHandle(gesture: UIGestureRecognizer) {
        guard let collectionView = self.superview as? UICollectionView else { return }
        let point = gesture.location(in: self.contentView)
        guard let indexPath = collectionView.indexPath(for: self) else { return }
        collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    @objc private func doubleTapGestureHandle(gesture: UIGestureRecognizer) {
        if scrollView.zoomScale != 1 {
            
            scrollView.setZoomScale(1.0, animated: true)
        }
        else {
            let point = gesture.location(in: scrollView)
            var zoomRect: CGRect = .zero
            zoomRect.size.width = scrollView.frame.width / scrollView.maximumZoomScale
            zoomRect.size.height = scrollView.frame.height / scrollView.maximumZoomScale
            zoomRect.origin.x = point.x - zoomRect.width * 0.5
            zoomRect.origin.y = point.y - zoomRect.height * 0.5
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()


    }
    
    private func setupUI() {
        self.contentView.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)
        
        scrollView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor).isActive = true
    }
    
}

//MARK: - UIScrollViewDelegate
extension MPGalleryPreviewDetailBaseCell: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}

extension MPGalleryPreviewDetailBaseCell: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer is UITapGestureRecognizer 
            && otherGestureRecognizer is UITapGestureRecognizer
            && otherGestureRecognizer.numberOfTouches == 1 {
            return true
        }
        else {
            return false
        }
    }
    
}

class MPScrollView: UIScrollView, UIGestureRecognizerDelegate {
    
    init() {
        super.init(frame: .zero)
        self.scrollsToTop = false
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
