//
//  MPGalleryPercentDrivenInteractiveTransition.swift
//  
//
//  Created by ogawa on 2024/6/12.
//

import UIKit

class MPGalleryPercentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {
    public override var duration: CGFloat { _duration}
    
    private var _duration: CGFloat
    
    private weak var toController: (any MPGalleryPreviewProtocol)?
    
    private weak var fromController: UIViewController?
    
    private var oldBackgroundColor: UIColor? = .clear
    
    private var oldHideStatusBar: Bool = false
    
    private var oldHideNavigationBar: Bool = false
        
    var transitionType: MPTransitionType = .show
    
    
    public init(duration: CGFloat = 0.3) {
        self._duration = duration
        super.init()
        self.wantsInteractiveStart = false
    }
    


    private func prepare() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(gestureHandler(gesture:)))
        toController!.view.addGestureRecognizer(gesture)
        
        
    }
    
    func prepare(toController: any MPGalleryPreviewProtocol,fromController: UIViewController?) {
        self.toController = toController
        self.fromController = fromController
        prepare()
    }
    
    @objc private func gestureHandler(gesture: UIPanGestureRecognizer) {
        guard let toController else { return }

        switch gesture.state {
        case .began:
            oldBackgroundColor = toController.view.backgroundColor
            oldHideStatusBar = toController.isHideStatusBar
            oldHideNavigationBar = toController.isHideNavigationBar
            wantsInteractiveStart = true
            toController.isHideStatusBar = false
            
            if !oldHideNavigationBar {
                toController.isHideNavigationBar = true
            }
            if toController.navigationController != nil {

                if let superview = toController.view.superview,let fromController = self.fromController {
                    
                    superview.addSubview(fromController.view)
                    superview.bringSubviewToFront(toController.view)
                }
            }
            
            if let superview = toController.sourceView.superview {
                superview.isHidden = true
            }
            else {
                toController.sourceView.isHidden = true
            }
            

            
        case .changed:
            
            let point = gesture.translation(in: gesture.view)
            guard let imageView = toController.currentView else { cancel();return }
            let percent = point.y / (toController.view.frame.height)
            imageView.transform = CGAffineTransform(a: 1 - abs(percent), b: 0, c: 0, d: 1 - abs(percent), tx: point.x, ty: point.y)
            toController.view.backgroundColor = .black.withAlphaComponent(1 - abs(percent))

            
            
        case .cancelled,.failed:
            guard let imageView = toController.currentView else { cancel();return }
            toController.isHideStatusBar = oldHideStatusBar
            toController.view.backgroundColor = oldBackgroundColor
            toController.isHideNavigationBar = oldHideNavigationBar
            
            imageView.transform = CGAffineTransform.identity
            if toController.navigationController != nil {
                if let fromController = self.fromController {
                    fromController.view.removeFromSuperview()
                }
            }
            cancel()
            wantsInteractiveStart = false
        case .ended:
            if toController.navigationController != nil {
                if let fromController = self.fromController {
                    fromController.view.removeFromSuperview()
                }
            }
            wantsInteractiveStart = false
            guard let imageView = toController.currentView else { cancel(); return }
            let percent = imageView.transform.ty / (toController.view.frame.height)
            if abs(percent) >= 0.2  {
                if toController.navigationController == nil {
                    toController.dismiss(animated: true)
                }
                else {
                    if toController.navigationController?.viewControllers.first == toController {
                        toController.navigationController?.dismiss(animated: true)
                    }
                    else {
                        toController.navigationController?.popViewController(animated: true)
                    }
                    
                    
                }
                

                finish()
                
            }
            else {
                toController.isHideStatusBar = oldHideStatusBar
                toController.isHideNavigationBar = oldHideNavigationBar
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.toController?.view.backgroundColor = self?.oldBackgroundColor
                    imageView.transform  = CGAffineTransform.identity
                }
                cancel()

               
            }


        default:
            break;
        }
    }
    

    
    deinit {
        debugPrint(Self.self)
    }
}
