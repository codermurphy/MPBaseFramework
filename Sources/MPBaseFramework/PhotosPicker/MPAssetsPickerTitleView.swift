//
//  MPImagePickerTitleView.swift
//  BasicProject
//
//  Created by ogawa on 2022/1/14.
//

import UIKit

class MPAssetsPickerTitleView: UIControl {

    //MARK: - initial
    init(title: String?) {
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.backgroundColor = .clear
        self.isSelected = false
        containerView.layer.cornerRadius = 14
        setupUI()


    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: -1, height: 28)
    }
    

    
    //MARK: - update title
    
    func updateTitle(title: String,animated: Bool) {
        
        self.titleLabel.text = title
        self.invalidateIntrinsicContentSize()
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
        else {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    //MARK: - override
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.arrowView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                }
            }
            else {
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.arrowView.transform =  CGAffineTransform.identity
                }
                
            }
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()        
    }
    
    //MARK: - UI
    
    private let containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .white.withAlphaComponent(0.3)
        container.layer.masksToBounds = true
        container.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        container.isUserInteractionEnabled = false
        return container
    }()

    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.text = "Photos"
        label.textColor = .white
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    private func setupUI() {
        
        self.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(arrowView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        containerView.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 7).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -5).isActive = true
        arrowView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor,constant: 5).isActive = true
        arrowView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        arrowView.widthAnchor.constraint(equalToConstant: arrowView.intrinsicContentSize.width).isActive = true
        arrowView.heightAnchor.constraint(equalToConstant: arrowView.intrinsicContentSize.height).isActive = true
    }
    
    private let arrowView: MPImagePickerTitleArrowView = MPImagePickerTitleArrowView()

}

fileprivate class MPImagePickerTitleArrowView: UIView {
    
    init() {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)))
        
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        self.layer.addSublayer(arrowLayer)
        arrowLayer.frame = self.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 20, height: 20)
    }
    
    
    //MARK: - UI
    private let arrowLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.lightGray.cgColor
        layer.masksToBounds = true
        layer.fillColor = UIColor.black.withAlphaComponent(0.7).cgColor
        layer.strokeColor = UIColor.clear.cgColor
        layer.lineJoin = .round
        layer.lineCap = .round
        layer.strokeEnd = 1.0
        let path = UIBezierPath()
        let firstPoint = CGPoint(x: 5.5, y: 8)
        let middPoint = CGPoint(x: 10, y: 15)
        let lastPoint = CGPoint(x: 14.5, y: 8)
        path.move(to: firstPoint)
        path.addLine(to: middPoint)
        path.addLine(to: lastPoint)
        layer.path = path.cgPath
        return layer
    }()
}
