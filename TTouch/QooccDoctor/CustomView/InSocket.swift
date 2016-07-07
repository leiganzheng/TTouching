//
//  test.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/7.
//  Copyright © 2016年 Private. All rights reserved.
//

import UIKit

class InSocket: NSObject, GCDAsyncUdpSocketDelegate {
    
    let IP = "255.255.255.255"
    let PORT:UInt16 = 5556
    var socket:GCDAsyncUdpSocket!
    
    override init(){
        super.init()
        setupConnection()
    }
    
    func setupConnection(){
        var error : NSError?
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        socket.bindToPort(PORT, error: &error)
        socket.enableBroadcast(true, error: &error)
        socket.joinMulticastGroup(IP, error: &error)
        socket.beginReceiving(&error)
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!,      withFilterContext filterContext: AnyObject!) {
        println("incoming message: \(data)");
    }
}