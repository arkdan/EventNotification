//
//  DefaultEventObserver.swift
//  EventNotification
//
//  Created by arkdan on 01/04/2019.
//  Copyright © 2019 ark dan. All rights reserved.
//

import Foundation

/// `DefaultEventObserver` privides default `eventToken` requirement.
///
/// This is useful when conforming class is does not intent to unsubscribe from
/// receiving notification events at any point of their lifetime.
/// If, however, a conforming class **needs to unsubscribe**, they shoutl conform to
/// `EventObserver` instead, and implement `var eventToken: EventToken { get }` requirement.
public protocol DefaultEventObserver: EventObserver {}

extension DefaultEventObserver {
    public var eventToken: EventToken {
        return .sharedNil
    }
}

extension EventToken {

    fileprivate static let sharedNil: EventToken = {
        let t = EventToken()
        t.tokens = nil
        return t
    }()
}
