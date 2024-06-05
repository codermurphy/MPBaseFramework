//
//  MPImagePickerFlagView.swift
//  BasicProject
//
//  Created by ogawa on 2022/1/13.
//

import UIKit

class MPAssetsPickerFlagView: UIView,MPAssetsPickerSelectedFlagProtocol {
    
    

    //MARK: - initial
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
        
    //MARK: - public
    
    func setSelected(index: Int,selected: Bool) {
        selectedIndexLabel.text = "\(index)"
        if selected {
            selectedIndexLabel.isHidden = false
            self.backgroundColor = .black.withAlphaComponent(0.4)
            self.selectedView!.isSelected = true
        }
        else {
            selectedIndexLabel.isHidden = true
            self.backgroundColor = .clear
            self.selectedView!.isSelected = false
        }
        
    }
    
    //MARK: - private
    
    private func commonInit() {
        self.addSubview(selectedView!)
        

        
        self.addSubview(selectedIndexLabel)
        selectedIndexLabel.isHidden = true
        
    }
    
    //MARK: - override methods
    
    
    //MARK: - UI
    
    
    var selectedIndexLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15,weight: .bold)
        label.textColor = .white
        return label
    }()
    
    var selectedView: MPTickSelectedProtocol? = MPTickSelectedView(size: CGSize(width: 18, height: 18))
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectedView!.frame.origin = CGPoint(x: self.bounds.width - selectedView!.frame.width - 3, y: 3)
        selectedIndexLabel.frame.size = CGSize(width: selectedView!.frame.origin.x - 5, height: 15)
        selectedIndexLabel.center = CGPoint(x: selectedIndexLabel.frame.size.width * 0.5 + 5, y: selectedView!.frame.size.height * 0.5)
        
    }
}
