//
//  MPTickSelectedView.swift
//  BasicProject
//
//  Created by ogawa on 2022/1/17.
//

import UIKit

class MPTickSelectedView: UIView,MPTickSelectedProtocol {
    
    //MARK: - initial
    
    init(size: CGSize) {
        self._size = size
        super.init(frame: CGRect(origin: .zero, size: size))
        
        let path = UIBezierPath()
        
        let middlePoint = CGPoint(x: size.width * 0.5, y: size.height * 0.75)
        let firsrPoint = CGPoint(x: size.width * 0.35, y: size.height * 0.6)
        let lastPoint = CGPoint(x: size.width * 0.7, y: size.height * 0.35)
        path.move(to: firsrPoint)
        path.addLine(to: middlePoint)
        path.addLine(to: lastPoint)
        selectedLayer.path = path.cgPath
        
        self.backgroundColor = .clear
        self.layer.cornerRadius = size.height * 0.5
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor
        self.clipsToBounds = true
        
        selectedLayer.frame = CGRect(origin: .zero, size: size)
        self.layer.addSublayer(selectedLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - property
    
    private var _size: CGSize
    
    var isSelected: Bool = false {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            selectedLayer.strokeEnd = isSelected ? 1.0 : 0.0
            selectedLayer.backgroundColor = isSelected ? UIColor.green.cgColor : UIColor.clear.cgColor
            CATransaction.commit()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return _size
    }
    
    //MARK: - UI
    
    private let selectedLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        
        layer.backgroundColor = UIColor.clear.cgColor
        layer.strokeEnd = 0.0
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 2
        layer.lineCap = .round
        layer.lineJoin = .round
        
        return layer
    }()
}
