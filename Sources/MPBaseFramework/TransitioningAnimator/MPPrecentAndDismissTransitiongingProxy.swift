//
//  MPTransitioningAnimatorProxy.swift
//  BasicProject
//
//  Created by ogawa on 2021/12/31.
//

import UIKit

public class MPPrecentAndDismissTransitiongingProxy: NSObject {
    
    //MARK: - initial
    
    public init(animator: UIViewControllerAnimatedTransitioning?,
                percentDrivenInteractiveTransition:UIPercentDrivenInteractiveTransition?,
                presentationClass: UIPresentationController.Type? = nil)  {
        
        super.init()
        
        self.animator = animator
        self.presentationClass = presentationClass
        self.percentDrivenInteractiveTransition = percentDrivenInteractiveTransition
    }


    //MARK: - property
    private var animator: UIViewControllerAnimatedTransitioning?
        
    private var presentationClass: UIPresentationController.Type?
    
    private var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition?
    
    //MARK: - deinit
    deinit {
        debugPrint(Self.self)
    }
}


extension MPPrecentAndDismissTransitiongingProxy: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animator
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
