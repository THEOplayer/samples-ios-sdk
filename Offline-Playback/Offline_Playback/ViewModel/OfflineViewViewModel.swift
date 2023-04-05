//
//  OfflineViewViewModel.swift
//  Offline_Playback
//
//  Copyright © 2019 THEOPlayer. All rights reserved.
//

import os.log
import THEOplayerSDK

// MARK: - OfflineViewViewModel declaration

class OfflineViewViewModel {

    // MARK: - Private property

    // Static Stream array declaration used in this app
    private let streams: [Stream] = [
        Stream(title: "Big Buck Bunny",
               posterName: "big-buck-bunny",
               posterUrl: "https://cdn.theoplayer.com/video/big_buck_bunny/poster.jpg",
               url: "https://cdn.theoplayer.com/video/big_buck_bunny/big_buck_bunny_metadata.m3u8",
               mimeType: "application/x-mpegURL",
               drm: nil),
        Stream(title: "Sintel",
               posterName: "sintel",
               posterUrl: "https://cdn.theoplayer.com/video/sintel/poster.jpg",
               url: "https://cdn.theoplayer.com/video/sintel/nosubs.m3u8",
               mimeType: "application/x-mpegURL",
               drm: nil),
        Stream(title: "Tears of Steel",
               posterName: "tears-of-steel",
               posterUrl: "https://cdn.theoplayer.com/video/tears_of_steel/poster.jpg",
               url: "https://cdn.theoplayer.com/video/tears_of_steel/index.m3u8",
               mimeType: "application/x-mpegURL",
               drm: nil),
        Stream(title: "Elephants Dream",
               posterName: "elephants-dream",
               posterUrl: "https://cdn.theoplayer.com/video/elephants-dream/playlist.png",
               url: "https://cdn.theoplayer.com/video/elephants-dream/playlist.m3u8",
               mimeType: "application/x-mpegURL",
               drm: nil),
        Stream(title: "Apple FairPlay",
               posterName: "placeholder",
               posterUrl: "",
               url: "https://fps.ezdrm.com/demo/video/ezdrm.m3u8",
               mimeType: "application/x-mpegURL",
               drm: Drm(
                    type: .ezDrm,
                    licenseUrl: "https://fps.ezdrm.com/api/licenses/09cc0377-6dd4-40cb-b09d-b582236e70fe",
                    certificateUrl: "https://fps.ezdrm.com/demo/video/eleisure.cer")
                )
    ]

    // MARK: - Public property

    var cellViewModels: [OfflineTableViewCellViewModel] = [OfflineTableViewCellViewModel]()

    // MARK: - Class life cycle

    init() {
        // Loop through the streams array and instantiate OfflineTableViewCellViewModel objects
        for stream in streams {
            let offlineTableViewCellViewModel = OfflineTableViewCellViewModel(stream: stream)

            /* Check status of all existing caching tasks
                If task status is done assign the task to the view model object
                Remove the task by default as terminating app during caching for example will resulting an error task.
             */
            for task in THEOplayer.cache.tasks {
                for source in task.source.sources {
                    if source.src == URL(string: stream.url) {
                        os_log("Found caching task for URL: %@, task status: %@", stream.url, task.status._rawValue)
                        switch task.status {
                        case .done:
                            offlineTableViewCellViewModel.cachingTask = task
                        default:
                            // Remove caching task
                            task.remove()
                            if let _ = source.drm {
                                // Remove DRM renew record
                                UserDefaults.standard.removeObject(forKey: stream.url)
                            }
                        }
                    }
                }
            }

            cellViewModels.append(offlineTableViewCellViewModel)
        }
    }

    func restoreDrmLicenseRenewTimers() {
        for cellViewModel in cellViewModels {
            cellViewModel.restoreDrmLicenseRenewTimer()
        }
    }

    func terminateDrmLicenseRenewTimers() {
        for cellViewModel in cellViewModels {
            cellViewModel.terminateDrmLicenseRenewTimer()
        }
    }
}
