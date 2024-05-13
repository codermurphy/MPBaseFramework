//
//  MPSheetBottomController.swift
//  BasicProject
//
//  Created by ogawa on 2021/12/31.
//

import UIKit

internal class MPSheetBottomPresentController: UIPresentationController,UIGestureRecognizerDelegate {


    private func configGesture() {

        let gesture = UITapGestureRecognizer()
        gesture.delegate = self
        gesture.addTarget(self, action: #selector(dismissTapGestureHandler(gesture:)))
        self.containerView?.addGestureRecognizer(gesture)

    }
    
    @objc private func dismissTapGestureHandler(gesture: UITapGestureRecognizer) {
        guard let container = containerView,let toView = presentedView else { return }
        let point = gesture.location(in: container)
        if !toView.frame.contains(point) {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
        
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let container = containerView,let toView = presentedView else { return false}
        let point = gestureRecognizer.location(in: container)
        if !toView.frame.contains(point) {
            return true
        }
        else {
            return false
        }
    }

        
    //MARK: - override
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let controller = presentedViewController as? MPSheetBottomController else {
            return super.frameOfPresentedViewInContainerView
        }
        return CGRect(x: 0, y: super.frameOfPresentedViewInContainerView.height - controller.style.containerHeight, width: super.frameOfPresentedViewInContainerView.width, height: controller.style.containerHeight)
    }
    
    override func presentationTransitionWillBegin() {
        guard let toView = presentedView else { return }
        
        configGesture()
        if let controller = presentedViewController as? MPSheetBottomController {
            if controller.style.isShowBarrier {
                containerView?.backgroundColor = controller.style.barrierColor
            }
            
        }
        toView.frame = frameOfPresentedViewInContainerView
    }
    

    deinit {
        debugPrint(Self.self)
    }
}

public class MPSheetBottomControllerConfig: NSObject {
    
    public static let shareConfig = MPSheetBottomControllerConfig()
    
    //MARK: - property
        
    /// 最大高度
    public var containerHeight: CGFloat = 500
    
    /// 是否显示背景
    public var isShowBarrier: Bool = true
    
    /// 背景颜色
    public var barrierColor: UIColor? = .black.withAlphaComponent(0.2)
    
    /// 内容背景色
    public var backgroundColor: UIColor? = .white
    
    /// 内容圆角
    public var cornerRadius: CGFloat = 20
    
    /// 是否显示阴影
    public var isShowShadow = true
    
    /// 阴影颜色
    public var shadowColor: UIColor? = .black.withAlphaComponent(0.5)
    
    /// 阴影偏移量
    public var shadowOffset: CGSize = .zero
    
    /// 阴影半径
    public var shadowRadius: CGFloat = 10
    
    /// 阴影透明度
    public var shadowOpacity: Float = 1
    
}


public class MPSheetBottomController: UIViewController {
    
    //MARK: - initial
    public init(style: MPSheetBottomControllerConfig = MPSheetBottomControllerConfig.shareConfig) {
        
        self.style = style
        
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .custom
        
        configAnimator()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - properyt
    
    private var proxy: MPPrecentAndDismissTransitiongingProxy?
        
    private(set) var style: MPSheetBottomControllerConfig

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear
        // Do any additional setup after loading the view.
        configStyle()

        layout()
    }
    
    //MARK: - config
    
    private func configAnimator() {
        let animator = MPControllerAnimator()
        
        animator.animation = MPTransitioningAnimations.sheetBottomAnimation.animation
    
        self.proxy = MPPrecentAndDismissTransitiongingProxy(animator: animator,
                                                  percentDrivenInteractiveTransition: MPDirectionPercentInteractiveTransition(sourceViewController: self,direction: .bottom),
                                                  presentationClass: MPSheetBottomPresentController.self)
        self.transitioningDelegate = self.proxy
    }
    
    private func configStyle() {
        
        if style.isShowShadow {
            self.view.layer.shadowColor = style.shadowColor?.cgColor
            self.view.layer.shadowOffset = style.shadowOffset
            self.view.layer.shadowRadius = style.shadowRadius
            self.view.layer.shadowOpacity = style.shadowOpacity
            self.view.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: style.containerHeight),
                                                      byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: CGFloat(style.cornerRadius), height: CGFloat(style.cornerRadius))).cgPath
        }

        if style.cornerRadius > 0 {
            let cornerMask = CAShapeLayer()
            
            let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.width,
                                                         height: style.containerHeight),
                                     byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: CGFloat(style.cornerRadius), height: CGFloat(style.cornerRadius))).cgPath
            cornerMask.path = path
            containerView.layer.mask = cornerMask
        }

        containerView.backgroundColor = style.backgroundColor
        
    }
    
    
    //MARK: - UI
    private var indicatorView: UIView?
    
    
    private let containerView: UIView =  {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private func layout() {
        
        if indicatorView == nil {
            indicatorView = UIView()
            indicatorView?.backgroundColor = .lightGray
            indicatorView?.frame = CGRect(x: (self.view.bounds.width - 50) * 0.5, y: 10, width: 50, height: 5)
            indicatorView?.layer.cornerRadius = 2.5
            indicatorView?.clipsToBounds = true
            containerView.addSubview(indicatorView!)
        }
        
        self.view.addSubview(containerView)
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: style.containerHeight)
    }
    
    
    deinit {
        debugPrint(Self.self)
    }


}
