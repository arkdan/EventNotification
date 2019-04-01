//
//  DefaultEventObserverTests.swift
//  EventNotificationTests
//
//  Created by arkdan on 01/04/2019.
//  Copyright © 2019 ark dan. All rights reserved.
//

import XCTest
@testable import EventNotification

class DefEventObserver: DefaultEventObserver {

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

class DefaultEventObserverTests: XCTestCase {

    func testUIEventReceived() {
        let exp = expectation(description: #function)
        let observer = DefEventObserver()

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
        let observer = DefEventObserver()
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

    func testRetainCycle() {
        let exp = expectation(description: #function)

        var observer: DefEventObserver? = DefEventObserver()

        observer!.onDeinit = {
            exp.fulfill()
        }

        observer = nil
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testUnsubscribeImplicit() {
        let exp = expectation(description: #function)

        var observer: DefEventObserver? = DefEventObserver()

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

    func testUnsubscribeOne() {
        // `unsubscribe` is not supported by DefaultEventObserver
    }

    func testUnsubscribeAll() {
        // `unsubscribe` is not supported by DefaultEventObserver
    }
}
