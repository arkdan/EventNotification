//
//  KeyboardEvent.swift
//  EventNotification
//
//  Created by mac on 11/10/17.
//  Copyright © 2017 arkdan. All rights reserved.
//

import UIKit

public struct KeyboardDidShowEvent: UIEventt {
    public static var notificationName: Notification.Name {
        return .UIKeyboardDidShow
    }
}

public struct KeyboardWillShowEvent: UIEventt {
    public static var notificationName: Notification.Name {
        return .UIKeyboardWillShow
    }
}

public struct KeyboardWillHideEvent: UIEventt {
    public static var notificationName: Notification.Name {
        return .UIKeyboardWillHide
    }
}

public protocol KeyboardEventObserver: EventObserver {}

extension KeyboardEventObserver {

    public func onKeyboardAppear(handler: @escaping (CGRect) -> Void) {
        handleEventNotification(KeyboardDidShowEvent.self) { notification in
            let value: NSValue = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
            let keyboardFrame: CGRect = value.cgRectValue
            handler(keyboardFrame)
        }
    }

    public func onKeyboardWillAppear(handler: @escaping (CGRect) -> Void) {
        handleEventNotification(KeyboardWillShowEvent.self) { notification in
            let value: NSValue = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
            let keyboardFrame: CGRect = value.cgRectValue
            handler(keyboardFrame)
        }
    }

    public func onKeyboardDissappear(handler: @escaping () -> Void) {
        handleEventNotification(KeyboardWillHideEvent.self) { _ in
            handler()
        }
    }

    public func unsubscribeKeyboardAppear() {
        unsubscribe(KeyboardDidShowEvent.self)
    }
    public func unsubscribeKeyboardDisappear() {
        unsubscribe(KeyboardWillHideEvent.self)
    }
}
