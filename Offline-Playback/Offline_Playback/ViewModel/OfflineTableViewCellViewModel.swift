//
//  OfflineTableViewCellViewModel.swift
//  Offline_Playback
//
//  Copyright © 2025 Dolby OptiView. All rights reserved.
//

import os.log
import THEOplayerSDK

// MARK: - OfflineTableViewCellViewModelDelegate declaration

protocol OfflineTableViewCellViewModelDelegate {
    func onProgressUpdate(percentage: Double)
    func onCacheResumed()
    func onCacheCompleted()
    func onCacheRemoved()
    func onError()
}

// MARK: - OfflineTableViewCellViewModel declaration

class OfflineTableViewCellViewModel {

    // MARK: - Private properties

    // Set the cache default expiration time to 7 days
    private let expiryInMinutes: Int = 60 * 24 * 7
    private let drmLicenseRenewIntervalInDays: Int = 1
    private var drmTimer: Timer?

    // MARK: - Public properties

    var title: String = ""
    var posterImage: UIImage?
    var url: String = ""
    var mimeType: String = ""
    var source: SourceDescription
    var cachingTask: CachingTask? = nil {
        didSet {
            if let task = cachingTask {
                attachCachingEventListeners()
                switch task.status {
                case .idle:
                    // No action for a newly created caching task
                    break
                case .loading:
                    delegate?.onCacheResumed()
                case .error:
                    delegate?.onError()
                case .done:
                    setDrmLicenseRenewTimer()
                    delegate?.onCacheCompleted()
                case .evicted:
                    // Should never happen as an evicted cachingTask will be not set in OfflineViewViewModel
                    break
                @unknown default:
                    print("Unknown task status: \(task.status.rawValue)")
                }
            } else {
                removeCachingEventListeners()
            }
        }
    }
    var taskPercentage: Double {
        if let task = cachingTask, task.percentageCached.isFinite {
            // Get completion rate of the caching task
            return task.percentageCached
        } else {
            return 0.0
        }
    }
    var isCached: Bool {
        return cachingTask?.status ?? .idle == .done
    }
    var isEvicted: Bool {
        return cachingTask?.status ?? .idle == .evicted
    }
    var status: String {
        return cachingTask?.status._rawValue ?? "nil"
    }
    var bytesCached: UInt {
        return cachingTask?.bytesCached ?? 0
    }
    var cachingListener: [String : EventListener] = [:]
    var delegate: OfflineTableViewCellViewModelDelegate? = nil

    // MARK: - Class life cycle

    init(stream: Stream) {
        title = stream.title
        if stream.posterName != "" {
            posterImage = UIImage(named: stream.posterName)
        }
        url = stream.url
        mimeType = stream.mimeType

        // Parse the DRM config
        let drmConfig: DRMConfiguration? = nil
        /*if let drm = stream.drm {
            switch drm.type {
            case .ezDrm:
                drmConfig = EzdrmDRMConfiguration(
                    licenseAcquisitionURL: drm.licenseUrl,
                    certificateURL: drm.certificateUrl
                )
            case .uplynk:
                if drm.licenseUrl == "" {
                    drmConfig = UplynkDRMConfiguration(
                        certificateURL: drm.certificateUrl
                    )
                } else {
                    drmConfig = UplynkDRMConfiguration(
                        licenseAcquisitionURL: drm.licenseUrl,
                        certificateURL: drm.certificateUrl
                    )
                }
            }
        }*/
        let typeSource = TypedSource(
            src: url,
            type: mimeType,
            drm: drmConfig
        )
        source = SourceDescription(
            source: typeSource,
            poster: stream.posterUrl
        )
    }

    deinit {
        // Set caching task to nil and also remove event listener
        cachingTask = nil
        terminateDrmLicenseRenewTimer()
    }

    // MARK: - Cache event listener related functions and closures

    private func attachCachingEventListeners() {
        // Listen to the caching event and store references in dictionary
        self.cachingListener["stateChange"] = self.cachingTask?.addEventListener(type: CachingTaskEventTypes.STATE_CHANGE, listener: { [weak self] event in
            self?.onStateChangeEvent(event: event)
        })
        self.cachingListener["progress"] = self.cachingTask?.addEventListener(type: CachingTaskEventTypes.PROGRESS, listener: { [weak self] event in
            self?.onProgressEvent(event: event)
        })
    }

    private func removeCachingEventListeners() {
        // Remove caching event listeners
        cachingTask?.removeEventListener(type: CachingTaskEventTypes.STATE_CHANGE, listener: cachingListener["stateChange"]!)
        cachingTask?.removeEventListener(type: CachingTaskEventTypes.PROGRESS, listener: cachingListener["progress"]!)

        cachingListener.removeAll()
    }

