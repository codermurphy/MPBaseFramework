//
//  MPToast.swift
//  BasicProject
//
//  Created by ogawa on 2021/12/23.
//

import UIKit

public final class MPToastStyle: NSObject {
    
    public enum ToastPosition {
        case top
        case center
        case bottom
    }
    
    static public let share = MPToastStyle()
    
    /// 所在位置
    public var position: ToastPosition = .top
    
    /// 是否移动之前的提示
    public var isMovePreToast = false
    
    /// 是否自动隐藏
    public var isAutoDismiss = true
    
    /// 自动隐藏时间
    public var autoDismissTimeinterval: TimeInterval = 2
    
    /// 是否显示圆角
    public var isShowCorner = true
    
    /// 是否直接显示半圆角 ture：cornerRadius无效
    public var isShowCircleCorner = true
    
    ///  圆角
    public var cornerRadius: CGFloat = 10
    
    public var margin: UIEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    
    public var padding: UIEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    
    /// 图标与文本内容的间距
    public var imageWithContentSpacing: CGFloat = 5
    
    /// 标题与内容之间的间距
    public var titleWithMessageSpacing: CGFloat = 0
    
    /// 图标的默认大小
    public var imageDefaultSize: CGSize = CGSize(width: 30, height: 30)
    
    /// 背景色
    public var backgroundColor: UIColor? = .white
    
    /// 是否显示阴影
    public var isShowShadow: Bool = true
    
    /// 阴影颜色
    public var shadowColor: UIColor? = UIColor.lightGray
    
    /// 阴影偏移量
    public var shadowOffSet: CGSize = .zero
    
    /// 阴影透明度
    public var shadowOpacity: Float = 1.0
    
    /// 阴影半径
    public var shadowRadius: CGFloat = 5
    
    /// 标题颜色
    public var titleColor: UIColor? = .black
    
    /// 标题字体
    public var titleFont: UIFont = .systemFont(ofSize: 18, weight: .medium)
    
    /// 标题文本对齐
    public var titleAliganment: NSTextAlignment = .center
        
    /// 消息颜色
    public var messageColor: UIColor? = .black
    
    /// 消息字体
    public var messageFont: UIFont = .systemFont(ofSize: 15)
    
    /// 消息文本对齐
    public var messageAliganment: NSTextAlignment = .center
    
}

public class MPToast: UIView {
    
    private enum ToastType {
        case none
        case title
        case message
        case image
        case titleMessage
        case titleImage
        case messageImage
        case titleMessageImage
    }
    
    public enum ToastLocation {
        case top
        case center
        case bottom
    }
    
    

    //MARK: - initial
        
    convenience init(view: UIView,title: String?,message: String?,image: UIImage?,style: MPToastStyle? = nil) {
        self.init()
        
        self.style = style ?? MPToastStyle.share
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = false
                
        self.title = title
        self.message = message
        self.image = image
        self.configToastType()
        self.commonInit(view: view)
        self.configStyle()

        self.showAnimation()
    }
    
    
    static public func show(sourceView: UIView? = nil,title: String? = nil,message: String? = nil,image: UIImage? = nil,style: MPToastStyle? = nil) {
        
        if sourceView == nil {
            guard let window = UIApplication.shared.delegate?.window, let nonilWindow = window else { return }
            
            let _ = MPToast(view: nonilWindow,title: title, message: message, image: image,style: style)
        }
        else {
            
            let _ = MPToast(view: sourceView!,title: title, message: message, image: image,style: style)
        }


        
    }
    
    //MARK: - property
        
    private var title: String?
        
    private var message: String?
    
    private var image: UIImage?
        
    private var type: ToastType = .none
    
    private var style: MPToastStyle!
    
    //MARK: - common
    
