//
//  MPGalleryPreviewProtocol.swift
//
//


import UIKit

public protocol MPGalleryResourceProtocol {
    var count: Int { get }
}

public protocol MPGalleryPreviewProtocol: UIViewController {
    
    associatedtype V: UIView
    
    associatedtype Resource: MPGalleryResourceProtocol
    
    var isHideStatusBar: Bool { set get }
    
    var isHideNavigationBar: Bool { set get}
        
    var sourceView: V { get}
    
    var currentView: V? { get}
    
    var currentIndex: Int { get }
    
    var assets: Resource { get }
        
    var proxy: MPTransitionAnimator? { get }
    
    var targetFrame: CGRect { get }
        
    var currentViewchangeHandle: ((Int) -> V?)? { set get}
    
    init(isPresent: Bool,sourceView: V,currentIndex: Int,assest: Resource)
    
}

public protocol MPGalleryPreviewDetailCellProtocol: UICollectionViewCell {
    
    var imageView: UIImageView { get }
    
    var scrollView: UIScrollView { get }
}

