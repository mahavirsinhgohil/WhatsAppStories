//
//  ListViewController.swift
//  Stories
//
//  Created by Mahavirsinh Gohil on 17/10/17.
//  Copyright © 2017 Mahavirsinh Gohil. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let imgCollection = [[UIImage(named:"pexels-photo-4525"),UIImage(named:"pexels-photo-302053"), UIImage(named:"pexels-photo-415326"),UIImage(named:"pexels-photo-452558")],
                         [UIImage(named:"pexels-photo-4525"),UIImage(named:"pexels-photo-452558")],
                         [UIImage(named:"pexels-photo-4525"),UIImage(named:"pexels-photo-302053"), UIImage(named:"pexels-photo-452558")],
                         [UIImage(named:"pexels-photo-4525")],
                         [UIImage(named:"pexels-photo-4525"), UIImage(named:"pexels-photo-452558"), UIImage(named:"pexels-photo-302053"), UIImage(named:"pexels-photo-415326")]] as! [[UIImage]]
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStory" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let storyVC = segue.destination as! StoryViewController
                storyVC.imageCollection = imgCollection
                storyVC.rowIndex = indexPath.row
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
}

// MARK:- Table View Data Source and Delegate
extension ListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imgCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = "User \(indexPath.row + 1)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showStory", sender: self)
    }
}
