//
//  MPImagePreviewCell.swift
//  BasicProject
//
//  Created by ogawa on 2024/4/26.
//

import UIKit


public class MPImagePreviewCell: UICollectionViewCell {
   
    //MARK: - initial
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        scrollView.delegate = self

        self.contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)


    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    //MARK: - UI
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    public let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        return scrollView
    }()
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        configImageViewSize()

    }
    
    private func configImageViewSize() {
        
        scrollView.frame = self.bounds
        scrollView.contentSize = self.contentView.bounds.size
        imageView.frame = self.bounds
        
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        scrollView.setZoomScale(1.0, animated: false)
        scrollView.contentOffset = .zero
        scrollView.contentSize = .zero
    }
}

//MARK: - UIScrollViewDelegate
extension MPImagePreviewCell: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
