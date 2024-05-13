//
//  MPImagePickerCell.swift
//  BasicProject
//
//  Created by ogawa on 2022/1/13.
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


class MPImagePickerCell: UICollectionViewCell,MPImageCellContentProtocol {
    
    var asset: PHAsset? {
        didSet {
            guard let mediaType = asset?.mediaType,mediaType != .unknown && mediaType != .audio else { return }
            guard let duration = asset?.duration, duration > 0 else { durationLabel.isHidden = true; return }
            switch mediaType {
            case .image:
                break
            case .video:
                durationLabel.isHidden = false
                durationLabel.text = duration.formatter
            default:
                break
            }

        }
    }
    
    var imageRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    var selectedIndex: Int = 0
    
    var selectedImage: Bool = false
    
    var isDegraded: Bool = false
    
    weak var imageManger: MPAssetsManager?

    
    
    weak var delegate: MPImagePickerCellDelegate?
    
    //MARK: - initial
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(durationLabel)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5).isActive = true
        durationLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
        durationLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5).isActive = true
        self.contentView.addSubview(flagView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandle(gesture:)))
        tapGesture.delegate = self
        flagView.addGestureRecognizer(tapGesture)
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - tap gesture handler
    
    @objc private func tapGestureHandle(gesture: UIGestureRecognizer) {
    
        if !selectedImage {
            guard let index = delegate?.cellDidSelected(cell: self),index.1 == true else { return }
            setSelectedFlag(index: index.0,selected: index.1)
        }
        else {
            setSelectedFlag(index: 0,selected: false)
            delegate?.cellDidUnSelected(cell: self)
            
        }
        
        
    }
    
    //MARK: - override methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageManger?.cancelRequestImage(requestId: imageRequestID)
        imageManger = nil
        imageRequestID = PHInvalidImageRequestID
        imageView.image = nil
        durationLabel.isHidden = true
        setSelectedFlag(index: 0,selected: false)
    }

    
    
    func setSelectedFlag(index: Int,selected: Bool) {
        selectedImage = selected
        flagView.setSelected(index: index,selected: selectedImage)
    }
    
    //MARK: - UI
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let flagView: MPImagePickerSelectedFlagProtocol = {
        let flag = MPImagePickerFlagView()
        return flag
    }()

    let durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.isHidden = true
        label.textAlignment = .right
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.contentView.bounds
        flagView.frame = self.contentView.bounds
    }
}

extension MPImagePickerCell: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let targeRect = CGRect(x: self.contentView.bounds.width - flagView.selectedView!.frame.width - 10, y: 0, width: flagView.selectedView!.frame.width + 10, height: flagView.selectedView!.frame.width + 10)
        let point = gestureRecognizer.location(in: gestureRecognizer.view)
        if targeRect.contains(point) {
            return true
        }
        else {
            return false
        }
        
    }
}