    private func configToastType() {
    
        if title == nil && message == nil && image == nil {
            self.type = .none
        }
        else if title != nil && message == nil && image == nil {
            self.type = .title
            titleLabel.textColor = style.titleColor
            titleLabel.textAlignment = style.titleAliganment
            titleLabel.font = style.titleFont
            titleLabel.text = title
            titleLabel.sizeToFit()
            containerView.addSubview(titleLabel)
        }
        else if title != nil && message != nil && image == nil {
            self.type = .titleMessage
            titleLabel.textColor = style.titleColor
            titleLabel.textAlignment = style.titleAliganment
            titleLabel.font = style.titleFont
            
            messageLabel.textColor = style.messageColor
            messageLabel.textAlignment = style.messageAliganment
            messageLabel.font = style.messageFont
            titleLabel.text = title
            messageLabel.text = message
            titleLabel.sizeToFit()
            messageLabel.sizeToFit()
            containerView.addSubview(titleLabel)
            containerView.addSubview(messageLabel)
        }
        else if title != nil && message == nil && image != nil {
            self.type = .titleImage
            titleLabel.textColor = style.titleColor
            titleLabel.textAlignment = style.titleAliganment
            titleLabel.font = style.titleFont
            titleLabel.text = title
            titleLabel.sizeToFit()
            icon.image = image
            containerView.addSubview(icon)
            containerView.addSubview(titleLabel)
        }
        else if title != nil && message != nil && image != nil {
            self.type = .titleMessageImage
            titleLabel.textColor = style.titleColor
            titleLabel.textAlignment = style.titleAliganment
            titleLabel.font = style.titleFont
            
            messageLabel.textColor = style.messageColor
            messageLabel.textAlignment = style.messageAliganment
            messageLabel.font = style.messageFont
            titleLabel.text = title
            messageLabel.text = message
            titleLabel.sizeToFit()
            messageLabel.sizeToFit()
            icon.image = image
            containerView.addSubview(icon)
            containerView.addSubview(titleLabel)
            containerView.addSubview(messageLabel)
        }
        else if title == nil && message != nil && image == nil {
            self.type = .message
            messageLabel.textColor = style.messageColor
            messageLabel.textAlignment = style.messageAliganment
            messageLabel.font = style.messageFont
            messageLabel.text = message
            messageLabel.sizeToFit()
            containerView.addSubview(messageLabel)
        }
        else if title == nil && message != nil && image != nil {
            self.type = .messageImage
            icon.image = image
            messageLabel.textColor = style.messageColor
            messageLabel.textAlignment = style.messageAliganment
            messageLabel.font = style.messageFont
            messageLabel.text = message
            messageLabel.sizeToFit()
            containerView.addSubview(icon)
            containerView.addSubview(messageLabel)
        }
        else {
            self.type = .image
            icon.image = image
            icon.sizeToFit()
            containerView.addSubview(icon)
        }
    }
    
