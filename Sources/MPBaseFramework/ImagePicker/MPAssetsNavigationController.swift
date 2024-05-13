//
//  MPAssetsNavigationController.swift
//  BasicProject
//
//  Created by ogawa on 2024/4/30.
//

import UIKit

class MPAssetsNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

       delegate = self
    }
    
    private var percentageTransition :MPPreviewInteractiveTransition?
    


}


extension MPAssetsNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count > 1 {
            if let preview = viewController as? MPImagePreviewController {
                let lastController = navigationController.viewControllers[navigationController.viewControllers.count - 2]
                percentageTransition = MPPreviewInteractiveTransition()
                percentageTransition?.prepare(toController: preview,fromController: lastController)
            }
            else {
                percentageTransition = nil
            }
        }
        

    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        if let animator = animationController as? MPControllerAnimator,animator.animatorType == .dismissOrPop {
            return percentageTransition
        }
        else {
            return nil
        }
        
        
        
       
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch operation {
        case .none:
            return nil
        case .push:
            if let resultController =  toVC as? MPImagePreviewProtocol {
                
                let pushAnimator = MPControllerAnimator()
                pushAnimator.animation = MPTransitioningAnimations.imagePreview(controller: resultController).animation
                return pushAnimator
            }
            else {
                return nil
            }
        case .pop:
            if let resultController =  fromVC as? MPImagePreviewProtocol {
                let popAnimator =  MPControllerAnimator()
                popAnimator.animation = MPTransitioningAnimations.imagePreview(controller: resultController).animation
                popAnimator.animatorType = .dismissOrPop
                return popAnimator
            }
            else {
                return nil
            }
        default:
            return nil
        }
    }
}
