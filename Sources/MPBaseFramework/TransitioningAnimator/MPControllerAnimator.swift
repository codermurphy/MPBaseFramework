//
//  MPCommonAnimator.swift
//  BasicProject
//
//  Created by ogawa on 2021/12/31.
//

import UIKit

public enum MPTransitionType {
    case presentOrPush
    case dismissOrPop
}



public typealias MPTransitioningAnimationClosure = (TimeInterval,MPTransitionType,UIView,UIViewControllerContextTransitioning) -> Void


public class MPControllerAnimator: NSObject {


    //MARK: - initial
    
    public init(duration: TimeInterval = 0.3) {
        self.duration = duration
        super.init()
    }
    
    //MARK: - property
    
    public var animatorType: MPTransitionType = .presentOrPush
    
    private let duration: TimeInterval
    
    public var animation: MPTransitioningAnimationClosure?
            
    //MARK: - present or push
    private func presentOrPushAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else { return }
        transitionContext.containerView.addSubview(toView)

        guard let nonilPreseentAnimation = animation else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return

        }
        nonilPreseentAnimation(duration,animatorType,toView,transitionContext)

    }
    
    //MARK: - dismiss or pop
    private func dismissOrPopAnimation(transitionContext: UIViewControllerContextTransitioning) {

        guard let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        if let toVC = transitionContext.viewController(forKey: .to) {
            if toVC.navigationController != nil {
                transitionContext.containerView.addSubview(toVC.view)
            }
        }
                

        guard let nonilDismissAnimation = animation else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return

        }
        nonilDismissAnimation(duration,animatorType,fromView,transitionContext)
        
    }
    
    

    
    //MARK: - deinit
    
    deinit {
        debugPrint(Self.self)
    }
}


extension MPControllerAnimator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch animatorType {
        case .presentOrPush:
            presentOrPushAnimation(transitionContext: transitionContext)
        case .dismissOrPop:
            dismissOrPopAnimation(transitionContext: transitionContext)
        }
    }
    
    public func animationEnded(_ transitionCompleted: Bool) {
        
        if transitionCompleted {
            
            switch animatorType {
            case .presentOrPush:
                animatorType = .dismissOrPop
            case .dismissOrPop:
                animatorType = .presentOrPush
            }
        }
        
    }
    
    
}
