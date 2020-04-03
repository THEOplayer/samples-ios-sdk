# THEOplayer How To's - Offline Stream Caching

This guide is going to cover how to use THEOplayer Cache API to download clear and DRM protected stream for offline playback.

## Table of Contents

* [Overview]
* [Initialising a Caching Task]
* [Starting a Caching Task]
* [Pausing a Caching Task]
* [Resuming a Caching Task]
* [Removing a Caching task]
* [Inspecting which Caching Tasks are Active]
* [Inspecting the Completion Rate of a Caching Task]
* [Caching a DRM Stream]
* [Renewing DRM license]
* [Playing Cached Stream]
* [Summary]

## Overview

An overview of changes made to [THEO Basic Playback] are highlighted below, this helps to clarify the logic and data flow behind this reference app.

* MVVM (Model-View-ViewModel) architectural was used in this reference app to separate business logic from user interface code.
* `PlayerViewController` as the Navigation Controller's root view controller has been replaced by `OfflineViewController`.
* `OfflineViewController` has a `UITableVIew` that presents `Stream` objects as `OfflineTableViewCell`.
* `OfflineTableViewCell` has download, pause, resume and delete buttons for user to interact with.
* Each `OfflineTableViewCell` will be assigned a `OfflineTableViewCellViewModel` object, which is instantiated with a `Stream` object and invokes THEOplayer Caching API directly.
* The `OfflineTableViewCellViewModelDelegate` protocol is defined for `OfflineTableViewCellViewModel`to notify its delegate (`OfflineTableViewCell`).
* `OfflineTableViewCellViewModel` will create `SourceDescription` object which will be passed to the THEOplayer Caching API and to `PlayerViewController` through `OfflineViewController` when user tap on a `OfflineTableViewCell`.

## Initialising a Caching Task

THEOplayer Cache API can be accessed using the static `Cache` object from `THEOplayer`. To create a `CachingTask` object, use the `createTask()` API which requires a `SourceDescription` and an optional `CachingParameters`. Expiration date and desired bandwidth of the to-be-created `CachingTask` can be set via `CachingParameters`.

```swift
class OfflineTableViewCellViewModel {

    ...

    private let expiryInMinutes: Int = 60 * 24 * 7

    ...

    var cachingTask: CachingTask? = nil {
        didSet {
            if let task = cachingTask {
                attachCachingEventListeners()

                ...

            } else {
                removeCachingEventListeners()
            }
        }
    }

    ...

    func createCachingTask() {
        let target = Calendar.current.date(byAdding: .minute, value: expiryInMinutes, to: Date())

        cachingTask = THEOplayer.cache.createTask(source: source, parameters: CachingParameters.init(expirationDate: target!))

        ...
    }

    ...
}
```

On succeeded, a `CachingTask` object will be returned. Listeners to `CachingTaskEventTypes.STATE_CHANGE` and `CachingTaskEventTypes.PROGRESS` events can be added to monitor changes to caching state and progress respectively.

```swift
class OfflineTableViewCellViewModel {

    ...

    var taskPercentage: Double {
        if let task = cachingTask, task.percentageCached.isFinite {
            return task.percentageCached
        } else {
            return 0.0
        }
    }

    ...

    private func attachCachingEventListeners() {
        cachingListener["stateChange"] = cachingTask?.addEventListener(type: CachingTaskEventTypes.STATE_CHANGE, listener: onStateChangeEvent)
        cachingListener["progress"] = cachingTask?.addEventListener(type: CachingTaskEventTypes.PROGRESS, listener: onProgressEvent)
    }

    private func removeCachingEventListeners() {
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
                DispatchQueue.main.async {
                    self.delegate?.onCacheRemoved()
                }
            default:
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

    ...
}
```

The new `CachingTask` task will be in the `.idle` state. To start caching see [Starting a Caching Task] or to [Removing a caching task] remove it.

## Starting a Caching Task

Simply call the `start()` function with the `CachingTask` object to start caching.

```swift
class OfflineTableViewCellViewModel {

    ...

    func createCachingTask() {

        ...

        cachingTask = THEOplayer.cache.createTask(source: source, parameters: CachingParameters.init(expirationDate: target!))
        cachingTask.start()
    }

    ...
}
```

The `status` of the `CachingTask` will be switched  to `.loading` and remain as such until the caching stops (done or error). `CachingTaskEventTypes.PROGRESS` event will be fired whenever completion percentage changes.

When caching is completed, the `status` will set to `.done` until the cache expires in which case the `status` should move to `.evicted`.

## Pausing a Caching Task

Use the `pause()` function to pause the `CachingTask`.

```swift
class OfflineTableViewCellViewModel {

    ...

    func pauseCaching() {
        cachingTask?.pause()
        os_log("pauseCaching: status : %@ bytesCached: %d", cachingTask?.status.rawValue ?? "nil", cachingTask?.bytesCached ?? 0)
    }

    ...

}
```

