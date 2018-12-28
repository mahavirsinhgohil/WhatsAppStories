//
//  InnerCell.swift
//  Stories
//
//  Created by Mahavirsinh Gohil on 19/12/18.
//  Copyright © 2018 Mahavirsinh Gohil. All rights reserved.
//

import UIKit
import Kingfisher

protocol StoryHandlerDelegate: class {
    func startStory()
    func pauseStory()
    func resumeStory()
}

class InnerCell: UICollectionViewCell {
    
    weak var delegate: StoryHandlerDelegate?
    
    @IBOutlet weak var scrollV: UIScrollView!
    @IBOutlet weak var imgStory: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

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
    
    func setStory(_ storyURL: URL) {
        isImageDragged = false
        scrollV.isUserInteractionEnabled = false
        indicator.startAnimating()
        indicator.isHidden = false
        imgStory.kf.setImage(with: storyURL,
                             options: [.transition(.fade(0.2)),
                                       .memoryCacheExpiration(.days(1)),
                                       .downloadPriority(URLSessionTask.highPriority)]) {
                                        [weak self] (result) in
            switch result {
            case .success(_):
                self?.scrollV.isUserInteractionEnabled = true
                self?.indicator.isHidden = true
                self?.setContentMode()
                self?.delegate?.startStory()
            case .failure(let error):
                print("Story Download Error : \(error)")
            }
        }   
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
                self?.delegate?.resumeStory()
                self?.isImageDragged = false
            }
        }
    }
}

// MARK:- Scroll View Data Source and Delegate
extension InnerCell: UIScrollViewDelegate {
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        delegate?.pauseStory()
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
