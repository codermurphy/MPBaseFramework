//
//  MPAssetsVideoCell.swift
//  
//
//  Created by ogawa on 2024/6/4.
//

import UIKit
import Photos

extension TimeInterval {
    
    var formatter: String {
        
        
        let intValue = Int(self.rounded())
        
        let hour: Int = intValue / 3600
        let minutes = (intValue - hour * 3600) / 60
        let seconds = intValue - hour * 3600 - minutes * 60
        
        var result = ""
        
        if hour > 0 {
            if hour < 10 {
                result = "0\(hour):"
            }
            else {
                result = "\(hour):"
            }
            
        }
        
        if minutes > 0 {
            if minutes < 10 {
                result += "0\(minutes):"
            }
            else {
                result += "\(minutes):"
            }
        }
        else {
            result += "00:"
        }

        
        if seconds > 0 {
            if seconds < 10 {
                result += "0\(seconds)"
            }
            else {
                result += "\(seconds)"
            }
        }
        else {
            result += "00"
        }
        
        return result
    }
}


class MPAssetsVideoCell: MPAssetsImageCell,MPAssetsPickerCellVideoCellProtocol {
    
    override var asset: PHAsset? {
        didSet {
            guard let mediaType = asset?.mediaType,mediaType == .video else { return }
            guard let duration = asset?.duration, duration > 0 else { durationLabel.isHidden = true; return }
            switch mediaType {
            case .video:
                durationLabel.isHidden = false
                durationLabel.text = duration.formatter
            default:
                break
            }
        }
    }
    
    // MARK: initial
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(durationLabel)
        self.contentView.bringSubviewToFront(self.flagView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: UI
    
    let durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.isHidden = true
        label.textAlignment = .right
        label.text = "00:00"
        label.sizeToFit()
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        durationLabel.frame = CGRect(x: 5,
                                     y: self.contentView.bounds.height - durationLabel.frame.height - 5,
                                     width: self.contentView.bounds.width - 10,
                                     height: durationLabel.frame.height)
    }
    
    
    
}
