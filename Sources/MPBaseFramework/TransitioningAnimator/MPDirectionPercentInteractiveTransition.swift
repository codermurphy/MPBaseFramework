//
//  MPDirectionPercentInteractiveTransition.swift
//  BasicProject
//
//  Created by ogawa on 2021/12/31.
//

import UIKit

public class MPDirectionPercentInteractiveTransition: UIPercentDrivenInteractiveTransition {

    //MARK: - property
        
    public override var duration: CGFloat {
        return _duration
    }
    
    private var _duration: CGFloat
    
    private var direction: UIRectEdge
    
    weak var sourceViewController: UIViewController?
    
    init(sourceViewController: UIViewController,direction: UIRectEdge = .top,duration: CGFloat = 0.3) {
        self._duration = duration
        self.direction = direction
        super.init()
        self.sourceViewController = sourceViewController
        self.wantsInteractiveStart = false
        sourceViewController.addObserver(self, forKeyPath: "view", options: [.new], context: nil)
//        prepare()
    }
    
    private func prepare() {

        let gesture = UIPanGestureRecognizer(target: self, action: #selector(gestureHandler(gesture:)))
        sourceViewController!.view.addGestureRecognizer(gesture)
    }
    
    @objc private func gestureHandler(gesture: UIPanGestureRecognizer) {
        
        
        let translation = gesture.translation(in: sourceViewController!.view)
        var percent: CGFloat = 0
        switch direction {
        case .top,.bottom:
            percent = translation.y / sourceViewController!.view.bounds.size.height
        case .left,.right,.all:
            percent = translation.x / sourceViewController!.view.bounds.size.width
        default:
            break
        }
        
        switch gesture.state {
        case .began:
            wantsInteractiveStart = true
            sourceViewController?.dismiss(animated: true, completion: nil)
        case .changed:
            switch direction {
            case .top:
                if percent < 0 {
                    update(abs(percent))
                }
            case .bottom:
                if percent > 0 {
                    update(abs(percent))
                }
            default:
                break
            }
            
        case .cancelled,.failed:
            cancel()
            wantsInteractiveStart = false
        case .ended:
            wantsInteractiveStart = false
            let velocity = gesture.velocity(in: sourceViewController!.view)
            switch direction {
            case .top:
                if percent <= -0.4 || velocity.y < 0 {
                    finish()
                } else {
                    cancel()
                }
            case .bottom:
                if percent >= 0.5 || velocity.y > 0 {
                    finish()
                } else {
                    cancel()
                }
            default:
                break
            }

            
        default:
            break;
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let isViewLoaded = sourceViewController?.isViewLoaded,isViewLoaded == true {
            prepare()
        }
    }
    
    deinit {
        sourceViewController?.removeObserver(self, forKeyPath: "view")
        debugPrint(Self.self)
    }
}
