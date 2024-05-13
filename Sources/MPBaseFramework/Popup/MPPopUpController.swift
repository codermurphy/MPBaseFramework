//
//  MPPopUpController.swift
//  BasicProject
//
//  Created by ogawa on 2021/12/29.
//

import UIKit


class MPPopUpPresentController: UIPresentationController,UIGestureRecognizerDelegate {


    //MARK: - gesture
    func configGesture() {
        guard let controller = self.presentedViewController as? MPPopUpController else { return  }
        guard controller.style.tapBarrierDismiss else { return }
        let gesture = UITapGestureRecognizer()
        gesture.delegate = self
        gesture.addTarget(self, action: #selector(dismissTapGestureHandler(gesture:)))
        self.containerView?.addGestureRecognizer(gesture)

    }
    
    @objc private func dismissTapGestureHandler(gesture: UITapGestureRecognizer) {
        guard let container = containerView,let toView = presentedView else { return }
        let point = gesture.location(in: container)
        if !toView.frame.contains(point) {
            if presentedViewController.isEditing {
                presentedViewController.view.endEditing(true)
            }
            else {
                presentedViewController.dismiss(animated: true, completion: nil)
            }
            
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
        guard let controller = self.presentedViewController as? MPPopUpController else {
            return super.frameOfPresentedViewInContainerView
        }
        return controller.view.frame
    }
    
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let nonilContainerView = containerView,let controller = self.presentedViewController as? MPPopUpController else { return }
        configGesture()
        containerView?.backgroundColor = controller.style.isShowBarrier ? controller.style.barrierColor : containerView?.backgroundColor
        controller.layoutRootView(sourceView: nonilContainerView)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        guard let controller = self.presentedViewController as? MPPopUpController else { return }
        controller.configStyle()

    }
    
    
    deinit {
        debugPrint(Self.self)
    }
}

public struct MPPopUpControllerStyle {
    
    public static var shareStyle = MPPopUpControllerStyle()
    
    public init() {
        
    }
    
    public var maxContainerWidth: CGFloat = 270
    
    public var minContainerHeight: CGFloat = 44
    
    public var topAndBottomMargin: CGFloat = 44
        
        
    public var position: MPTransitioningAnimations.FromDirection = .bottom
    
    public var backgroundColor: UIColor? = .white
    
    public var isShowBarrier: Bool = true
    
    public var barrierColor: UIColor = .black.withAlphaComponent(0.2)
    
    public var tapBarrierDismiss: Bool = true
    
    public var cornerRadius: CGFloat = 10
    
    /// 是否显示阴影
    public var isShowShadow = true
    
    /// 阴影颜色
    public var shadowColor: UIColor? = .black.withAlphaComponent(0.3)
    
    /// 阴影偏移量
    public var shadowOffset: CGSize = .zero
    
    /// 阴影半径
    public var shadowRadius: CGFloat = 10
    
    /// 阴影透明度
    public var shadowOpacity: Float = 1
    
}


//MARK: - MPPopUpController

public class MPPopUpController: UIViewController {
    
    //MARK: - initial
    public init(style: MPPopUpControllerStyle = MPPopUpControllerStyle.shareStyle) {
        
        self.style = style
        
        super.init(nibName: nil, bundle: nil)
    
        self.modalPresentationStyle = .custom

        configProxy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - property
    
    private var proxy: MPPrecentAndDismissTransitiongingProxy?
        
    var style: MPPopUpControllerStyle
    
    private(set) var centerYConstraint: NSLayoutConstraint?
    
    private(set) var bottomConstraint: NSLayoutConstraint?
    
    private(set) var centetXConstraint: NSLayoutConstraint?
    
    private(set) var topConstraint: NSLayoutConstraint?
     
    internal var keyboardRect: CGRect = .zero
      
    // MARK: life cycle
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        layout()
        configStyle()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let nonilContainerView = self.presentationController?.containerView,
           self.presentedViewController != nil && self.presentedViewController!.isBeingDismissed{
            self.configConstraints(sourceView: nonilContainerView)
        }
    }
    
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if coordinator.isAnimated {
            UIView.animate(withDuration: coordinator.transitionDuration) { [weak self] in
                self?.view.superview?.layoutIfNeeded()
            }
        }

    }
    
