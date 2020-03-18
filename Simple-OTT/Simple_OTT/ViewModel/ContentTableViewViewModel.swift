//
//  ContentTableViewViewModel.swift
//  Simple_OTT
//
//  Copyright © 2020 THEOPlayer. All rights reserved.
//

import os.log
import THEOplayerSDK

// MARK: - ContentTableViewViewModel declaration

class ContentTableViewViewModel {

    // MARK: - Private properties

    private var contents: [Content] {
        didSet {
            contentTableViewCellVMs.removeAll()
            for content in contents {
                contentTableViewCellVMs.append(ContentTableViewCellViewModel(content: content))
            }
        }
    }

    // MARK: - Public properties

    let type: SimpleOTTViewControllerType
    let name: String
    var contentTableViewCellVMs: [ContentTableViewCellViewModel] = [ContentTableViewCellViewModel]()

    // MARK: - Class life cycle

    init(type: SimpleOTTViewControllerType, contents: [Content]) {
        self.type = type
        self.name = type.rawValue
        self.contents = contents

        for content in contents {
            let contentTableViewCellVM = ContentTableViewCellViewModel(content: content)
            contentTableViewCellVM.showOption = type == .offline
            
            /* Check status of all existing caching tasks
                If task status is done assign the task to the view model object
                Remove the task by default as terminating app during caching for example will resulting an error task.
             */
            for task in THEOplayer.cache.tasks {
                for source in task.source.sources {
                    if source.src == URL(string: content.videoSource) {
                        os_log("Found caching task for URL: %@, task status: %@", content.videoSource, task.status.rawValue)
                        switch task.status {
                        case .done:
                            contentTableViewCellVM.cachingTask = task
                        default:
                            task.remove()
                        }
                    }
                }
            }

            contentTableViewCellVMs.append(contentTableViewCellVM)
        }
    }

    // MARK: - Function to update contents to be listed in content table

    func updateContents(contents: [Content]) {
        self.contents = contents
    }
}
