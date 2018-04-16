//
//  Event.swift
//  EventNotification
//
//  Created by mac on 11/9/17.
//  Copyright © 2017 arkdan. All rights reserved.
//

import Foundation

private let bgQueue = OperationQueue()

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

    public func send() {
        let notificationName = type(of: self).notificationName
        let eventname = type(of: self).eventName
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: [eventname: self])
    }
}

public protocol UIEventt: Event {} // just to distinguish from UIKit
public protocol BGEvent: Event {}

extension UIEventt {
    public static var queue: OperationQueue {
        return .main
    }
}

extension BGEvent {
    public static var queue: OperationQueue {
        return bgQueue
    }
}

public final class EventToken {
    fileprivate var tokens: [String: NSObjectProtocol]? = [:]
    fileprivate static let sharedNil: EventToken = {
        let t = EventToken()
        t.tokens = nil
        return t
    }()
}

public protocol EventObserver: class {
    var eventToken: EventToken { get }
}

extension EventObserver {
    public var eventToken: EventToken {
        return .sharedNil
    }
}

extension EventObserver {

    public func handleEvent<E: Event>(_ type: E.Type, handler: @escaping (E) -> Void) {
        let block: (Notification) -> Void = { notification in
            guard let event = notification.userInfo?[type.eventName] as? E else {
                print("Something wrong with event \(type.eventName)")
                return
            }
            handler(event)
        }
        let token = NotificationCenter.default.addObserver(forName: type.notificationName,
                                                           object: nil,
                                                           queue: type.queue,
                                                           using: block)
        add(token: token, event: type)
    }

    public func handleEventNotification<E: Event>(_ type: E.Type, handler: @escaping (Notification) -> Void) {
        let token = NotificationCenter.default.addObserver(forName: type.notificationName,
                                                           object: nil,
                                                           queue: type.queue,
                                                           using: handler)
        add(token: token, event: type)
    }

    private func add(token: NSObjectProtocol, event: Event.Type) {
        eventToken.tokens?[event.eventName] = token
    }

    public func unsubscribe<E: Event>(_ type: E.Type) {
        if let token = eventToken.tokens?[type.eventName] {
            NotificationCenter.default.removeObserver(token)
        }
        eventToken.tokens?[type.eventName] = nil
    }

    public func unsubscribe() {
        eventToken.tokens?.forEach { _, token in
            NotificationCenter.default.removeObserver(token)
        }
        eventToken.tokens?.removeAll()
    }
}

