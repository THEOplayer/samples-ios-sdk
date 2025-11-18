//
//  OfflineViewViewModel.swift
//  Offline_Playback
//
//  Copyright © 2025 Dolby OptiView. All rights reserved.
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
        Stream(title: "Apple FairPlay (Axinom)",
               posterName: "sintel",
               posterUrl: "https://cdn.theoplayer.com/video/sintel/poster.jpg",
               url: "https://media.axprod.net/VTB/DrmQuickStart/AxinomDemoVideo-SingleKey/Encrypted_Cbcs/Manifest.m3u8",
               mimeType: "application/x-mpegURL",
               drm: Drm(
                    customIntegrationId: AxinomDRMIntegration.integrationID,
                    licenseAcquisitionURL: "https://drm-fairplay-licensing.axtest.net/AcquireLicense",
                    certificateURL: "https://vtb.axinom.com/FPScert/fairplay.cer",
                    integrationParameters: ["token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ2ZXJzaW9uIjoxLCJjb21fa2V5X2lkIjoiNjllNTQwODgtZTllMC00NTMwLThjMWEtMWViNmRjZDBkMTRlIiwibWVzc2FnZSI6eyJ2ZXJzaW9uIjoyLCJ0eXBlIjoiZW50aXRsZW1lbnRfbWVzc2FnZSIsImxpY2Vuc2UiOnsiYWxsb3dfcGVyc2lzdGVuY2UiOnRydWV9LCJjb250ZW50X2tleXNfc291cmNlIjp7ImlubGluZSI6W3siaWQiOiIyMTFhYzFkYy1jOGEyLTQ1NzUtYmFmNy1mYTRiYTU2YzM4YWMiLCJ1c2FnZV9wb2xpY3kiOiJUaGVPbmVQb2xpY3kifV19LCJjb250ZW50X2tleV91c2FnZV9wb2xpY2llcyI6W3sibmFtZSI6IlRoZU9uZVBvbGljeSIsInBsYXlyZWFkeSI6eyJwbGF5X2VuYWJsZXJzIjpbIjc4NjYyN0Q4LUMyQTYtNDRCRS04Rjg4LTA4QUUyNTVCMDFBNyJdfX1dfX0.D9FM9sbTFxBmcCOC8yMHrEtTwm0zy6ejZUCrlJbHz_U"])
                )
    ]

    // MARK: - Public property

    var cellViewModels: [OfflineTableViewCellViewModel] = [OfflineTableViewCellViewModel]()

    // MARK: - Class life cycle

    init() {
        // Loop through the streams array and instantiate OfflineTableViewCellViewModel objects
        for stream in streams {
            let offlineTableViewCellViewModel = OfflineTableViewCellViewModel(stream: stream)

            /* Check the status of all existing caching tasks
                If the task status is done, assign the task to the view model object
                Remove the task by default as terminating app during caching for example will result in an error task.
             */
            for task in THEOplayer.cache.tasks {
                for source in task.source.sources {
                    if source.src == stream.url {
                        print("Found caching task for URL: \(stream.url), task status: \(task.status._rawValue)")
                        switch task.status {
                        case .done:
                            offlineTableViewCellViewModel.cachingTask = task
                        default:
                            // Remove the caching task
                            task.remove()
                            if let _ = source.drm {
                                // Remove the DRM renew record
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
