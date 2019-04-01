//
//  KeyboardEvent.swift
//  EventNotification
//
//  Created by mac on 11/10/17.
//  Copyright © 2017 arkdan. All rights reserved.
//

import UIKit

public struct KeyboardDidShowEvent: Event {
    public static var notificationName: Notification.Name {
        return .UIKeyboardDidShow
    }
}

public struct KeyboardWillShowEvent: Event {
    public static var notificationName: Notification.Name {
        return .UIKeyboardWillShow
    }
}

public struct KeyboardWillHideEvent: Event {
    public static var notificationName: Notification.Name {
        return .UIKeyboardWillHide
    }
}

public struct KeyboardWillChangeFrameEvent: Event {
    public static var notificationName: Notification.Name {
        return .UIKeyboardWillChangeFrame
    }
}

public protocol KeyboardEventObserver: EventObserver {}

extension KeyboardEventObserver {

    public func onKeyboardAppear(handler: @escaping (CGRect) -> Void) {
        handleEventNotification(KeyboardDidShowEvent.self) { notification in
            guard let value = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
                return
            }
            let keyboardFrame: CGRect = value.cgRectValue
            handler(keyboardFrame)
        }
    }

    public func onKeyboardWillAppear(handler: @escaping (CGRect) -> Void) {
        handleEventNotification(KeyboardWillShowEvent.self) { notification in
            guard let value = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
                return
            }
            let keyboardFrame: CGRect = value.cgRectValue
            handler(keyboardFrame)
        }
    }

    public func onKeyboardDissappear(handler: @escaping () -> Void) {
        handleEventNotification(KeyboardWillHideEvent.self) { _ in
            handler()
        }
    }

    public func onKeyboardFrameChanged(handler: @escaping (CGRect) -> Void) {
        handleEventNotification(KeyboardWillChangeFrameEvent.self) { notification in
            guard let value = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
                return
            }
            let keyboardFrame: CGRect = value.cgRectValue
            handler(keyboardFrame)
        }
    }

    public func unsubscribeKeyboardAppear() {
        unsubscribe(KeyboardDidShowEvent.self)
    }
    public func unsubscribeKeyboardDisappear() {
        unsubscribe(KeyboardWillHideEvent.self)
    }
}
