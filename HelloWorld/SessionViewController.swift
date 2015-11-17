//
//  ViewController.swift
//  HelloWorld
//
//  Created by Ankur Oberoi on 11/15/15.
//  Copyright © 2015 Ankur Oberoi. All rights reserved.
//

import UIKit

class SessionViewController: UIViewController, OTSessionDelegate, OTPublisherDelegate, OTSubscriberDelegate, UIBarPositioningDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    lazy var sessionConfig: [String:String] = {
        return self.appDelegate.config["HelloWorldSession"] as! [String:String]
    }()
    
    lazy var session: OTSession = {
        return OTSession(apiKey: self.sessionConfig["apiKey"]!, sessionId: self.sessionConfig["sessionId"]!, delegate: self)
    }()
    
    lazy var publisher: OTPublisher = {
        return OTPublisher(delegate: self)
    }()
    
    var subscriber: OTSubscriber?
    
    @IBOutlet weak var publisherViewContainer: UIView!
    @IBOutlet weak var subscriberViewContainer: UIView!
    @IBOutlet weak var toggleConnectButton: UIBarButtonItem!
    
    override func viewDidLayoutSubviews() {
        publisher.view.frame = publisherViewContainer.bounds
        subscriber?.view.frame = subscriberViewContainer.bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        publisherViewContainer.addSubview(publisher.view)
        
        toggleConnect(self)
    }

    // NOTE: It would be nicer if this view controller could "observe" session.sessionConnectionStatus
    //       directly, and update its enabled and title properties accordingly. KVO is supposed to
    //       provide that type of functionality, but KVO has become de-empahsized in modern ObjC and
    //       is super kludgey in Swift. See also: https://github.com/slazyk/Observable-Swift
    @IBAction func toggleConnect(sender: AnyObject) {
        
        switch session.sessionConnectionStatus {
        case OTSessionConnectionStatus.Connected:
            
            var disconnectError: OTError?
            session.disconnect(&disconnectError)
            
            guard (disconnectError == nil) else {
                print("Disconnect Error: \(disconnectError!.description)")
                return
            }
            
            toggleConnectButton.title = "Disconnecting..."
            toggleConnectButton.enabled = false

        case OTSessionConnectionStatus.NotConnected:
            
            var connectError: OTError?
            session.connectWithToken(sessionConfig["token"]!, error: &connectError)
            
            guard (connectError == nil) else {
                print("Connect Error: \(connectError!.description)")
                return
            }
            
            toggleConnectButton.title = "Connecting..."
            toggleConnectButton.enabled = false
        default:
            print("Cannot toggle connect with session connection status: \(session.sessionConnectionStatus)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Bar Positioning Delegate
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    // MARK: Session Delegate
    
    func sessionDidConnect(session: OTSession!) {
        print("Session connected")
        
        var publishError: OTError?
        session.publish(publisher, error: &publishError)
        
        guard (publishError == nil) else {
            print("Publish Error: \(publishError!.description)")
            return
        }
        
        toggleConnectButton.title = "Disconnect"
        toggleConnectButton.enabled = true
    }
    
    func sessionDidDisconnect(session: OTSession!) {
        print("Session disconnected")
        
        subscriber?.view.removeFromSuperview()
        subscriber = nil
        
        toggleConnectButton.title = "Connect"
        toggleConnectButton.enabled = true
    }
    
    func session(session: OTSession!, didFailWithError error: OTError!) {
        print("Session failed with error: \(error.description)")
    }
    
    func session(session: OTSession!, streamCreated stream: OTStream!) {
        print("Stream created")
        
        guard (subscriber == nil) else {
            print("Subscriber already exists")
            return
        }
        
        subscriber = OTSubscriber(stream: stream, delegate: self)
        
        var subscribeError: OTError?
        session.subscribe(subscriber, error: &subscribeError)
        
        guard (subscribeError == nil) else {
            print("Subscribe error: \(subscribeError!.description)")
            return
        }
        
        subscriberViewContainer.addSubview(subscriber!.view)
    }
    
    func session(session: OTSession!, streamDestroyed stream: OTStream!) {
        print("Stream destroyed")
        
        // TODO: repeated code from sessionDidDisconnect
        subscriber?.view.removeFromSuperview()
        subscriber = nil
    }
    
    // MARK: Publisher Delegate
    
    func publisher(publisher: OTPublisherKit!, didFailWithError error: OTError!) {
        print("Publisher did fail with error: \(error.description)")
    }
    
    func publisher(publisher: OTPublisherKit!, streamCreated stream: OTStream!) {
        print("Publisher stream created")
    }
    
    func publisher(publisher: OTPublisherKit!, streamDestroyed stream: OTStream!) {
        print("Publisher stream destroyed")
    }
    
    // MARK: Subscriber Delegate
    
    func subscriber(subscriber: OTSubscriberKit!, didFailWithError error: OTError!) {
        print("Subscriber did fail with error: \(error.description)")
    }

    func subscriberDidConnectToStream(subscriber: OTSubscriberKit!) {
        print("Subscriber did connect to stream")
    }
    
    func subscriberVideoDataReceived(subscriber: OTSubscriber!) {
        print("Subscriber video data received")
    }

}

