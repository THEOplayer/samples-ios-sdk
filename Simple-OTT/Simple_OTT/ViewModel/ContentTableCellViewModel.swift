//
//  ContentTableViewCellViewModel.swift
//  Simple_OTT
//
//  Copyright © 2020 THEOPlayer. All rights reserved.
//

import os.log
import THEOplayerSDK

// MARK: - ContentTableViewCellViewModelDelegate declaration

protocol ContentTableViewCellViewModelDelegate {
    func onProgressUpdate(percentage: Double)
    func onCachePaused()
    func onCacheResumed()
    func onCacheCompleted()
    func onCacheRemoved()
    func onError()
}

// MARK: - ContentTableViewCellViewModel declaration

class ContentTableViewCellViewModel {

    // MARK: - Private properties

    // Set cache default expiry time to 7 days
    private let expiryInMinutes: Int = 60 * 24 * 7

    // MARK: - Public properties

    var title: String = ""
    var desc: String = ""
    var posterImage: UIImage?
    var url: String = ""
    var mimeType: String = ""
    var showOption: Bool = false
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
    var isDownloadAllowed: Bool {
        return  NetworkManager.shared.wifiOnlyDownload ? NetworkManager.shared.isWifiConnected : true
    }
    var cachingListener: [String : EventListener] = [:]
    var delegate: ContentTableViewCellViewModelDelegate? = nil

    // MARK: - Class life cycle

    init(content: Content) {
        title = content.name
        desc = content.description
        if content.imageUrl != "" {
            posterImage = UIImage(named: content.imageUrl)
        }
        url = content.videoSource
        mimeType = "application/x-mpegURL"

        let typeSource = TypedSource(
            src: url,
            type: mimeType
        )
        source = SourceDescription(
            source: typeSource
        )
        NetworkManager.shared.addDelegate(delegate: self)
    }

    deinit {
        // Set caching task to nil will also remove event listener
        cachingTask = nil
        NetworkManager.shared.removeDelegate(delegate: self)
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
    }
}

// MARK: - NetworkManagerDelegate

extension ContentTableViewCellViewModel: NetworkManagerDelegate {
    func onWifiConnectionChanged(isConnected: Bool) {
        if let task = cachingTask, (task.status == .idle || task.status == .loading) {
            if isConnected {
                delegate?.onCacheResumed()
            } else {
                if NetworkManager.shared.wifiOnlyDownload {
                    // Pause download if wifi is not connection and the wifiOnlyDownload is set.
                    delegate?.onCachePaused()
                    pauseCaching()
                }
            }
        }
    }
}
