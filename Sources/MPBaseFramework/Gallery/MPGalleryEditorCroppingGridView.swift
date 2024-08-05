//
//  MPGalleryEditorCroppingGridView.swift
//  
//
//  Created by ogawa on 2024/7/2.
//

import UIKit

import UIKit
 

class MPGalleryEditorCroppingGridView: UIView {
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear
//        self.clipsToBounds = false
        self.isUserInteractionEnabled = false
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        
        self.layer.addSublayer(shapeLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let shapeLayer: CAShapeLayer  = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 4
        
        return layer
    }()
    
    
    
   
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        shapeLayer.frame = CGRect(origin: .zero, size: rect.size)
        UIColor.white.setStroke()
        
        var scale: CGFloat = self.window?.windowScene?.screen.scale ?? UIScreen.main.scale


        let avgWidth = rect.width / 3
        let avgHeight = rect.height / 3
        for index in 1..<3 {
            let path = UIBezierPath()
            let x = avgWidth * CGFloat(index)
            
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
            path.lineWidth = scale >= 3 ? 0.75 : 0.5
            path.stroke()
        }
        
        for index in 1..<3 {
            let path = UIBezierPath()
            let y = avgHeight * CGFloat(index)
            path.move(to: CGPoint(x: 0 ,y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
            path.lineWidth = scale >= 3 ? 0.75 : 0.5
            path.stroke()
        }
        
        let topLeftPath = UIBezierPath()
        topLeftPath.move(to: CGPoint(x: -1, y: 20))
        topLeftPath.addLine(to: CGPoint(x: -1, y: -1))
        topLeftPath.addLine(to: CGPoint(x: 20, y: -1))
//        topLeftPath.close()
        
        
        topLeftPath.move(to: CGPoint(x: rect.width + 1, y: 20))
        topLeftPath.addLine(to: CGPoint(x: rect.width + 1, y: -1))
        topLeftPath.addLine(to: CGPoint(x: rect.width - 20, y: -1))
        
        topLeftPath.move(to: CGPoint(x: -1, y: rect.height - 20))
        topLeftPath.addLine(to: CGPoint(x: -1, y: rect.height + 1))
        topLeftPath.addLine(to: CGPoint(x: 20, y: rect.height + 1))
        
        topLeftPath.move(to: CGPoint(x: rect.width + 1, y: rect.height - 20))
        topLeftPath.addLine(to: CGPoint(x: rect.width + 1, y: rect.height + 1))
        topLeftPath.addLine(to: CGPoint(x: rect.width - 20, y: rect.height + 1))
        
        shapeLayer.path = topLeftPath.cgPath
        

    }

}
