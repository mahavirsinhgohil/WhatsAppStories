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
    
    let userStoryCollection = [
        [URL(string: "http://www.bhmpics.com/wallpapers/caesar_in_planet_of_the_apes-852x480.jpg"),
         URL(string: "https://www.filmsourcing.com/wp-content/uploads/2014/12/poster_sample_horror_education5.jpg"),
         URL(string: "http://www.bhmpics.com/thumbs/justice_league_batman_team-t3.jpg"),
         URL(string: "https://www.filmsourcing.com/wp-content/uploads/2014/12/its-a-wonderful-life-poster.jpg")],
    [URL(string: "https://www.filmsourcing.com/wp-content/uploads/2014/12/poster_sample_horror_education1.jpg"),
     URL(string: "http://www.bhmpics.com/thumbs/iron_man_in_the_rain-t3.jpg")
        ],
    [URL(string: "https://www.filmsourcing.com/wp-content/uploads/2014/12/poster_sample_horror_education6.jpg"),
     URL(string: "https://www.filmsourcing.com/wp-content/uploads/2014/12/family_man-poster.jpg"),
     URL(string: "http://www.bhmpics.com/wallpapers/giant_gorilla_kong_skull_island-852x480.jpg"),
     URL(string: "https://www.filmsourcing.com/wp-content/uploads/2014/12/poster_sample_horror_education2.jpg"),
     URL(string: "http://www.bhmpics.com/thumbs/logan_2018-t3.jpg"),
     ]] as! [[URL]]
    
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
                storyVC.storyCollection = userStoryCollection
                storyVC.rowIndex = indexPath.row
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
}

// MARK:- Table View Data Source and Delegate
extension ListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userStoryCollection.count
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
