//
//  ViewController.swift
//  Stories
//
//  Created by Mahavirsinh Gohil
//  Copyright © 2018 Mahavirsinh Gohil. All rights reserved.
//

import UIKit
import Kingfisher

class StoryViewController: UIViewController {

    @IBOutlet weak var outerCollection: UICollectionView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var rowIndex:Int = 0
    var arrUser = [StoryHandler]()
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    var storyCollection: [[URL]]!
    
    var tapGest: UITapGestureRecognizer!
    var longPressGest: UILongPressGestureRecognizer!
    var panGest: UIPanGestureRecognizer!

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        cancelBtn.addTarget(self, action: #selector(cancelBtnTouched), for: .touchUpInside)
        setupModel()
        addGesture()
    }

    @IBAction func cancelBtnTouched() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK:- Helper Methods
extension StoryViewController {
    
    func setupModel() {
        for collection in storyCollection {
            preDownloadImages(collection: collection)
            arrUser.append(StoryHandler(stories: collection))
        }
        StoryHandler.userIndex = rowIndex
        outerCollection.reloadData()
        outerCollection.scrollToItem(at: IndexPath(item: StoryHandler.userIndex, section: 0),
                                     at: .centeredHorizontally, animated: false)
    }
    
    func preDownloadImages(collection: [URL]) {
        let imageView = UIImageView()
        for storyURL in collection {
            imageView.kf.setImage(with: storyURL,
                                  options: [.memoryCacheExpiration(.days(2))]) { (result) in }
        }
    }
    
    func currentStoryIndexChanged(index: Int) {
        arrUser[StoryHandler.userIndex].storyIndex = index
    }
    
    func showNextUserStory() {
        let newUserIndex = StoryHandler.userIndex + 1
        if newUserIndex < arrUser.count {
            StoryHandler.userIndex = newUserIndex
            showUpcomingUserStory()
        } else {
            cancelBtnTouched()
        }
    }
    
    func showPreviousUserStory() {
        let newIndex = StoryHandler.userIndex - 1
        if newIndex >= 0 {
            StoryHandler.userIndex = newIndex
            showUpcomingUserStory()
        } else {
            cancelBtnTouched()
        }
    }
    
    func showUpcomingUserStory() {
        removeGestures()
        let indexPath = IndexPath(item: StoryHandler.userIndex, section: 0)
        outerCollection.reloadItems(at: [indexPath])
        outerCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        self.addGesture()
    }
    
    func getCurrentStory() -> StoryBar? {
        if let cell = outerCollection.cellForItem(at: IndexPath(item: StoryHandler.userIndex, section: 0)) as? OuterCell {
            return cell.storyBar
        }
        return nil
    }
}

// MARK:- Gestures
extension StoryViewController {
    
    func addGesture() {
        
        // for previous and next navigation
        tapGest = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGest)
        
        longPressGest = UILongPressGestureRecognizer(target: self,
                                                         action: #selector(panGestureRecognizerHandler))
        longPressGest.minimumPressDuration = 0.2
        self.view.addGestureRecognizer(longPressGest)
        
        /*
         swipe down to dismiss
         NOTE: Self's presentation style should be "Over Current Context"
         */
        panGest = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler))
        self.view.addGestureRecognizer(panGest)
    }
    
    func removeGestures() {
        self.view.removeGestureRecognizer(tapGest)
        self.view.removeGestureRecognizer(longPressGest)
        self.view.removeGestureRecognizer(panGest)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let touchLocation: CGPoint = gesture.location(in: gesture.view)
        let maxLeftSide = ((view.bounds.maxX * 40) / 100) // Get 40% of Left side
        if let storyBar = getCurrentStory() {
            if touchLocation.x < maxLeftSide {
                storyBar.previous()
            } else {
                storyBar.next()
            }
        }
    }
    
    @objc func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        guard let storyBar = getCurrentStory() else { return }

        let touchPoint = sender.location(in: self.view?.window)
        if sender.state == .began {
            storyBar.pause()
            initialTouchPoint = touchPoint
        } else if sender.state == .changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.view.frame = CGRect(x: 0, y: max(0, touchPoint.y - initialTouchPoint.y),
                                         width: self.view.frame.size.width,
                                         height: self.view.frame.size.height)
            }
        } else if sender.state == .ended || sender.state == .cancelled {
            if touchPoint.y - initialTouchPoint.y > 200 {
                dismiss(animated: true, completion: nil)
            } else {
                storyBar.resume()
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0,
                                             width: self.view.frame.size.width,
                                             height: self.view.frame.size.height)
                })
            }
        }
    }
}

// MARK:- Collection View Data Source and Delegate
extension StoryViewController: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIScreen.main.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! OuterCell
        cell.weakParent = self
        cell.setStory(story: arrUser[indexPath.row])
        return cell
    }
}

// MARK:- Scroll View Delegate
extension StoryViewController {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let storyBar = getCurrentStory() {
            storyBar.pause()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let lastIndex = StoryHandler.userIndex
        let pageWidth = outerCollection.frame.size.width
        let pageNo = Int(floor(((outerCollection.contentOffset.x + pageWidth / 2) / pageWidth)))

        if lastIndex != pageNo {
            StoryHandler.userIndex = pageNo
            showUpcomingUserStory()
        } else {
            if let storyBar = getCurrentStory() {
                self.addGesture()
                storyBar.resume()
            }
        }
    }
}
