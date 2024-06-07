//
//  MPPreviewInteractiveTransition.swift
//  BasicProject
//
//  Created by ogawa on 2024/5/4.
//

import UIKit

public class MPPreviewInteractiveTransition: UIPercentDrivenInteractiveTransition {

    public override var duration: CGFloat { _duration}
    
    private var _duration: CGFloat
    
    private weak var toController: MPImagePreviewProtocol?
    
    private weak var fromController: UIViewController?
    
        
    var transitionType: MPTransitionType = .presentOrPush
    
    
    public init(duration: CGFloat = 0.3) {
        self._duration = duration 
        super.init()
        self.wantsInteractiveStart = false
    }
    


    private func prepare() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(gestureHandler(gesture:)))
        toController!.view.addGestureRecognizer(gesture)
        
        
    }
    
    func prepare(toController: MPImagePreviewProtocol,fromController: UIViewController?) {
        self.toController = toController
        self.fromController = fromController
        prepare()
    }
    
    @objc private func gestureHandler(gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:

            wantsInteractiveStart = true
            toController?.modalPresentationCapturesStatusBarAppearance = false
            toController?.setNeedsStatusBarAppearanceUpdate()
            
            if toController?.navigationController != nil {
                toController?.navigationController?.modalPresentationCapturesStatusBarAppearance = false
                toController?.navigationController?.setNeedsStatusBarAppearanceUpdate()
                if let superview = toController?.view.superview,let fromController = self.fromController {
                    
                    superview.addSubview(fromController.view)
                    superview.bringSubviewToFront(toController!.view)
                }
            }

            
        case .changed:
            
            let point = gesture.translation(in: gesture.view)
            guard let imageView = toController?.currentImageView else { cancel();return }
            let percent = point.y / (toController!.view.frame.height)
            imageView.transform = CGAffineTransform(a: 1 - abs(percent), b: 0, c: 0, d: 1 - abs(percent), tx: point.x, ty: point.y)
            toController?.view.backgroundColor = .black.withAlphaComponent(1 - abs(percent))
            
            
        case .cancelled,.failed:
            toController?.modalPresentationCapturesStatusBarAppearance = true
            toController?.setNeedsStatusBarAppearanceUpdate()
            if toController?.navigationController != nil {
                toController?.navigationController?.modalPresentationCapturesStatusBarAppearance = false
                toController?.navigationController?.setNeedsStatusBarAppearanceUpdate()
                if let fromController = self.fromController {
                    fromController.view.removeFromSuperview()
                }
            }
            cancel()
            wantsInteractiveStart = false
        case .ended:
            if toController?.navigationController != nil {
                if let fromController = self.fromController {
                    fromController.view.removeFromSuperview()
                }
            }
            wantsInteractiveStart = false
            guard let imageView = toController?.currentImageView else { cancel(); return }
            let percent = imageView.transform.ty / (toController!.view.frame.height)
            if abs(percent) >= 0.2  {
                if toController?.navigationController == nil {
                    toController?.dismiss(animated: true)
                }
                else {
                    if toController?.navigationController?.viewControllers.first == toController {
                        toController?.navigationController?.dismiss(animated: true)
                    }
                    else {
                        toController?.navigationController?.popViewController(animated: true)
                    }
                    
                    
                }
                

                finish()
                
            }
            else {
                cancel()
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.toController?.view.backgroundColor = .black
                    imageView.transform  = CGAffineTransform.identity
                    self?.toController?.modalPresentationCapturesStatusBarAppearance = true
                    self?.toController?.setNeedsStatusBarAppearanceUpdate()
                    
                    if self?.toController?.navigationController != nil {
                        self?.toController?.navigationController?.modalPresentationCapturesStatusBarAppearance = false
                        self?.toController?.navigationController?.setNeedsStatusBarAppearanceUpdate()
                    }
                }
               
            }


        default:
            break;
        }
    }
    

    
    deinit {
        debugPrint(Self.self)
    }
    

}