    //MARK: - config
    
    private func configProxy() {
                
        let animator = MPControllerAnimator()
        
        animator.animation = MPTransitioningAnimations.fromDirectionAnimaiton(style.position).animation
        
        var percentDriven: MPDirectionPercentInteractiveTransition?
        
        switch style.position {
        case.top:
            percentDriven = MPDirectionPercentInteractiveTransition(sourceViewController: self, direction: .top)
        case .bottom:
            percentDriven = MPDirectionPercentInteractiveTransition(sourceViewController: self, direction: .bottom)
        default:
            break;
        }
    
        self.proxy = MPPrecentAndDismissTransitiongingProxy(animator: animator,
                                                  percentDrivenInteractiveTransition: percentDriven,
                                                  presentationClass: MPPopUpPresentController.self)
        self.transitioningDelegate = self.proxy
    }
    
    
    fileprivate func configStyle() {
        
        containerView.backgroundColor = style.backgroundColor
        
        if style.cornerRadius > 0 {
            containerView.layer.cornerRadius = style.cornerRadius
            containerView.clipsToBounds = true
        }
        
        if style.isShowShadow {
            
            self.view.layer.shadowColor = style.shadowColor?.cgColor
            self.view.layer.shadowOffset = style.shadowOffset
            self.view.layer.shadowRadius = style.shadowRadius
            self.view.layer.shadowOpacity = style.shadowOpacity

        }
        
    }
    
    fileprivate func layoutRootView(sourceView: UIView) {
        sourceView.addSubview(self.view)
        configFrame(sourceView: sourceView)
        configConstraints(sourceView: sourceView)
        
    }
    
    
    internal func getMaxHeight(keyboardRect: CGRect = .zero) -> CGFloat {
        guard let superView = self.presentationController?.containerView else {
            return self.view.frame.height - style.topAndBottomMargin * 2 - keyboardRect.height
        }
        return superView.frame.height - style.topAndBottomMargin * 2 - keyboardRect.height
    }
    