    private func commonInit(view: UIView) {
        
        

        
        self.addSubview(containerView)


        let maxWidth: CGFloat = view.bounds.width - style.margin.left - style.margin.right
        
        var contentWidth: CGFloat = 0
        
        var contentHeight: CGFloat = 0
        
        var titleSize: CGSize = .zero
        
        var messageSize: CGSize = .zero
        
        var imageSize: CGSize = image?.size ?? .zero
        
        switch self.type {
        case .title:
            
            titleSize = titleLabel.frame.size
            contentWidth = min(maxWidth,titleSize.width + style.padding.left + style.padding.right)
            let fitContainSize: CGSize = CGSize(width: contentWidth - style.padding.left - style.padding.right, height: CGFloat.greatestFiniteMagnitude)
            if contentWidth == maxWidth {
                titleSize = titleLabel.sizeThatFits(fitContainSize)
            }
            contentHeight = titleSize.height + style.padding.top + style.padding.bottom
            titleLabel.frame.origin = CGPoint(x: style.padding.left + (fitContainSize.width - titleSize.width) * 0.5,
                                              y: style.padding.top)
            titleLabel.frame.size = titleSize
            
        case .titleMessage:
            
            titleSize = titleLabel.frame.size
            messageSize = messageLabel.frame.size
            contentWidth = min(maxWidth,max(titleSize.width,messageSize.width) + style.padding.left + style.padding.right)
            let fitContainSize: CGSize = CGSize(width: contentWidth - style.padding.left - style.padding.right, height: CGFloat.greatestFiniteMagnitude)

            if contentWidth == maxWidth {
                titleSize = titleLabel.sizeThatFits(fitContainSize)
                messageSize = messageLabel.sizeThatFits(fitContainSize)
            }
            contentHeight = titleSize.height + messageSize.height + style.padding.top + style.padding.bottom + style.titleWithMessageSpacing

            titleLabel.frame.origin = CGPoint(x: style.padding.left + (fitContainSize.width - titleSize.width) * 0.5,
                                              y: style.padding.top)
            titleLabel.frame.size = titleSize
            messageLabel.frame.origin = CGPoint(x: style.padding.left + (fitContainSize.width - messageSize.width) * 0.5,
                                                y: style.padding.top + titleSize.height + style.titleWithMessageSpacing)
            messageLabel.frame.size = messageSize
            
        case .titleImage:
            
            titleSize = titleLabel.frame.size
            imageSize = imageSize.width + style.padding.left + style.padding.right >= maxWidth ? style.imageDefaultSize : imageSize
            contentWidth = min(maxWidth,titleSize.width + imageSize.width + style.padding.left + style.padding.right + style.imageWithContentSpacing)
            
            let fitContainSize: CGSize = CGSize(width: contentWidth - imageSize.width - style.imageWithContentSpacing - style.padding.left - style.padding.right,
                                                height: CGFloat.greatestFiniteMagnitude)
            if contentWidth == maxWidth {
                
                titleSize = titleLabel.sizeThatFits(fitContainSize)
            }
            contentHeight = max(imageSize.height,messageSize.height) + style.padding.top + style.padding.bottom
            
            icon.frame.size = imageSize
            icon.frame.origin = CGPoint(x: style.padding.left, y: (contentHeight - imageSize.height) * 0.5)
            
            titleLabel.frame.size = titleSize
            titleLabel.frame.origin = CGPoint(x: style.padding.left + imageSize.width + style.imageWithContentSpacing, y: (contentHeight - titleSize.height) * 0.5)
            
        case .titleMessageImage:
            titleSize = titleLabel.frame.size
            messageSize = messageLabel.frame.size
            imageSize = imageSize.width + style.padding.left + style.padding.right >= maxWidth ? style.imageDefaultSize : imageSize
            contentWidth = min(maxWidth,max(titleSize.width,messageSize.width) + imageSize.width + style.padding.left + style.padding.right + style.imageWithContentSpacing)
            
            let fitContainSize: CGSize = CGSize(width: contentWidth - imageSize.width - style.imageWithContentSpacing - style.padding.left - style.padding.right,
                                                height: CGFloat.greatestFiniteMagnitude)
            if contentWidth == maxWidth {
                
                titleSize = titleLabel.sizeThatFits(fitContainSize)
                messageSize = messageLabel.sizeThatFits(fitContainSize)
            }
            
            contentHeight = max(imageSize.height,messageSize.height + titleSize.height + style.titleWithMessageSpacing) + style.padding.top + style.padding.bottom
            
            icon.frame.size = imageSize
            icon.frame.origin = CGPoint(x: style.padding.left, y: (contentHeight - imageSize.height) * 0.5)
            
            titleLabel.frame.size = CGSize(width: fitContainSize.width, height: titleSize.height)
            titleLabel.frame.origin = CGPoint(x: style.padding.left + imageSize.width + style.imageWithContentSpacing, y: style.padding.top)
            
            messageLabel.frame.origin = CGPoint(x: titleLabel.frame.origin.x,
                                                y: titleLabel.frame.origin.y + titleSize.height + style.titleWithMessageSpacing)
            
            messageLabel.frame.size = CGSize(width: fitContainSize.width, height: messageSize.height)
            
        case .message:
            messageSize = messageLabel.frame.size
            contentWidth = min(maxWidth,messageSize.width + style.padding.left + style.padding.right)
            let fitContainSize: CGSize = CGSize(width: contentWidth - style.padding.left - style.padding.right, height: CGFloat.greatestFiniteMagnitude)
            if contentWidth == maxWidth {
                messageSize = messageLabel.sizeThatFits(fitContainSize)
            }
            contentHeight = messageSize.height + style.padding.top + style.padding.bottom
            messageLabel.frame.origin = CGPoint(x: style.padding.left + (fitContainSize.width - messageSize.width) * 0.5, y: style.padding.top)
            messageLabel.frame.size = messageSize
        case .messageImage:
            
            messageSize = messageLabel.frame.size
            imageSize = imageSize.width + style.padding.left + style.padding.right >= maxWidth ? style.imageDefaultSize : imageSize

            contentWidth = min(maxWidth,messageSize.width + imageSize.width + style.padding.left + style.padding.right + style.imageWithContentSpacing)
            
            let fitContainSize: CGSize = CGSize(width: contentWidth - imageSize.width - style.imageWithContentSpacing - style.padding.left - style.padding.right,
                                                height: CGFloat.greatestFiniteMagnitude)
            if contentWidth == maxWidth {
                
                messageSize = messageLabel.sizeThatFits(fitContainSize)
            }
            contentHeight = max(imageSize.height,messageSize.height) + style.padding.top + style.padding.bottom
            
            icon.frame.size = imageSize
            icon.frame.origin = CGPoint(x: style.padding.left, y: (contentHeight - imageSize.height) * 0.5)
            
            messageLabel.frame.size = messageSize
            messageLabel.frame.origin = CGPoint(x: imageSize.width + style.padding.left + style.imageWithContentSpacing,
                                                y: (contentHeight - messageSize.height) * 0.5)
            
        case .image:
            contentWidth = min(maxWidth,imageSize.width + style.padding.left + style.padding.right)
            
            if contentWidth == maxWidth {
                let scale = imageSize.height / imageSize.width
                imageSize.width = contentWidth - style.padding.left - style.padding.right
                imageSize.height = imageSize.width * scale
                contentHeight = imageSize.height + style.padding.top + style.padding.bottom
            }
            contentHeight = imageSize.height + style.padding.top + style.padding.bottom
            icon.frame.origin = CGPoint(x: style.padding.left, y: style.padding.top)
            icon.frame.size = imageSize
            
        case .none:
            return
        }
        
        
        self.frame.size = CGSize(width: contentWidth, height: contentHeight)
        containerView.frame = self.bounds
        
        configPosition(source: view)
        
        movePreToast(source: view)

        view.addSubview(self)

    }
    
