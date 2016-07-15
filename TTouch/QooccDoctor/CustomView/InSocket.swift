//
//  test.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/7.
//  Copyright © 2016年 Private. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class InSocket: NSObject, GCDAsyncUdpSocketDelegate {
    
    let IP = "255.255.255.255"
    let PORT:UInt16 = 5556
    var socket:GCDAsyncUdpSocket!
    
    override init(){
        super.init()
        setupConnection()
    }
    
    func setupConnection(){
        do {
           
            socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
            try socket.bindToPort(PORT)
//            try socket.enableBroadcast(true)
//            try socket.joinMulticastGroup(IP)
            try socket.connectToHost(IP, onPort: PORT)
            try socket.beginReceiving()
        } catch {
            // deal with error
        }

       
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!,withFilterContext filterContext: AnyObject!) {
        print("incoming message: \(data)");
    }
}