//
//  EventNotificationTests.swift
//  EventNotificationTests
//
//  Created by arkdan on 15/04/2018.
//  Copyright © 2018 ark dan. All rights reserved.
//

import XCTest
@testable import EventNotification

class AAEvent: UIEventt {
    let string: String
    init(string: String) {
        self.string = string
    }
}

class BBEvent: BGEvent {
    let string: String
    init(string: String) {
        self.string = string
    }
}


class TEventObserver: EventObserver {
    let eventToken = EventToken()

    var receivedAA: ((String) -> Void)?
    var receivedBB: ((String) -> Void)?

    var onDeinit: (() -> Void)?

    init() {
        handleEvent(AAEvent.self) { [weak self] (aaEvent) in
            self?.receivedAA?(aaEvent.string)
        }
        handleEvent(BBEvent.self) { [weak self] (bbEvent) in
            self?.receivedBB?(bbEvent.string)
        }
    }

    deinit {
        onDeinit?()
    }

}

class EventNotificationTests: XCTestCase {

    func testUIEventReceived() {
        let exp = expectation(description: #function)
        let observer = TEventObserver()

        let testString = #function

        let event = AAEvent(string: testString)

        observer.receivedAA = { string in
            XCTAssert(string == testString)
            exp.fulfill()
        }
        observer.receivedBB = { string in
            XCTFail()
        }

        event.send()
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testBGEventReceived() {
        let observer = TEventObserver()
        let exp = expectation(description: #function)

        let testString = #function

        let event = BBEvent(string: testString)

        observer.receivedAA = { string in
            XCTFail()
        }

        observer.receivedBB = { string in
            XCTAssert(string == testString)
            exp.fulfill()
        }

        event.send()
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testUnsubscribeOne() {
        let exp = expectation(description: #function)

        let observer = TEventObserver()

        let eventA = AAEvent(string: "")
        let eventB = BBEvent(string: "")

        observer.receivedAA = { string in
            XCTFail()
        }

        observer.receivedBB = { string in
            exp.fulfill()
        }

        observer.unsubscribe(AAEvent.self)

        eventA.send()
        eventB.send()
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testUnsubscribeAll() {
        let exp = expectation(description: #function)

        let observer = TEventObserver()

        let eventA = AAEvent(string: "")
        let eventB = BBEvent(string: "")

        observer.receivedAA = { string in
            XCTFail()
        }

        observer.receivedBB = { string in
            XCTFail()
        }

        observer.unsubscribe()
        eventA.send()
        eventB.send()
        DispatchQueue.global().delayed(0.1) {
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.2, handler: nil)
    }

    func testRetainCycle() {
        let exp = expectation(description: #function)

        var observer: TEventObserver? = TEventObserver()

        observer!.onDeinit = {
            exp.fulfill()
        }

        observer = nil
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testUnsubscribeImplicit() {
        let exp = expectation(description: #function)

        var observer: TEventObserver? = TEventObserver()

        let eventA = AAEvent(string: "")
        let eventB = BBEvent(string: "")

        observer!.receivedAA = { string in
            XCTFail()
        }

        observer!.receivedBB = { string in
            XCTFail()
        }

        observer!.onDeinit = {
            // give some time for possible notification delivery (which should NOT happen)
            delay(0.1, queue: .global()) {
                exp.fulfill()
            }
        }

        observer = nil
        eventA.send()
        eventB.send()
        waitForExpectations(timeout: 0.2, handler: nil)
    }

}

extension DispatchTimeInterval {
    public static func withSeconds(_ seconds: Double) -> DispatchTimeInterval {
        return DispatchTimeInterval.nanoseconds(Int(seconds * 1e9))
    }
}

extension DispatchTime {
    static public func fromNow(seconds: Double) -> DispatchTime {
        return DispatchTime.now() + DispatchTimeInterval.withSeconds(seconds)
    }
}

public func delay(_ time: Double, queue: DispatchQueue = DispatchQueue.main, block: @escaping () -> ()) {
    queue.asyncAfter(deadline: DispatchTime.fromNow(seconds: time), execute: block)
}

extension DispatchQueue {
    public func delayed(_ time: Double, block: @escaping () -> ()) {
        asyncAfter(deadline: DispatchTime.fromNow(seconds: time), execute: block)
    }
}
