//
//  MPTransitioningDirectionAnimation.swift
//
//
//  Created by ogawa on 2024/6/12.
//

import UIKit

public struct MPTransitioningDirectionAnimation: MPAnimateTransitionDelegate {
    
    public enum FromDirection {
        case top
        case center
        case bottom
    }
    
    public var direction: FromDirection
    
    
    public func animateTransition(duration: TimeInterval, transitionType: MPTransitionType, transitionContext: UIViewControllerContextTransitioning) {
        
        switch transitionType {
        case .show:
            guard let toView = transitionContext.view(forKey: .to) else { transitionContext.completeTransition(!transitionContext.transitionWasCancelled);
                return }
            let originColor = transitionContext.containerView.backgroundColor
            transitionContext.containerView.backgroundColor = .clear
                                
            switch direction {
            case .top:
                
                toView.transform = CGAffineTransform(translationX: 0, y: -(toView.frame.height + toView.frame.minY))

            case .center:
                toView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)

            case .bottom:
                
                let offset = transitionContext.containerView.frame.height - toView.frame.minY
                toView.transform = CGAffineTransform(translationX: 0, y: offset)
            }
            UIView.animate(withDuration: duration) {
                toView.transform = CGAffineTransform.identity
                transitionContext.containerView.backgroundColor = originColor
            } completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
            

        case .hide:
            guard let fromView = transitionContext.view(forKey: .from) else { transitionContext.completeTransition(!transitionContext.transitionWasCancelled);
                return }
            UIView.animate(withDuration: duration) {
                transitionContext.containerView.backgroundColor = .clear
                switch direction {
                case .top:
                    fromView.transform = CGAffineTransform(translationX: 0, y:-(fromView.frame.height + fromView.frame.minY))
                case .center:
                    fromView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                case .bottom:
                    let offset = transitionContext.containerView.frame.height - fromView.frame.minY
                    fromView.transform = CGAffineTransform(translationX: 0, y: offset)
                }
                
            } completion: { _ in
                if !transitionContext.transitionWasCancelled {
                    fromView.removeFromSuperview()
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    
    }
    
}
