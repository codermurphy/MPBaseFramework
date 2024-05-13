//
//  MPAlertAction.swift
//  BasicProject
//
//  Created by ogawa on 2022/1/21.
//

import UIKit

public class MPAlertAction: UIButton {

    internal weak var controller: MPAlertController?
    
    private var clickedCallback: ((MPAlertController?) -> Void)?
    
    public var autoDismiss: Bool = false

    //MARK: - inital
    public init(title: String?,image: UIImage? = nil,action: ((MPAlertController?) -> Void)? = nil) {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        self.clickedCallback = action
        self.setTitleColor(.black, for: .normal)
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: 18)
        self.setImage(image, for: .normal)
        self.addTarget(self, action: #selector(clickedHandler), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func clickedHandler() {
        if clickedCallback == nil {
            controller?.dismiss(animated: true, completion: nil)
        }
        else {
            clickedCallback?(controller)
            if autoDismiss {
                
                controller?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - ovrride
    public override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        
        if let _ = target as? MPAlertAction {
            super.addTarget(target, action: action, for: controlEvents)
        }
        else {
            return
        }
        
    }

    
    deinit {
        debugPrint(Self.self)
    }
}
