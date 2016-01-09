//
//  ViewController.swift
//  HelloWorld
//
//  Created by Ankur Oberoi on 11/15/15.
//  Copyright © 2015 Ankur Oberoi. All rights reserved.
//

import UIKit

class SessionViewController: UIViewController, OTSessionDelegate, OTPublisherDelegate, OTSubscriberDelegate {
    
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
    
    override func viewDidLayoutSubviews() {
        publisher.view.frame = publisherViewContainer.bounds
        subscriber?.view.frame = subscriberViewContainer.bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var connectError: OTError?
        session.connectWithToken(sessionConfig["token"]!, error: &connectError)
        
        guard (connectError == nil) else {
            print("Connect Error: \(connectError!.description)")
            return
        }
        
        publisherViewContainer.addSubview(publisher.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    }
    
    func sessionDidDisconnect(session: OTSession!) {
        print("Session disconnected")
        
        publisher.view.removeFromSuperview()
        
        subscriber?.view.removeFromSuperview()
        subscriber = nil
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
    
    func session(session: OTSession!, connectionCreated connection: OTConnection!) {
        print("Connection created: \(connection.connectionId)")
    }
    
    func session(session: OTSession!, receivedSignalType type: String!, fromConnection connection: OTConnection?, withString string: String!) {
        if let connection = connection {
            print("Session recieved signal of type: \(type), from connection: \(connection.connectionId), with string: \(string)")
        } else {
            print("Session recieved signal without connection")
        }
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

