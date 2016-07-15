//
//  test.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/7.
//  Copyright © 2016年 Private. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class OutSocket: NSObject, GCDAsyncUdpSocketDelegate {
    
//    let IP = "90.112.76.180"
    let PORT:UInt16 = 33632
    var socket:GCDAsyncUdpSocket!
    
    override init(){
        super.init()
        setupConnection()
    }
    
    func setupConnection(){
        let ipAddress =  GetWiFiInfoHelper.getIPAddress(true)//192.168.5.23
        let arr = ipAddress.componentsSeparatedByString(".") as NSArray
        var index = 0
        let mulArr = NSMutableArray()
        for str in arr {
            index = index + 1
            if index < arr.count {
                mulArr.addObject(str)
            }
            if index == arr.count {
                mulArr.addObject("255")
            }
            
        }
        let IP = mulArr.componentsJoinedByString(".")
        do {
            socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
           try socket.connectToHost(IP, onPort: PORT)
            
        } catch {
            // deal with error
        }
      
    }
    
    func send(message:String){
        let data = message.dataUsingEncoding(NSUTF8StringEncoding)
        socket.sendData(data, withTimeout: 2, tag: 0)
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didConnectToAddress address: NSData!) {
        print("didConnectToAddress");
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
        print("didNotConnect \(error)")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
        print("didSendDataWithTag")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
        print("didNotSendDataWithTag")
    }
}
