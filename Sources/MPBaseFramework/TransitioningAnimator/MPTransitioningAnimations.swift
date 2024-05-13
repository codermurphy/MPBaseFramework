//
//  MPTransitioningAnimations.swift
//  BasicProject
//
//  Created by ogawa on 2021/12/31.
//

import UIKit

public protocol MPImagePreviewProtocol: UIViewController {
    
    var sourceView: UIImageView? { set get}
    
    var currentImageView: UIImageView? { get }
}



public enum MPTransitioningAnimations {
    
    
    public enum FromDirection {
        case top
        case center
        case bottom
    }

    
    case fromDirectionAnimaiton(FromDirection)
    
    case sheetBottomAnimation
    
    
    case imagePreview(controller: MPImagePreviewProtocol)
    

}


extension MPTransitioningAnimations {
    public var animation: MPTransitioningAnimationClosure? {
        var animation: MPTransitioningAnimationClosure?
        switch self {
        case .fromDirectionAnimaiton(let fromDirection):
            
            animation = { duration,type,animationView,contextTransitioning in
                
                switch type {
                case .presentOrPush:
                    let originColor = contextTransitioning.containerView.backgroundColor
                    contextTransitioning.containerView.backgroundColor = .clear
                                        
                    switch fromDirection {
                    case .top:
                        
                        animationView.transform = CGAffineTransform(translationX: 0, y: -(animationView.frame.height + animationView.frame.minY))

                    case .center:
                        animationView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)

                    case .bottom:
                        
                        let offset = contextTransitioning.containerView.frame.height - animationView.frame.minY
                        animationView.transform = CGAffineTransform(translationX: 0, y: offset)
                    }
                    UIView.animate(withDuration: duration) {
                        animationView.transform = CGAffineTransform.identity
                        contextTransitioning.containerView.backgroundColor = originColor
                    } completion: { _ in
                        contextTransitioning.completeTransition(!contextTransitioning.transitionWasCancelled)
                    }
                    
                    

                case .dismissOrPop:
                    
                    UIView.animate(withDuration: duration) {
//                        animationView.alpha = 0
                        contextTransitioning.containerView.backgroundColor = .clear
                        switch fromDirection {
                        case .top:
                            animationView.transform = CGAffineTransform(translationX: 0, y:-(animationView.frame.height + animationView.frame.minY))
                        case .center:
                            animationView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                        case .bottom:
                            let offset = contextTransitioning.containerView.frame.height - animationView.frame.minY
                            animationView.transform = CGAffineTransform(translationX: 0, y: offset)
                        }
                        
                    } completion: { _ in
                        if !contextTransitioning.transitionWasCancelled {
                            animationView.removeFromSuperview()
                        }
                        contextTransitioning.completeTransition(!contextTransitioning.transitionWasCancelled)
                    }
                }
                
            }
            
        case .sheetBottomAnimation:
            animation = { duration,type,animationView,contextTransitioning in
                
                switch type {
                case .presentOrPush:
                    let originColor = contextTransitioning.containerView.backgroundColor
                    contextTransitioning.containerView.backgroundColor = .clear
                    animationView.transform = CGAffineTransform(translationX: 0, y: animationView.frame.height)
                                
                    UIView.animate(withDuration: duration) {
                        animationView.transform = CGAffineTransform.identity
                        contextTransitioning.containerView.backgroundColor = originColor
                    } completion: { _ in
                        contextTransitioning.completeTransition(!contextTransitioning.transitionWasCancelled)
                    }
                case .dismissOrPop:

                    UIView.animate(withDuration: duration) {
                        animationView.transform = CGAffineTransform(translationX: 0, y:animationView.frame.height)
                        contextTransitioning.containerView.backgroundColor = .clear
                    } completion: { _ in
                        if !contextTransitioning.transitionWasCancelled {
                            animationView.removeFromSuperview()
                        }
                        contextTransitioning.completeTransition(!contextTransitioning.transitionWasCancelled)
                    }
                }
                
            }
        case let .imagePreview(controller):
            animation = { [weak controller] duration,type,animationView,contextTransitioning in
                guard let controller else { contextTransitioning.completeTransition(true); return}
                switch type {
                case .presentOrPush:
                    
                    
                    
                    guard let sourceView = controller.sourceView else { contextTransitioning.completeTransition(true); return }
                    controller.view.isHidden = true
                    let backgroundView = UIView(frame: contextTransitioning.containerView.bounds)
                    backgroundView.backgroundColor = .clear
                    
                    contextTransitioning.containerView.addSubview(backgroundView)
                    
                    let snapshotView = UIImageView()
                    snapshotView.image = sourceView.image
                    
                    let originFrame = sourceView.convert(sourceView.frame, to: contextTransitioning.containerView)
                    
                    snapshotView.contentMode = sourceView.contentMode
                    snapshotView.mp_setScaleFitFrame(sourceFrame: originFrame,isPreview: false)
                    
                    contextTransitioning.containerView.addSubview(snapshotView)
      
                    
                    UIView.animate(withDuration: duration) { [weak snapshotView,weak sourceView,weak backgroundView] in
                        
                        snapshotView?.mp_setScaleFitFrame(sourceFrame:  contextTransitioning.containerView.frame,isPreview: true)
                        backgroundView?.backgroundColor = .black
                        sourceView?.alpha = 0

                        
                    } completion: { [weak snapshotView,weak backgroundView]_ in
                        
                        backgroundView?.removeFromSuperview()
                        controller.view.isHidden = false
                        controller.modalPresentationCapturesStatusBarAppearance = true
                        controller.setNeedsStatusBarAppearanceUpdate()
                        snapshotView?.removeFromSuperview()
                        contextTransitioning.completeTransition(!contextTransitioning.transitionWasCancelled)
                    }
                    
                case .dismissOrPop:

                    guard let sourceView = controller.sourceView else { contextTransitioning.completeTransition(true) ;return }
                    guard let currentImageView = controller.currentImageView else { contextTransitioning.completeTransition(true) ;return }
                    let backgroundView = UIView(frame: contextTransitioning.containerView.bounds)
                    backgroundView.backgroundColor = animationView.backgroundColor
                    
                    contextTransitioning.containerView.addSubview(backgroundView)
                    
                    let snapshotView = UIImageView()
                    var originFrame: CGRect = .zero
                    if let superView = currentImageView.superview {
                        originFrame = superView.convert(currentImageView.frame, to: contextTransitioning.containerView)
                    }
                    else {
                        originFrame =  currentImageView.convert(currentImageView.frame, to: contextTransitioning.containerView)
                    }
                    snapshotView.image = currentImageView.image
                    snapshotView.mp_setScaleFitFrame(sourceFrame: originFrame,isPreview: true)
                    snapshotView.contentMode = currentImageView.contentMode
                
                    contextTransitioning.containerView.addSubview(snapshotView)
                    
                    controller.modalPresentationCapturesStatusBarAppearance = false
                    controller.setNeedsStatusBarAppearanceUpdate()
                    controller.view.isHidden = true
                    let resultFrame = sourceView.convert(sourceView.frame, to: contextTransitioning.containerView)
                    
                    UIView.animate(withDuration: duration) { [weak snapshotView,weak backgroundView] in
                        snapshotView?.mp_setScaleFitFrame(sourceFrame: resultFrame,isPreview: false)
                        backgroundView?.backgroundColor = .clear
                    } completion: {  [weak snapshotView,weak sourceView,weak backgroundView] _ in
                        
                        if contextTransitioning.transitionWasCancelled {
                            controller.view.isHidden = false
                            controller.modalPresentationCapturesStatusBarAppearance = true
                            controller.setNeedsStatusBarAppearanceUpdate()
                            sourceView?.alpha = 0
                        }
                        else {
                            sourceView?.alpha = 1
                        }
                        
                        snapshotView?.removeFromSuperview()
                        backgroundView?.removeFromSuperview()
                        contextTransitioning.completeTransition(!contextTransitioning.transitionWasCancelled )
                    }
                }
                
            }
        }
        