    private func configFrame(sourceView: UIView,keyboardRect: CGRect = .zero) {
        var origin: CGPoint = .zero
        
        let width: CGFloat = style.maxContainerWidth == 0 ? sourceView.frame.width : style.maxContainerWidth
        
        let systemLayoutHeight = containerView.systemLayoutSizeFitting(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height
        
        var fitHeight: CGFloat = systemLayoutHeight < style.minContainerHeight ? style.minContainerHeight : systemLayoutHeight
        
        let maxHeight = getMaxHeight(keyboardRect: keyboardRect)
        
        if fitHeight == CGFloat.greatestFiniteMagnitude {
            fitHeight = style.minContainerHeight
        }
        
        if fitHeight != CGFloat.greatestFiniteMagnitude  && fitHeight > maxHeight {
            fitHeight = maxHeight
        }
        
        let size: CGSize = CGSize(width: width, height: fitHeight)
        origin.x = (sourceView.bounds.width - size.width) * 0.5
        switch style.position {
        case .top:
            origin.y = style.topAndBottomMargin
        case .center:
            origin.y = (maxHeight + 2 * style.topAndBottomMargin - size.height) * 0.5
        case .bottom:
            origin.y = sourceView.bounds.height - size.height - style.topAndBottomMargin
        }
                
        self.view.frame = CGRect(origin: origin, size: size)
    }
    
    fileprivate func configConstraints(sourceView: UIView) {
        
        let width: CGFloat = style.maxContainerWidth == 0 ? sourceView.frame.width : style.maxContainerWidth
        
        self.view.widthAnchor.constraint(equalToConstant: width).isActive = true
        switch style.position {
        case .top:
            self.topConstraint = self.view.topAnchor.constraint(equalTo: sourceView.topAnchor,constant: style.topAndBottomMargin)
            self.topConstraint?.isActive = true
            self.bottomConstraint = self.view.bottomAnchor.constraint(lessThanOrEqualTo: sourceView.bottomAnchor, constant: -style.topAndBottomMargin)
            self.bottomConstraint?.isActive = true
        case .center:
            self.topConstraint = self.view.topAnchor.constraint(greaterThanOrEqualTo: sourceView.topAnchor,constant: style.topAndBottomMargin)
            self.topConstraint?.isActive = true
            self.bottomConstraint = self.view.bottomAnchor.constraint(lessThanOrEqualTo: sourceView.bottomAnchor, constant: -style.topAndBottomMargin)
            self.bottomConstraint?.isActive = true
            self.centerYConstraint = self.view.centerYAnchor.constraint(equalTo: sourceView.centerYAnchor)
            self.centerYConstraint?.isActive = true
        case .bottom:
            self.topConstraint = self.view.topAnchor.constraint(greaterThanOrEqualTo: sourceView.topAnchor,constant: style.topAndBottomMargin)
            self.topConstraint?.isActive = true
            self.bottomConstraint = self.view.bottomAnchor.constraint(equalTo: sourceView.bottomAnchor,constant: -style.topAndBottomMargin)
            self.bottomConstraint?.isActive = true
        }
                

        self.centetXConstraint = self.view.centerXAnchor.constraint(equalTo: sourceView.centerXAnchor)
        self.centetXConstraint?.isActive = true
        
        if containerView.subviews.isEmpty {
            self.view.heightAnchor.constraint(equalToConstant: style.minContainerHeight).isActive = true
        }
    }
        
    //MARK: - notifications
    
    internal func addTextFieldEditNotications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBeginEditTextField(notification:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEndEditTextField(notification:)), name: UITextField.textDidEndEditingNotification, object: nil)
    }
    
    internal func addKeyboardNotifations() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIApplication.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIApplication.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIApplication.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameWillChange(notification:)), name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameDidChange(notification:)), name: UIApplication.keyboardDidChangeFrameNotification, object: nil)
    }
    

    
    //MARK: - textfield notificatioin handler
    
    @objc public func didBeginEditTextField(notification: Notification) {
        self.isEditing = true
    }
    
    @objc public func didEndEditTextField(notification: Notification) {
        self.isEditing = false
    }
    
    @objc public func keyboardWillShow(notification: Notification) {
        guard self.presentedViewController == nil else { return }
        guard let keyboradInfo = notification.userInfo else { return }
        guard let endRect = (keyboradInfo[UIApplication.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let duration = (keyboradInfo[UIApplication.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
        guard let superView = self.view.superview else { return }
    
        self.keyboardRect = endRect
        self.centerYConstraint?.isActive = false
        self.bottomConstraint?.constant = -(endRect.height + style.topAndBottomMargin)
        if !self.isBeingPresented {

            UIView.animate(withDuration: duration, delay: 0, options: [.overrideInheritedDuration,.overrideInheritedCurve,.allowAnimatedContent] , animations: {
                superView.layoutIfNeeded()
            }, completion: nil)
        }




    }
    
    @objc public func keyboardDidShow(notification: Notification) {

    }
    
    @objc public func keyboardWillHide(notification: Notification) {

        if self.presentedViewController == nil {
            guard let keyboradInfo = notification.userInfo else { return }
            guard let duration = (keyboradInfo[UIApplication.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
            guard let superView = self.view.superview else { return }
            self.bottomConstraint?.constant = -style.topAndBottomMargin
            self.centerYConstraint?.isActive = true
            self.keyboardRect = .zero
            UIView.animate(withDuration: duration, delay: 0, options: [.overrideInheritedDuration,.overrideInheritedCurve,.allowAnimatedContent,.layoutSubviews] , animations: {
                superView.layoutIfNeeded()
            }, completion: nil)
        }

    }
    
    @objc public func keyboardDidHide(notification: Notification) {

    }
    
    @objc public func keyboardFrameWillChange(notification: Notification) {
        
    }
    
    @objc public func keyboardFrameDidChange(notification: Notification) {
        
    }
    
//    @objc public func keyboar
        
    //MARK: - UI
    
    public let containerView = UIView()
    public func layout() {
        
        
        self.view.addSubview(containerView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        debugPrint(Self.self)
    }
}