    private func onStateChangeEvent(event: CacheEvent) {
        print("onStateChangeEvent - status: \(status)")
        if let status = cachingTask?.status {
            switch status {
            case .done:
                delegate?.onCacheCompleted()
            case .error:
                delegate?.onError()
            case .evicted:
                // Currently THEOplayer iOS SDK does not fire the evicted event from the main thread, hence the dispatch to main queue block below
                DispatchQueue.main.async {
                    self.delegate?.onCacheRemoved()
                }
            default:
                // This covers .idle and .loading cases where no action is needed
                break
            }
        }
    }

    private func onProgressEvent(event: CacheEvent) {
        if let _ = cachingTask {
            print("onProgressEvent - title: \(title), status: \(status), percentage: \(String(format:"%.2f", taskPercentage * 100))")
            delegate?.onProgressUpdate(percentage: taskPercentage)
        }
    }

    // MARK: - Caching task functions

    func createCachingTask() {
        let target = Calendar.current.date(byAdding: .minute, value: expiryInMinutes, to: Date())
        // Create caching task with a specific expirationDate
        cachingTask = THEOplayer.cache.createTask(source: source, parameters: CachingParameters.init(expirationDate: target!))
        // Start the new caching task
        cachingTask?.start()
        // Set DRM license renew timer immedately after a new DRM caching task is added
        setDrmLicenseRenewTimer()
        print("createCachingTask - status: \(status), bytesCached: \(bytesCached)")
    }

    func pauseCaching() {
        // Pause the caching task
        cachingTask?.pause()
        print("pauseCaching - status: \(status), bytesCached: \(bytesCached)")
    }

    func resumeCaching() {
        // Use start() to resume the caching task
        cachingTask?.start()
        print("resumeCaching - status: \(status), bytesCached: \(bytesCached)")
    }

    func removeCaching() {
        print("removeCaching - status: \(status), bytesCached: \(bytesCached)")
        // Remove the caching task
        cachingTask?.remove()
        cachingTask = nil
        UserDefaults.standard.removeObject(forKey: url)
        terminateDrmLicenseRenewTimer()
    }

    // MARK: - DRM license renew functions

    func restoreDrmLicenseRenewTimer() {
        setDrmLicenseRenewTimer()
    }

    func terminateDrmLicenseRenewTimer() {
        if drmTimer != nil {
            drmTimer?.invalidate()
            drmTimer = nil
        }
    }

    private func setDrmLicenseRenewTimer() {
        if let task = cachingTask {
            if let drm = source.sources[0].drm {
                // Get the next renew date
                let renewDate = getDrmLicenseRenewDate() {
                    // Renew immediately if it has passed the last recorded renew date
                    task.license.renew(drm)
                }

                // Update the new renew date
                UserDefaults.standard.set(renewDate, forKey: url)

                // Clean old timer just in case
                terminateDrmLicenseRenewTimer()
                drmTimer = Timer(fire: renewDate, interval: 0, repeats: false) { [weak self] timer in
                    // Safety check in case timer is triggered after the object is destory
                    guard let self = self else { return }

                    /* Download DRM license here if needed.
                       For demo purposes, renew with a non-expiring DRM configuration
                    */
                    self.cachingTask?.license.renew(drm)
                    self.setDrmLicenseRenewTimer()
                }
            } else {
                print("No DRM configuration")
            }
        }
    }

    private func getDrmLicenseRenewDate(licenseExpired: (() -> Void)? = nil) -> Date {
        let currentDate = Date()
        // Default target date is current time + drmLicenseRenewIntervalInDays
        var targetDate = Calendar.current.date(byAdding: .day, value: drmLicenseRenewIntervalInDays, to: currentDate)!

        if let recordedDate = UserDefaults.standard.object(forKey: url) as? Date {
            let diff = Calendar.current.dateComponents([.second], from: currentDate, to: recordedDate)
            if diff.second! < 0 {
                // Make license expired callback if recorded date is in the past
                licenseExpired?()
            } else {
                // Recorded date is in future
                if (diff.second! / (60 * 60 * 24)) < drmLicenseRenewIntervalInDays {
                    // If on the same date, reuse the recorded date
                    targetDate = recordedDate
                } else {
                    // Should never happen, use the default target date
                    print("Recorded date is more then \(drmLicenseRenewIntervalInDays) day(s). ")
                }
            }
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        print("DRM license for URL: \(url) will be renewed at: \(formatter.string(from: targetDate))")

        return targetDate
    }
}
