//
//  StoryBar.swift
//  Stories
//
//  Created by Mahavirsinh Gohil on 16/10/17.
//  Copyright © 2017 Mahavirsinh Gohil. All rights reserved.
//

import Foundation
import UIKit

class Segment {
    let nonAnimatingBar = UIView()
    let animatingBar = UIView()
    init() {
    }
}

protocol SegmentedProgressBarDelegate: class {
    func segmentedProgressBarChangedIndex(index: Int)
    func segmentedProgressBarReachEnd()
    func segmentedProgressBarReachPrevious()
}

class StoryBar : UIView{
    
    weak var delegate: SegmentedProgressBarDelegate?
    var animatingBarColor = UIColor.gray {
        didSet {
            updateColors()
        }
    }
    var nonAnimatingBarColor = UIColor.gray.withAlphaComponent(0.25) {
        didSet {
            updateColors()
        }
    }
    var padding: CGFloat = 2.0
    var segments = [Segment]()
    let duration: TimeInterval
    var currentAnimationIndex = 0
    var barAnimation: UIViewPropertyAnimator?
    
    init(numberOfSegments: Int, duration: TimeInterval = 5.0) {
        self.duration = duration
        super.init(frame: CGRect.zero)
        
        for _ in 0..<numberOfSegments {
            let segment = Segment()
            addSubview(segment.nonAnimatingBar)
            addSubview(segment.animatingBar)
            segments.append(segment)
        }
        updateColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stop()
    }
    
    func updateColors() {
        for segment in segments {
            segment.animatingBar.backgroundColor = animatingBarColor
            segment.nonAnimatingBar.backgroundColor = nonAnimatingBarColor
        }
    }
    
    func getYPosition() -> CGFloat {
        if #available(iOS 11.0, *) {
            let _appDelegator = UIApplication.shared.delegate! as! AppDelegate
            if let bottom = _appDelegator.window?.safeAreaInsets.bottom {
                return bottom
            }
        }
        return 0
    }
}

// MARK: - Playback
extension StoryBar {
    
    func resetSegmentFrames() {
        let width = (frame.width - (padding * CGFloat(segments.count - 1)) ) / CGFloat(segments.count)
        for (index, segment) in segments.enumerated() {
            let segFrame = CGRect(x: CGFloat(index) * (width + padding),
                                  y: getYPosition(),
                                  width: width,
                                  height: frame.height)
            segment.nonAnimatingBar.frame = segFrame
            segment.animatingBar.frame = CGRect(origin: segFrame.origin,
                                                size: CGSize(width: 0, height: segFrame.size.height))
            
            let cr = frame.height / 2
            segment.nonAnimatingBar.layer.cornerRadius = cr
            segment.animatingBar.layer.cornerRadius = cr
        }
    }
    
    func resetSegmentsTill(index: Int) {
        var resetTillIndex = index
        stop()

        if resetTillIndex > segments.count - 1 {
            resetTillIndex = segments.count - 1
        }

        currentAnimationIndex = resetTillIndex
        resetSegmentFrames()
        for segmentIdx in 0..<resetTillIndex {
            segments[segmentIdx].animatingBar.frame.size.width = segments[segmentIdx].nonAnimatingBar.frame.size.width
        }
    }
    
    func removeOldAnimation(newWidth: CGFloat = 0) {
        stop()
        let oldAnimatingBar = segments[currentAnimationIndex].animatingBar
        oldAnimatingBar.frame.size.width = newWidth
    }
    
    func previous() {
        removeOldAnimation()
        let newIndex = currentAnimationIndex - 1
        if newIndex < 0 {
            delegate?.segmentedProgressBarReachPrevious()
        } else {
            currentAnimationIndex = newIndex
            removeOldAnimation()
            delegate?.segmentedProgressBarChangedIndex(index: newIndex)
            currentAnimationIndex = newIndex
//            animate(animationIndex: newIndex)
        }
    }

    func next() {
        let newIndex = currentAnimationIndex + 1
        if newIndex < segments.count {
            let oldSegment = segments[currentAnimationIndex]
            removeOldAnimation(newWidth: oldSegment.nonAnimatingBar.frame.width)
            delegate?.segmentedProgressBarChangedIndex(index: newIndex)
            currentAnimationIndex = newIndex
//            animate(animationIndex: newIndex)
        } else {
            delegate?.segmentedProgressBarReachEnd()
        }
    }
}

// MARK: - Animations
extension StoryBar {
    
    func showStoryBar() {
        if self.alpha == 0 {
            UIView.animate(withDuration: 0.2) {
                self.alpha = 1
            }
        }
    }
    
    func hideStoryBar() {
        if self.alpha == 1 {
            UIView.animate(withDuration: 0.2) {
                self.alpha = 0
            }
        }
    }
    
    func startAnimation() {
        layoutSubviews()
        animate(animationIndex: currentAnimationIndex)
    }
    
    func pause() {
        guard let barAnimation = barAnimation else { return }
        if barAnimation.isRunning {
            hideStoryBar()
            barAnimation.pauseAnimation()
        }
    }
    
    func resume() {
        guard let barAnimation = barAnimation else { return }
        if !barAnimation.isRunning {
            showStoryBar()
            barAnimation.startAnimation()
        }
    }
    
    func stop() {
        guard let barAnimation = barAnimation else { return }
        barAnimation.stopAnimation(true)
        if barAnimation.state == .stopped {
            barAnimation.finishAnimation(at: .current)
        }
    }
    
    func animate(animationIndex: Int) {
        let currentSegment = segments[animationIndex]
        
        if let _ = barAnimation {
            barAnimation = nil
        }
        
        showStoryBar()
        barAnimation = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: { 
            currentSegment.animatingBar.frame.size.width = currentSegment.nonAnimatingBar.frame.width
        })
        
        barAnimation?.addCompletion { [weak self] (position) in
            if position == .end {
                self?.next()
            }
        }
        
        barAnimation?.isUserInteractionEnabled = false
        barAnimation?.startAnimation()
    }
}