        return animation
    }
}



//MARK: - UIImageView fitSize extension

extension UIImageView {

    func mp_setScaleFitFrame(sourceFrame: CGRect,isPreview: Bool) {
        guard let image = self.image else { return }
        let sourceCenter = CGPoint(x: sourceFrame.origin.x + sourceFrame.width * 0.5, y: sourceFrame.origin.y + sourceFrame.height * 0.5)
        let imageScale = image.size.width / image.size.height
        let targetHeight = sourceFrame.size.width / imageScale
        let targetWidth = sourceFrame.size.height * imageScale
        var targeSize: CGSize = .zero
        var centerPoint: CGPoint = .zero
        if self.mask == nil {
            let mask = UIView()
            mask.backgroundColor = .black
            self.mask = mask
        }
        
        if image.size.height > image.size.width {
            
            if !isPreview {
                targeSize = CGSize(width: sourceFrame.width, height: targetHeight)
            }
            else {
                if targetWidth > sourceFrame.width {
                    targeSize = CGSize(width: sourceFrame.width, height: targetHeight)
                }
                else {
                    targeSize = CGSize(width: targetWidth, height: sourceFrame.height)
                }
                
            }
            
            centerPoint = CGPoint(x: sourceCenter.x,
                                  y: (sourceFrame.origin.y + targeSize.height * 0.5) - (targeSize.height * 0.5 - sourceFrame.height) - sourceFrame.height * 0.5)
        }
        else if image.size.height == image.size.width {
            
            if !isPreview {
                targeSize = CGSize(width: max(sourceFrame.width,sourceFrame.height), height: max(sourceFrame.width,sourceFrame.height))
                centerPoint = CGPoint(x: sourceCenter.x,
                                      y: (sourceFrame.origin.y + targeSize.height * 0.5) - (targeSize.height * 0.5 - sourceFrame.height) - sourceFrame.height * 0.5)
            }
            else {
                targeSize = CGSize(width: min(sourceFrame.width,sourceFrame.height), height: min(sourceFrame.width,sourceFrame.height))
                centerPoint = CGPoint(x: sourceCenter.x,
                                      y: (sourceFrame.origin.y + targeSize.height * 0.5) - (targeSize.height * 0.5 - sourceFrame.height) - sourceFrame.height * 0.5)
            }

        }
        else {
            if !isPreview {
                targeSize = CGSize(width: targetWidth, height: sourceFrame.height)
            }
            else {
                if targetHeight > sourceFrame.height {
                    targeSize = CGSize(width: targetWidth, height: sourceFrame.height)
                }
                else {
                    targeSize = CGSize(width: sourceFrame.width, height: targetHeight)
                }
                
            }
            
            centerPoint = CGPoint(x: (sourceFrame.origin.x + targeSize.width * 0.5) - (targeSize.width * 0.5 - sourceFrame.width) - sourceFrame.width * 0.5,
                                  y: sourceCenter.y)
        }
        self.frame.size = targeSize
        self.center = centerPoint
        self.mask?.frame.size = sourceFrame.size
        self.mask?.center = CGPoint(x: targeSize.width * 0.5, y: targeSize.height * 0.5)
          
    }
}
