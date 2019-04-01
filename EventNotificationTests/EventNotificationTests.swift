//
//  EventNotificationTests.swift
//  EventNotificationTests
//
//  Created by arkdan on 15/04/2018.
//  Copyright © 2018 ark dan. All rights reserved.
//

import XCTest
@testable import EventNotification

struct A: Event {
    let string: String
}

class B: BGEvent {
    let string: String
    init(string: String) {
        self.string = string
    }
}


class TEventObserver: EventObserver {
    let eventToken = EventToken()

    var receivedA: ((String) -> Void)?
    var receivedB: ((String) -> Void)?

    var onDeinit: (() -> Void)?

    init() {
        handleEvent(A.self) { [weak self] (eventA) in
            self?.receivedA?(eventA.string)
        }
        handleEvent(B.self) { [weak self] (eventB) in
            self?.receivedB?(eventB.string)
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

        let event = A(string: testString)

        observer.receivedA = { string in
            XCTAssert(string == testString)
            exp.fulfill()
        }
        observer.receivedB = { string in
            XCTFail()
        }

        event.send()
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testBGEventReceived() {
        let observer = TEventObserver()
        let exp = expectation(description: #function)

        let testString = #function

        let event = B(string: testString)

        observer.receivedA = { string in
            XCTFail()
        }

        observer.receivedB = { string in
            XCTAssert(string == testString)
            exp.fulfill()
        }

        event.send()
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testUnsubscribeOne() {
        let exp = expectation(description: #function)

        let observer = TEventObserver()

        let eventA = A(string: "")
        let eventB = B(string: "")

        observer.receivedA = { string in
            XCTFail()
        }

        observer.receivedB = { string in
            exp.fulfill()
        }

        observer.unsubscribe(A.self)

        eventA.send()
        eventB.send()
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testUnsubscribeAll() {
        let exp = expectation(description: #function)

        let observer = TEventObserver()

        let eventA = A(string: "")
        let eventB = B(string: "")

        observer.receivedA = { string in
            XCTFail()
        }

        observer.receivedB = { string in
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

        let eventA = A(string: "")
        let eventB = B(string: "")

        observer!.receivedA = { string in
            XCTFail()
        }

        observer!.receivedB = { string in
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
