//
//  File.swift
//  
//
//  Created by ogawa on 2024/6/12.
//

import UIKit


extension UIView {
    
    public var mp_snapshot: UIImage? {
        return UIGraphicsImageRenderer(bounds: self.bounds).image { context in
            layer.render(in: context.cgContext)
        }
    }
    
    public func mp_removeAllConstraints() {
        
        var _superview = self.superview
        while let superview = _superview {
            for constraint in superview.constraints {
                
                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }
                
                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }
            
            _superview = superview.superview
        }
    }
}
