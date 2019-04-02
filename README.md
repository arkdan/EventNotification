# EventNotification

[Keyboard](https://github.com/arkdan/EventNotification#Keyboard)

Allows to send arbitrary data between parts of an application that are not directly connected.
Normally, you would do so by sending a Notification with NotificationCenter, attaching the object you are sending to userInfo.
This library does exactly that; with sugar:

- no need to define a notificationName
- no need to unsubscribe; observer will be unsubscribed from NotificationCenter automatically upon deinit
- you still have ability to unsubscribe at any point
- clear syntax.

```ruby
pod 'EventNotification'
```
Say, you have

```swift
struct A {
    let string: String
}
```

To send an instance of `A` to all interested observers,

```swift
extension A: Event {}

class SomeEventObserver: EventObserver {
    let eventToken = EventToken()

    func startObservingA() {
        handleEvent(A.self) { [weak self] a in
            print(a.string)
        }
    }
    
    func stopObservingA() {
        self.unsubscribe(A.self)
    }
    
    func stopObservingAll() {
        self.unsubscribe()
    }
}

let a = A(string: "hfgjhk m,jkj fghjv")
a.send()
```

`let eventToken = EventToken()` is the only requirement for a observer class.

A not-uncommon case is, a observer class has no intent to unsubscribe from observing events (it will be unsubscribed automatically on deinit).
It the observer class may conform to `DefaultEventObserver`, which provides default implementation of `var eventToken`.

```swift
class OtherEventObserver: DefaultEventObserver {

    func startObservingA() {
        handleEvent(A.self) { [weak self] a in
            print(a.string)
        }
    }
}
```

### Keyboard

The library includes implementaion of keyboard events

`KeyboardDidShowEvent`, `KeyboardWillShowEvent`, `KeyboardWillHideEvent`, `KeyboardWillChangeFrameEvent`

```swift
class ViewControllerController: UIViewController, KeyboardEventObserver {

    let eventToken = EventToken()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        onKeyboardWillAppear { [weak self] frame in
            var contentInsets: UIEdgeInsets = .zero
            contentInsets.bottom = frame.height
            self?.tableView.contentInset = contentInsets
            self?.tableView.scrollIndicatorInsets = contentInsets
        }

        onKeyboardDissappear { [weak self] in
            self?.tableView.contentInset = .zero
            self?.tableView.setContentOffset(.zero, animated: true)
        }
        
        onKeyboardFrameChanged { [weak self] frame in
            // new frame
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unsubscribeKeyboardAppear()
        unsubscribeKeyboardDisappear()
        
        // or,
        unsubscribe()
    }
}
```


