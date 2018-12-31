//
//  StoryHandler.swift
//  Stories
//
//  Created by Mahavirsinh Gohil
//  Copyright © 2018 Mahavirsinh Gohil. All rights reserved.
//

import UIKit

class StoryHandler {
    var stories: [URL]
    var storyIndex: Int = 0
    static var userIndex: Int = 0
    
    init(stories: [URL]) {
        self.stories = stories
    }
}
