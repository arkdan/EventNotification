//
//  Event.swift
//  EventNotification
//
//  Created by arkdan on 01/04/2019.
//  Copyright © 2019 ark dan. All rights reserved.
//

import Foundation

private let bgQueue = OperationQueue()


/// A type can conform to `Event` without implementing the requirements -
/// `Event` privides default implementation.
/// Notofications are sent on main queue.
public protocol Event {
    static var notificationName: Notification.Name { get }
    static var eventName: String { get }
    static var queue: OperationQueue { get }
}

extension Event {
    public static var eventName: String {
        return String(describing: self)
    }

    public static var notificationName: Notification.Name {
        return Notification.Name(rawValue: eventName)
    }

    public static var queue: OperationQueue {
        return .main
    }

    public func send() {
        let notificationName = type(of: self).notificationName
        let eventname = type(of: self).eventName
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: [eventname: self])
    }
}

/// Notifications will be sent on a background queue.
public protocol BGEvent: Event {}

extension BGEvent {
    public static var queue: OperationQueue {
        return bgQueue
    }
}
