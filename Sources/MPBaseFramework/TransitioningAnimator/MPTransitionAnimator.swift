//
//  MPTransitionAnimator.swift
//

import UIKit

public enum MPTransitionType {
    case show
    case hide
}

public protocol MPAnimateTransitionDelegate {
    
    
    func animateTransition(duration: TimeInterval,transitionType: MPTransitionType,transitionContext: UIViewControllerContextTransitioning)
}


public class MPTransitionAnimator: NSObject {
    
    
    public init(duration: TimeInterval = 0.3,
                transitionType: MPTransitionType = .show,
                presentationClass: UIPresentationController.Type? = nil,
                percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition? = nil,
                animateTransitionDelegate: MPAnimateTransitionDelegate) {
        self.duration = duration
        self.transitionType = transitionType
        self.presentationClass = presentationClass
        self.percentDrivenInteractiveTransition = percentDrivenInteractiveTransition
        self.animateTransitionDelegate = animateTransitionDelegate
    }
    
    private var duration: TimeInterval
    
    private(set) var transitionType: MPTransitionType
    
    private var presentationClass: UIPresentationController.Type?
    
    private var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition?
    
    private var animateTransitionDelegate: MPAnimateTransitionDelegate
    
    
    private func showAnimateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toView = transitionContext.view(forKey: .to) else { return }
        transitionContext.containerView.addSubview(toView)
        animateTransitionDelegate.animateTransition(duration: duration, transitionType: transitionType, transitionContext: transitionContext)
        
    }
    
    private func hideAnimateTransition(transitionContext: UIViewControllerContextTransitioning) {
    
        if let toVC = transitionContext.viewController(forKey: .to) {
            if toVC.navigationController != nil {
                transitionContext.containerView.addSubview(toVC.view)
            }
        }
        animateTransitionDelegate.animateTransition(duration: duration, transitionType: transitionType, transitionContext: transitionContext)
        

    }
    
    deinit {
        
        debugPrint(Self.self)
    }
}

// MARK: UIViewControllerAnimatedTransitioning
extension MPTransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch transitionType {
        case .show:
            showAnimateTransition(transitionContext: transitionContext)
        case .hide:
            hideAnimateTransition(transitionContext: transitionContext)
        }
    }
    
    public func animationEnded(_ transitionCompleted: Bool) {
        
        if transitionCompleted {
            
            switch transitionType {
            case .show:
                transitionType = .hide
            case .hide:
                transitionType = .show
            }
        }
        
    }

    
    
}

// MARK: UIViewControllerTransitioningDelegate
extension MPTransitionAnimator: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return percentDrivenInteractiveTransition
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return percentDrivenInteractiveTransition
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return presentationClass?.init(presentedViewController: presented, presenting: presenting)
    }
}
