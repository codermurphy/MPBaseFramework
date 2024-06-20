//
//  MPGalleryPreviewAnimation.swift


import UIKit

struct MPGalleryPreviewAnimation: MPAnimateTransitionDelegate {
    
    weak var previewDelegate: (any MPGalleryPreviewProtocol)?
    
    func animateTransition(duration: TimeInterval, transitionType: MPTransitionType, transitionContext: UIViewControllerContextTransitioning) {
        
        switch transitionType {
        case .show:
            
            guard let toVC = transitionContext.viewController(forKey: .to) else { transitionContext.completeTransition(true); return }
            guard let sourceView = previewDelegate?.sourceView else { transitionContext.completeTransition(true); return }
            guard let targetFrame = previewDelegate?.targetFrame else { transitionContext.completeTransition(true); return }
            toVC.view.isHidden = true
            let backgroundView = UIView(frame: transitionContext.containerView.bounds)
            backgroundView.backgroundColor = .clear
            
            transitionContext.containerView.addSubview(backgroundView)
            
            let snapshotView = UIImageView()
            snapshotView.image = sourceView is UIImageView ?  (sourceView as! UIImageView).image : sourceView.mp_snapshot
            
            let originFrame = sourceView.convert(sourceView.frame, to: transitionContext.containerView)
            
            snapshotView.contentMode = sourceView.contentMode
            snapshotView.mp_setScaleFitFrame(sourceFrame: originFrame,isPreview: false)
            
            transitionContext.containerView.addSubview(snapshotView)
            
            if let superview = sourceView.superview {
                superview.isHidden = true
            }
            else {
                sourceView.isHidden = true
            }

            
            UIView.animate(withDuration: duration) { [weak snapshotView,weak toVC,weak backgroundView] in
                
                snapshotView?.mp_setScaleFitFrame(sourceFrame: targetFrame ,isPreview: true)
                if let nav = toVC as? UINavigationController {
                    backgroundView?.backgroundColor = nav.topViewController?.view.backgroundColor
                }
                else {
                    backgroundView?.backgroundColor = toVC?.view.backgroundColor
                }
                

                
            } completion: { [weak snapshotView,weak backgroundView,weak toVC]_ in
                
                if let superview = sourceView.superview {
                    superview.isHidden = false
                }
                else {
                    sourceView.isHidden = false
                }
                
                backgroundView?.removeFromSuperview()
                toVC?.view.isHidden = false
                previewDelegate?.isHideStatusBar = true
                snapshotView?.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
        case .hide:
            guard let fromVC = transitionContext.viewController(forKey: .from) else {transitionContext.completeTransition(true) ;return}
            guard let currentView = previewDelegate?.currentView else { transitionContext.completeTransition(true) ;return }
            guard let sourceView = previewDelegate?.sourceView else { transitionContext.completeTransition(true); return }
            
            if let superview = sourceView.superview {
                superview.isHidden = true
            }
            else {
                sourceView.isHidden = true
            }
            
            let backgroundView = UIView(frame: transitionContext.containerView.bounds)
            if let nav = fromVC as? UINavigationController {
                backgroundView.backgroundColor = nav.topViewController?.view.backgroundColor
            }
            else {
                backgroundView.backgroundColor = fromVC.view.backgroundColor
            }
            
            
            transitionContext.containerView.addSubview(backgroundView)
            
            let snapshotView = UIImageView()
            var originFrame: CGRect = .zero
            if let superView = currentView.superview {
                originFrame = superView.convert(currentView.frame, to: transitionContext.containerView)
            }
            else {
                originFrame =  currentView.convert(currentView.frame, to: transitionContext.containerView)
            }
            snapshotView.image = currentView is UIImageView ?  (currentView as! UIImageView).image : currentView.mp_snapshot
            snapshotView.mp_setScaleFitFrame(sourceFrame: originFrame,isPreview: true)
            snapshotView.contentMode = currentView.contentMode
        
            transitionContext.containerView.addSubview(snapshotView)
            
            previewDelegate?.isHideStatusBar = false
            fromVC.view.isHidden = true
            let resultFrame = sourceView.convert(sourceView.frame, to: transitionContext.containerView)
            
            UIView.animate(withDuration: duration) { [weak snapshotView,weak backgroundView] in
                snapshotView?.mp_setScaleFitFrame(sourceFrame: resultFrame,isPreview: false)
                backgroundView?.backgroundColor = .clear
            } completion: {  [weak snapshotView,weak sourceView,weak backgroundView,weak fromVC] _ in
                
                if let superview = sourceView?.superview {
                    superview.isHidden = false
                }
                else {
                    sourceView?.isHidden = false
                }
                
                if transitionContext.transitionWasCancelled {
                    fromVC?.view.isHidden = false
                    fromVC?.modalPresentationCapturesStatusBarAppearance = true
                    fromVC?.setNeedsStatusBarAppearanceUpdate()
                }

                snapshotView?.removeFromSuperview()
                backgroundView?.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled )
            }
        }
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

