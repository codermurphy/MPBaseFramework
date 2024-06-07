//
//  MPImagePreviewNavigationController.swift
//  
//
//  Created by ogawa on 2024/6/7.
//

import UIKit

public class MPImagePreviewNavigationController: UINavigationController {
    
    
    // MARK: property
    
    private let rootController: MPImagePreviewController
    
    public var proxy: MPPrecentAndDismissTransitiongingProxy?
    
    // MARK: intial
    public init(souceView: UIImageView,imageNames: [String],currentIndex: Int,pageChangeHandle: ((IndexPath) -> UIView?)? = nil) {
        self.rootController = MPImagePreviewController(souceView: souceView, imageNames: imageNames, currentIndex: currentIndex,pageChangeHandle: pageChangeHandle)
        super.init(rootViewController: rootController)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.isNavigationBarHidden = true
        
        configAnimator()


    }
    
    public override var prefersStatusBarHidden: Bool { true }
    
    public func configAnimator() {
        let animator = MPControllerAnimator()
        
        animator.animation = MPTransitioningAnimations.imagePreview(controller: rootController).animation
        let previewInteractive = MPPreviewInteractiveTransition()
        previewInteractive.prepare(toController: rootController, fromController: nil)
        self.proxy = MPPrecentAndDismissTransitiongingProxy(animator: animator,
                                                  percentDrivenInteractiveTransition: previewInteractive,
                                                  presentationClass: nil)
        self.transitioningDelegate = self.proxy
    }
    
    
    deinit {
        debugPrint(Self.self)
    }


}