    private func movePreToast(source: UIView) {
        
        if style.isMovePreToast {
            let toasts = source.subviews.filter({ $0 is MPToast}).reversed()
            
            var preToast: UIView = self
            
            for toast in toasts {
                
                UIView.animate(withDuration: 0.3) {
                    toast.transform = CGAffineTransform(translationX: 0, y: preToast.frame.maxY)
                }
                preToast = toast as! MPToast
            }
        }

        
    }
    
    private func configPosition(source: UIView) {
        
        switch style.position {
        case .top:
            
            if let nextResponder = source.next,nextResponder is UIViewController {
                self.frame.origin = CGPoint(x: (source.bounds.width - self.bounds.width) * 0.5, y: style.margin.top)
            }
            else {
                self.frame.origin = CGPoint(x: (source.bounds.width - self.bounds.width) * 0.5, y:  source.mpsafeAreaInsets.top + style.margin.top)
            }
        case .center:
            
            self.frame.origin = CGPoint(x: (source.bounds.width - self.bounds.width) * 0.5, y: ((source.bounds.height - source.mpsafeAreaInsets.top) - self.bounds.height) * 0.5)
            
        case .bottom:
            
            self.frame.origin = CGPoint(x: (source.bounds.width - self.bounds.width) * 0.5,
                                        y: source.bounds.height - (self.bounds.height + source.mpsafeAreaInsets.top +  source.mpsafeAreaInsets.bottom + style.margin.bottom))
        }
        
    }
    
    private func configStyle() {
        
        self.containerView.backgroundColor = style.backgroundColor

        if style.isShowCorner {
            
            containerView.layer.cornerRadius = style.isShowCircleCorner ? self.frame.height * 0.5 : style.cornerRadius
            containerView.clipsToBounds = true
        }
        
        if style.isShowShadow {
            self.layer.shadowColor = style.shadowColor?.cgColor
            self.layer.shadowOffset = style.shadowOffSet
            self.layer.shadowOpacity = style.shadowOpacity
            self.layer.shadowRadius = style.shadowRadius
            if style.isShowCorner {
                self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: containerView.layer.cornerRadius).cgPath
            }
        }
        
        if style.isAutoDismiss {
            DispatchQueue.main.asyncAfter(deadline: .now() + style.autoDismissTimeinterval) { [weak self] in
                self?.hiddenAnimation()
            }
        }
    
    }
    
    //MARK: - show animate
    
    private func showAnimation() {
        
        self.alpha = 0
        switch style.position {
        case .top:
            self.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
        case .center:
            self.transform = CGAffineTransform(translationX:  self.frame.width, y: 0)
        case .bottom:
            self.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
        }
        
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            
            self?.alpha = 1
            self?.transform = CGAffineTransform.identity
        }
    }
    
    private func hiddenAnimation() {
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.alpha = 0
            switch weakSelf.style.position {
            case .top:
                weakSelf.transform = CGAffineTransform(translationX: 0, y: -weakSelf.frame.height)
            case .center:
                weakSelf.transform = CGAffineTransform(translationX: -weakSelf.frame.width, y: 0)
            case .bottom:
                weakSelf.transform = CGAffineTransform(translationX: 0, y: weakSelf.frame.height)
            }
            
        } completion: { [weak self] _ in
            self?.removeFromSuperview()
        }

        
    }

    //MARK: - UI
    
    private let containerView: UIView = {
        let container = UIView()
        
        return container
    }()
        
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    deinit {
        debugPrint(Self.self)
    }
}

//MARK: - UIView SafeInsets extentsion

extension UIView {
    
    var mpsafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        }
        else {
            return self.layoutMargins
        }
    }
    
    public func mp_showToast(title: String? = nil,message: String? = nil,image: UIImage? = nil,style: MPToastStyle? = nil) {
        
        let _ = MPToast(view: self, title: title, message: message, image: image, style: style)
    }
}
