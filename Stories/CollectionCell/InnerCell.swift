//
//  InnerCell.swift
//  Stories
//
//  Created by Mahavirsinh Gohil on 19/12/18.
//  Copyright © 2018 Mahavirsinh Gohil. All rights reserved.
//

import UIKit

protocol ImageZoomDelegate: class {
    func imageZoomStart()
    func imageZoomEnd()
}

class InnerCell: UICollectionViewCell {
    
    weak var delegate: ImageZoomDelegate?
    
    @IBOutlet weak var scrollV: UIScrollView!
    @IBOutlet weak var imgStory: UIImageView!
    
    private var isImageDragged:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollV.maximumZoomScale = 3.0;
        scrollV.minimumZoomScale = 1.0;
        scrollV.clipsToBounds = true;
        scrollV.delegate = self
        scrollV.addSubview(imgStory)
    }
}

// MARK:- Helper Methods
extension InnerCell {
    
    func setImage(_ image: UIImage) {
        imgStory.image = image
        isImageDragged = false
        setContentMode()
    }
    
    private func setContentMode() {
        if imgStory.image!.imageOrientation == .up {
            imgStory.contentMode = .scaleAspectFit
        } else if imgStory.image!.imageOrientation == .left || imgStory.image!.imageOrientation == .right {
            imgStory.contentMode = .scaleAspectFill
        }
    }

    private func resetImage() {
        UIView.animate(withDuration: 0.3, animations: { 
            self.scrollV.zoomScale = 1.0
        }) { [weak self] (isAnimationDone) in
            if isAnimationDone {
                self?.delegate?.imageZoomEnd()
                self?.isImageDragged = false
            }
        }
    }
}

// MARK:- Scroll View Data Source and Delegate
extension InnerCell: UIScrollViewDelegate {
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        delegate?.imageZoomStart()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isImageDragged = true
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgStory
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if !isImageDragged {
            resetImage()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        resetImage()
    }
}
