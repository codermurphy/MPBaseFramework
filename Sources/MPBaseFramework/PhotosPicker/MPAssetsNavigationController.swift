//
//  MPAssetsNavigationController.swift
//  BasicProject
//
//  Created by ogawa on 2024/4/30.
//

import UIKit

class MPAssetNavigationBar: UINavigationBar {
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isTranslucent = false
        self.barTintColor = .black
        self.tintColor = .white
        
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MPAssetToolBar: UIToolbar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isTranslucent = false
        self.barTintColor = .black
        self.tintColor = .white

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class MPAssetsNavigationController: UINavigationController {
    
        
    private var percentageTransition :MPGalleryPercentDrivenInteractiveTransition?
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent}
    
    
    private override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    private override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        
    }
    
    
    convenience init(assets: MPAssetsPickerController) {
        self.init(navigationBarClass: MPAssetNavigationBar.self, toolbarClass: MPAssetToolBar.self)
        assets.extendedLayoutIncludesOpaqueBars = true
        self.viewControllers.append(assets)
        self.modalPresentationStyle = .fullScreen
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        delegate = self
        
    }
        
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        self.topViewController?.navigationItem.backButtonTitle = ""
        viewController.extendedLayoutIncludesOpaqueBars = true
        super.pushViewController(viewController, animated: animated)
    }
    
    
    override func setToolbarHidden(_ hidden: Bool, animated: Bool) {
        if animated {
            let toolBarHeight = self.toolbar.frame.height
            let safeHegiht  = self.view.safeAreaInsets.bottom
            let totalheight = toolBarHeight + safeHegiht
            if hidden {
                
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.toolbar.transform = CGAffineTransform(translationX: 0, y: totalheight)
                }
                
            }
            else {
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.toolbar.transform = CGAffineTransform.identity
                }
            }
        }
        else {
            super.setToolbarHidden(hidden, animated: animated)
        }
    }

    

}


extension MPAssetsNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count > 1 {
            if let preview = viewController as? MPAssetsPreviewController {
                let lastController = navigationController.viewControllers[navigationController.viewControllers.count - 2]
                percentageTransition = MPGalleryPercentDrivenInteractiveTransition()
                percentageTransition?.prepare(toController: preview,fromController: lastController)
            }
            else {
                percentageTransition = nil
            }
            
        }
        else {
            percentageTransition = nil
        }
        

    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        if let animator = animationController as? MPTransitionAnimator,animator.transitionType == .hide {
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
            if let resultController =  toVC as? (any MPGalleryPreviewProtocol) {
                
                let pushAnimator = MPTransitionAnimator(transitionType: .show,animateTransitionDelegate: MPGalleryPreviewAnimation(previewDelegate: resultController))
                return pushAnimator
            }
            else {
                return nil
            }
        case .pop:
            if let resultController =  fromVC as? (any MPGalleryPreviewProtocol)  {
                let pushAnimator = MPTransitionAnimator(transitionType: .hide,animateTransitionDelegate: MPGalleryPreviewAnimation(previewDelegate: resultController))
                return pushAnimator
            }
            else {
                return nil
            }
        default:
            return nil
        }
    }
}