## Resuming a Caching Task

The `start()` function can be used to resume a paused `CachingTask`.

```swift
class OfflineTableViewCellViewModel {

    ...

    func resumeCaching() {
        cachingTask?.start()
        os_log("resumeCaching: status : %@ bytesCached: %d", cachingTask?.status.rawValue ?? "nil", cachingTask?.bytesCached ?? 0)
    }

    ...

}
```

## Removing a Caching task

To remove a `CachingTask`, use the `remove()` function.

```swift
class OfflineTableViewCellViewModel {

    ...

    func removeCaching() {
        os_log("removeCaching: status : %@ bytesCached: %d", cachingTask?.status.rawValue ?? "nil", cachingTask?.bytesCached ?? 0)
        cachingTask?.remove()
        cachingTask = nil

        ...
    }

    ...

}
```

## Inspecting which Caching Tasks are Active

The `Cache` object holds an array of `CachingTask` regardless of their state that can be used to identify active tasks. As described in [Starting a Caching Task], ongoing `CachingTask` will remain in `.loading` state. For example:

```swift
for task in THEOplayer.cache.tasks {
    if task.status == .loading {
        // Active CachingTask
    }
}
```

## Inspecting the Completion Rate of a Caching Task

Th completion rate of `CachingTask` can be queried via the `percentageCached` property as follows.

```swift
class OfflineTableViewCellViewModel {

    ...

    var taskPercentage: Double {
        if let task = cachingTask, task.percentageCached.isFinite {
            return task.percentageCached
        } else {
            return 0.0
        }
    }

    ...
}
```

As described previously, `CachingTask` progress can also be monitored by listening to the `CachingTaskEventTypes.PROGRESS` event. Please visit [Initialising a Caching Task] for code snippet.

## Caching a DRM Stream

To cache a DRM stream, a `SourceDescription` with the appropriate `DRMConfiguration` shall be passed to the `createTask()` function (see [Initialising a Caching Task]). The rest of the procedure will be the same once the DRM `CachingTask` is created.

## Renewing DRM license

It might be required to renew the DRM license for a DRM `CachingTask` and it can be done via the `renew()` function of the `license` object in `CachingTask`. The `renew()` function expects an updated `DRMConfiguration` containing the up-to-date license. The code snippet below reuses the existing `DRMConfiguration` from `SourceDescription` for demonstration purpose.

```swift
if let drm = source.sources[0].drm {
    cachingTask.license.renew(drm)
}
```

The following points below summarised how auto license renewal can be implemented:

* Record DRM license expiration date.
* Use DRM license expiration date to create timer.
* When the timer is due, fetch new DRM license and invokes the `renew()` function as above.
* Remove all license renewal timers when application goes to background.
* On application launch or resume to foreground, loop through the `CachingTask` array held by the `Cache` object, filter for completed DRM `CachingTask` and restore each license renewal timer.

Example implementation can be found across [AppDelegate.swift],[OfflineViewViewModel.swift] and [OfflineTableViewCellViewModel.swift].

## Playing Cached Stream

Simply pass the same `SourceDescription` to `THEOplayer` instance to playback the cached content. THEOplayer SDK will check against the `CachingTask` array it has internally to determine if cache exists for the provided `SourceDescription`.

## Summary

This guide covered the usage of THEOplayer Cache API and how to download clear and DRM protected stream for offline playback.

For more guides about THEOplayer please visit [THEO Docs] portal.

[//]: # (Sections reference)
[Overview]: #Overview
[Initialising a Caching Task]: #Initialising-a-Caching-Task
[Starting a Caching Task]: #Starting-a-Caching-Task
[Pausing a Caching Task]: #Pausing-a-Caching-Task
[Resuming a Caching Task]: #Resuming-a-Caching-Task
[Removing a Caching task]: #Removing-a-Caching-task
[Inspecting which Caching Tasks are Active]: #Inspecting-which-Caching-Tasks-are-Active
[Inspecting the Completion Rate of a Caching Task]: #Inspecting-the-Completion-Rate-of-a-Caching-Task
[Caching a DRM Stream]: #Caching-a-DRM-Stream
[Renewing DRM license]: #Renewing-DRM-license
[Playing Cached Stream]: #Playing-Cached-Stream
[Summary]: #Summary

[//]: # (Links and Guides reference)
[THEO Basic Playback]: ../Basic-Playback
[THEO Docs]: https://docs.portal.theoplayer.com/

[//]: # (Project files reference)
[AppDelegate.swift]: ../../Offline_Playback/AppDelegate.swift
[OfflineViewViewModel.swift]: ../../Offline_Playback/ViewModel/OfflineViewViewModel.swift
[OfflineTableViewCellViewModel.swift]: ../../Offline_Playback/ViewModel/OfflineTableViewCellViewModel.swift
