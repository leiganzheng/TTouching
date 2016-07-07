//
//  test.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/7.
//  Copyright © 2016年 Private. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class UDPListener : GCDAsyncUdpSocketDelegate {
    
    var udpSock : GCDAsyncUdpSocket?
    let listenPort : UInt16 = 33632
    let data = "testing".dataUsingEncoding(NSUTF8StringEncoding)
//    let toAddress = "127.0.0.1"
    let connectPort : UInt16 = 33632
    
    
    init () {
        
        udpSock = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        do {
            
            try udpSock!.bindToPort(listenPort, interface: "lo0")  // Swift automatically translates Objective-C methods that produce
            // errors into methods that throw an error according to Swift’s native error handling functionality.
        }
        catch _ as NSError {
            print("Issue with binding to Port")
            return
        }
        
        do {
            
            try udpSock!.beginReceiving()
        }
            
        catch _ as NSError {
            print("Issue with receciving data")
            return
        }
    }
    
    func sendData(address:String) {
        
        udpSock!.sendData(data, toHost: address, port: connectPort, withTimeout: -1, tag: 0)
    }
    
}



//    Delegate CallBacks


 func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
    
    let str = NSString(data: data!, encoding: NSUTF8StringEncoding)
    print(str)
}

  func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
    
    print("didSendDataWithTag")
}

  func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
    
    print("didNOTSendDataWithTag")
}

