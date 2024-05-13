//
//  MPAlertController.swift
//  BasicProject
//
//  Created by ogawa on 2022/1/18.
//

import UIKit

public class MPAlertController: MPPopUpController {
    
    public enum AlertSheet {
        case top
        case bottom
    }
    
    public enum AlertStyle {
        case alert
        case sheet(AlertSheet)
    }
    
    public struct AlertConfig {
        
        public init() {
            
        }

        public var titleColor: UIColor = .black
        public var titleFont: UIFont = .systemFont(ofSize: 18, weight: .bold)
        
        public var messageColor: UIColor = .lightGray
        public var messageFont: UIFont = .systemFont(ofSize: 16)
        
        public var separatorColor: UIColor = .lightGray.withAlphaComponent(0.3)
        
        public var isShowHorizontalSeparator: Bool = true
        public var isShowVerticalSeparator: Bool = true
        
        public var defaultActionHeight: CGFloat = 44
        
        public var defaultFieldHeight: CGFloat = 44
        public var defaultFieldHorizationMargin: CGFloat = 15
        public var defaultFieldContainerVerticalMargin: CGFloat = 15
        public var defaultFieldSpaceing: CGFloat = 15

    }
    
    //MARK: - initial methods
    public init(style: MPPopUpControllerStyle = MPPopUpControllerStyle.shareStyle,
                config: AlertConfig? = nil,
                tittle: String? = nil,
                message: String? = nil,
                alertStyle: AlertStyle) {
        if tittle == nil && message == nil {
            fatalError("title and message is nil")
        }
        var copyStyle = style
        switch alertStyle {
        case .alert:
            copyStyle.position = .center
        case .sheet(let alertSheet):
            switch alertSheet {
            case .top:
                copyStyle.position = .top
            case .bottom:
                copyStyle.position = .bottom
            }
        }
        
        self.config = config ?? AlertConfig()

        super.init(style: copyStyle)
        
        self.alertTitle = tittle
        self.message = message

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


    //MARK: - life cycle
    public override func viewDidLoad() {
        commonInit()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !textFields.isEmpty && self.isBeingPresented {
            textFields.first?.becomeFirstResponder()
        }
    }
    
    
    //MARK: - property
    
    private var alertTitle: String?
    
    private var message: String?
    
    private var preferStyle: AlertStyle = .alert
    
    private var buttons: [MPAlertAction] = []
    
    private var buttonTotalHeight: CGFloat {
        if buttons.count > 0 {
            if buttons.count <= 2 {
                 return config.defaultActionHeight
            }
            else {
                 return config.defaultActionHeight * CGFloat(buttons.count) + CGFloat(buttons.count - 1)
            }
        }
        else {
            return 0
        }
    }
    
    private var textFields:  [MPAlertTextField] = []
    
    private let config: AlertConfig
    
    private var contentHeightConstaint: NSLayoutConstraint?
    
    private var actionHeightConstaint: NSLayoutConstraint?
        
    //MARK: - public
    
    public func addActionButton(button: MPAlertAction) {
        button.controller = self
        buttons.append(button)
    }
    
    public func addActionButtons(buttons: [MPAlertAction]) {
        for button in buttons {
            button.controller = self
        }
        self.buttons.append(contentsOf: buttons)
    }
    
    
    public func addTextField(field: MPAlertTextField) {
        field.placeholder = "placeholder"
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 5
        field.clipsToBounds = true
        textFields.append(field)
    }
    
    //MARK: - private
    
    private func commonInit() {
        
        if let title = alertTitle {
            titleLabel.text = title
        }
        
        if let nonilMessage = message {
            messageLabel.text = nonilMessage
        }
        
        if !textFields.isEmpty {
            self.addTextFieldEditNotications()
            self.addKeyboardNotifations()
        }
        
    }
    
    //MARK: - UI
    
    private let contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.backgroundColor = .clear
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never

        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 13.0, *) {
            scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        } else {
            // Fallback on earlier versions
        }
        return scrollView
    }()
    
    private let contentView: UIView = {
        let content = UIView()
        content.backgroundColor = .clear
        return content
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var actionContainerView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.backgroundColor = .clear
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never

        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 13.0, *) {
            scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        } else {
            // Fallback on earlier versions
        }
        return scrollView
    }()
    
    
    //MARK: - keyboard notification
    
    public override func keyboardWillShow(notification: Notification) {
        guard self.presentedViewController == nil else { return }
        guard let keyboradInfo = notification.userInfo else { return }
        guard let endRect = (keyboradInfo[UIApplication.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        self.configHeightConstaint(keyboardRect: endRect)
        super.keyboardWillShow(notification: notification)



    }
    
    public override func keyboardWillHide(notification: Notification) {
        self.configHeightConstaint()
        super.keyboardWillHide(notification: notification)

    }
    public override func keyboardDidHide(notification: Notification) {
//        self.configHeightConstaint()
//        super.keyboardDidHide(notification: notification)
    }
    
    private func configHeightConstaint(keyboardRect: CGRect = .zero) {
        
        let targetHeight = contentView.systemLayoutSizeFitting(CGSize(width: style.maxContainerWidth, height: CGFloat.greatestFiniteMagnitude)).height
        let maxHeight = getMaxHeight(keyboardRect: keyboardRect) - (config.isShowHorizontalSeparator ? 1 : 0)
        

        if buttonTotalHeight + targetHeight > maxHeight {
            
            var fitHeight:CGFloat = 0
            var fitcontentHeight:CGFloat = 0
            if buttonTotalHeight >= maxHeight * 0.5 {
                
                if self.actionHeightConstaint == nil {
                    fitcontentHeight = maxHeight - buttonTotalHeight
                }
                else {
                    fitcontentHeight = maxHeight * 0.5
                    fitHeight = maxHeight * 0.5
                }
            }
            else {
                fitcontentHeight = maxHeight - buttonTotalHeight
                fitHeight = buttonTotalHeight
            }

            self.contentHeightConstaint?.constant = fitcontentHeight
            self.actionHeightConstaint?.constant = fitHeight
        }
        else {
            self.contentHeightConstaint?.constant = style.minContainerHeight
            self.actionHeightConstaint?.constant = buttonTotalHeight
        }
    }
    

    //MARK: - override methods
    
   
    
    public override func layout() {
        super.layout()
        
        
        self.containerView.addSubview(contentScrollView)
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        contentScrollView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
        contentScrollView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
        contentScrollView.topAnchor.constraint(equalTo: self.containerView.topAnchor).isActive = true
        contentScrollView.widthAnchor.constraint(equalToConstant: style.maxContainerWidth).isActive = true
        layoutContent()
        if buttons.isEmpty {
            contentScrollView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor).isActive = true
        }
        else {
            layoutActions()
        }

    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if self.isEditing {
            self.bottomConstraint?.constant = -style.topAndBottomMargin
            self.centerYConstraint?.isActive = true
        }           
        
        self.configHeightConstaint(keyboardRect: self.keyboardRect)

        super.viewWillTransition(to: size, with: coordinator)


        
    }
    
    //MARK: - layout
    private func layoutContent() {
        
        contentScrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: contentScrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalToConstant: style.maxContainerWidth).isActive = true
        
        if alertTitle != nil {
            
            contentView.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
            
            if message == nil && textFields.isEmpty {
                titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
            }
        }

        if message != nil {
            contentView.addSubview(messageLabel)
            messageLabel.translatesAutoresizingMaskIntoConstraints = false

            if alertTitle != nil {
                messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
                messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
                messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
            }
            else {
                messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
                messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
                messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
            }
            if textFields.isEmpty {
                messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
            }
            
            
        }
        
        layoutFields()
        
        let targSize = contentView.systemLayoutSizeFitting(CGSize(width: style.maxContainerWidth, height: CGFloat.greatestFiniteMagnitude))
        if targSize.height == CGFloat.greatestFiniteMagnitude {
            contentScrollView.heightAnchor.constraint(equalToConstant: style.minContainerHeight).isActive = true
        }
        else {
            
            if targSize.height <= style.minContainerHeight {
                contentScrollView.heightAnchor.constraint(lessThanOrEqualToConstant: style.minContainerHeight).isActive = true
                self.contentHeightConstaint = contentScrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: targSize.height)
                self.contentHeightConstaint?.isActive = true
            }
            else {
                contentScrollView.heightAnchor.constraint(lessThanOrEqualToConstant: targSize.height).isActive = true
                let maxHeight = getMaxHeight() - (config.isShowHorizontalSeparator ? 1 : 0)
                if targSize.height + buttonTotalHeight > maxHeight {
                    if buttonTotalHeight >= maxHeight * 0.5 {
                        self.contentHeightConstaint = contentScrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: maxHeight * 0.5)
                    }
                    else {
                        self.contentHeightConstaint = contentScrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: style.minContainerHeight)
                    }
                }
                else {
                    self.contentHeightConstaint = contentScrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: style.minContainerHeight)
                }

                self.contentHeightConstaint?.isActive = true
            }
        }
    }
    
    private func layoutFields() {
        
        if !textFields.isEmpty {
            let totalHeight = config.defaultFieldHeight * CGFloat(textFields.count) + CGFloat(textFields.count - 1) * config.defaultFieldSpaceing
            
            let stack = UIStackView(arrangedSubviews: textFields)
            stack.backgroundColor = .clear
            stack.axis = .vertical
            stack.distribution = .fillEqually
            stack.spacing = config.defaultFieldSpaceing
            stack.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(stack)
            
            if message != nil {
                stack.topAnchor.constraint(equalTo: self.messageLabel.bottomAnchor,constant: config.defaultFieldSpaceing).isActive = true
            }
            else {
                if alertTitle == nil {
                    stack.topAnchor.constraint(equalTo: self.contentView.bottomAnchor,constant: config.defaultFieldSpaceing).isActive = true
                }
                else {
                    stack.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor,constant: config.defaultFieldSpaceing).isActive = true
                }
            }
            
            stack.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,constant: config.defaultFieldHorizationMargin).isActive = true
            stack.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,constant: -config.defaultFieldHorizationMargin).isActive = true
            stack.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,constant: -config.defaultFieldSpaceing).isActive = true
            stack.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
        }

    }
    private func layoutActions() {
        
        var separator: UIView?
        if config.isShowHorizontalSeparator {
            
            separator = UIView()
            separator!.backgroundColor = config.separatorColor
            
            self.containerView.addSubview(separator!)
            separator!.translatesAutoresizingMaskIntoConstraints = false
            separator!.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
            separator!.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
            separator!.topAnchor.constraint(equalTo: contentScrollView.bottomAnchor).isActive = true
            separator!.heightAnchor.constraint(equalToConstant: 1).isActive = true
                        
        }
        
        self.containerView.addSubview(actionContainerView)
        actionContainerView.translatesAutoresizingMaskIntoConstraints = false
        actionContainerView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
        actionContainerView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
        actionContainerView.topAnchor.constraint(equalTo: separator?.bottomAnchor ?? contentScrollView.bottomAnchor).isActive = true
        actionContainerView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor).isActive = true
        actionContainerView.widthAnchor.constraint(equalToConstant: style.maxContainerWidth).isActive = true
    
        switch buttons.count {
        case 1:
            let button = buttons.first!
            actionContainerView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.leadingAnchor.constraint(equalTo: actionContainerView.leadingAnchor).isActive = true
            button.trailingAnchor.constraint(equalTo: actionContainerView.trailingAnchor).isActive = true
            button.topAnchor.constraint(equalTo: actionContainerView.topAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: actionContainerView.bottomAnchor).isActive = true
            actionContainerView.heightAnchor.constraint(equalToConstant: config.defaultActionHeight).isActive = true

        case 2:

            let stack = UIStackView(arrangedSubviews: buttons)
            stack.backgroundColor = config.isShowVerticalSeparator ? config.separatorColor : .clear
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.spacing = config.isShowVerticalSeparator ? 1 : 0

            actionContainerView.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.leadingAnchor.constraint(equalTo: actionContainerView.leadingAnchor).isActive = true
            stack.trailingAnchor.constraint(equalTo: actionContainerView.trailingAnchor).isActive = true
            stack.topAnchor.constraint(equalTo: actionContainerView.topAnchor).isActive = true
            stack.bottomAnchor.constraint(equalTo: actionContainerView.bottomAnchor).isActive = true
            stack.widthAnchor.constraint(equalTo: actionContainerView.widthAnchor).isActive = true
            stack.heightAnchor.constraint(equalToConstant: config.defaultActionHeight).isActive = true
            actionContainerView.heightAnchor.constraint(equalToConstant: config.defaultActionHeight).isActive = true
        default:
            
            let totalHeight = config.defaultActionHeight * CGFloat(buttons.count) + CGFloat(buttons.count - 1)
            
            let stack = UIStackView(arrangedSubviews: buttons)
            stack.backgroundColor = config.separatorColor
            stack.axis = .vertical
            stack.distribution = .fillEqually
            stack.spacing = 1
            
            
            actionContainerView.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.leadingAnchor.constraint(equalTo: actionContainerView.leadingAnchor).isActive = true
            stack.trailingAnchor.constraint(equalTo: actionContainerView.trailingAnchor).isActive = true
            stack.topAnchor.constraint(equalTo: actionContainerView.topAnchor).isActive = true
            stack.bottomAnchor.constraint(equalTo: actionContainerView.bottomAnchor).isActive = true
            stack.widthAnchor.constraint(equalTo: actionContainerView.widthAnchor).isActive = true
            stack.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
            
            let maxHeight = getMaxHeight() - (config.isShowHorizontalSeparator ? 1 : 0)
            actionContainerView.heightAnchor.constraint(lessThanOrEqualToConstant: totalHeight).isActive = true
            if totalHeight >= maxHeight * 0.5 {
                self.actionHeightConstaint = actionContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: maxHeight * 0.5)
                self.actionHeightConstaint?.isActive = true
            }
            else {
                self.actionHeightConstaint = actionContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: config.defaultActionHeight)
                self.actionHeightConstaint?.isActive = true
            }
        }
    }
}

