//
//  OfflineTableViewCellViewModel.swift
//  Offline_Playback
//
//  Copyright © 2019 THEOPlayer. All rights reserved.
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

    // Set cache default expiry time to 7 days
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
                    // No action for newly created caching task
                    break
                case .loading:
                    delegate?.onCacheResumed()
                case .error:
                    delegate?.onError()
                case .done:
                    setDrmLicenseRenewTimer()
                    delegate?.onCacheCompleted()
                case .evicted:
                    // Should never happen as evicated cachingTask will be not set in OfflineViewViewModel
                    break
                @unknown default:
                    os_log("Unkown task status: %@", task.status.rawValue)
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

        // Parse DRM config
        var drmConfig: DRMConfiguration? = nil
        if let drm = stream.drm {
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
        }
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
        // Set caching task to nil will also remove event listener
        cachingTask = nil
        terminateDrmLicenseRenewTimer()
    }

    // MARK: - Cache event listener related functions and closures

    private func attachCachingEventListeners() {
        // Listen to caching event and store references in dictionary
        cachingListener["stateChange"] = cachingTask?.addEventListener(type: CachingTaskEventTypes.STATE_CHANGE, listener: onStateChangeEvent)
        cachingListener["progress"] = cachingTask?.addEventListener(type: CachingTaskEventTypes.PROGRESS, listener: onProgressEvent)
    }

    private func removeCachingEventListeners() {
        // Remove caching event listeners
        cachingTask?.removeEventListener(type: CachingTaskEventTypes.STATE_CHANGE, listener: cachingListener["stateChange"]!)
        cachingTask?.removeEventListener(type: CachingTaskEventTypes.PROGRESS, listener: cachingListener["progress"]!)

        cachingListener.removeAll()
    }

    private func onStateChangeEvent(event: CacheEvent) {
        os_log("onStateChangeEvent status: %@", self.cachingTask?.status.rawValue ?? "")
        if let status = cachingTask?.status {
            switch status {
            case .done:
                delegate?.onCacheCompleted()
            case .error:
                delegate?.onError()
            case .evicted:
                // Currently THEO SDK is not firing evicted event from the main thread hence the dispatch to main queue block below
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
        if let task = cachingTask {
            os_log("title: %@, status: %@, percentage: %.2f", title,  task.status.rawValue, taskPercentage * 100)
            delegate?.onProgressUpdate(percentage: taskPercentage)
        }
    }

    // MARK: - Caching task functions

    func createCachingTask() {
        let target = Calendar.current.date(byAdding: .minute, value: expiryInMinutes, to: Date())
        // Create caching task with specific expirationDate
        cachingTask = THEOplayer.cache.createTask(source: source, parameters: CachingParameters.init(expirationDate: target!))
        // Start the new caching task
        cachingTask?.start()
        // Set DRM license renew timer immedately after new DRM caching task is added
        setDrmLicenseRenewTimer()
        os_log("createCachingTask: status : %@ bytesCached: %d", cachingTask?.status.rawValue ?? "nil", cachingTask?.bytesCached ?? 0)
    }

    func pauseCaching() {
        // Pause caching task
        cachingTask?.pause()
        os_log("pauseCaching: status : %@ bytesCached: %d", cachingTask?.status.rawValue ?? "nil", cachingTask?.bytesCached ?? 0)
    }

    func resumeCaching() {
        // Use start() to resume caching task
        cachingTask?.start()
        os_log("resumeCaching: status : %@ bytesCached: %d", cachingTask?.status.rawValue ?? "nil", cachingTask?.bytesCached ?? 0)
    }

    func removeCaching() {
        os_log("removeCaching: status : %@ bytesCached: %d", cachingTask?.status.rawValue ?? "nil", cachingTask?.bytesCached ?? 0)
        // Remove caching task
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
                // Get next renew date
                let renewDate = getDrmLicenseRenewDate() {
                    // Renew immediately if it has passed last recorded renew date
                    task.license.renew(drm)
                }

                // Update new renew date
                UserDefaults.standard.set(renewDate, forKey: url)

                // Clean old timer just in case
                terminateDrmLicenseRenewTimer()
                drmTimer = Timer(fire: renewDate, interval: 0, repeats: false) { [weak self] timer in
                    // Safety check in case timer is triggered after the object is destory
                    guard let self = self else { return }

                    /* Download DRM license here if needed.
                       For demo purpose, renew with DRM configuration which does not expire
                    */
                    self.cachingTask?.license.renew(drm)
                    self.setDrmLicenseRenewTimer()
                }
            } else {
                os_log("No DRM configuration")
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
                    // If on the same date, reuse recorded date
                    targetDate = recordedDate
                } else {
                    // Should never happen, use default target date
                    os_log("Recorded date is more then %d day(s). ", drmLicenseRenewIntervalInDays)
                }
            }
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        os_log("DRM license for URL: %@ will be renewed at: %@", url, formatter.string(from: targetDate))

        return targetDate
    }
}
