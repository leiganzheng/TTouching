//
//  test.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/7.
//  Copyright © 2016年 Private. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

typealias resultBlock = (AnyObject) -> Void

class OutSocket: NSObject, GCDAsyncUdpSocketDelegate {
    
//    let IP = "90.112.76.180"
    let PORT:UInt16 = 33632
    var socket:GCDAsyncUdpSocket!
    var myResultBlock :resultBlock?
    
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
            try socket.enableBroadcast(true)
            try socket.bindToPort(0)
//            socket.localPort()
//            try socket.joinMulticastGroup(IP)
//           try socket.connectToHost(IP, onPort: PORT)
            try socket.beginReceiving()
            
        } catch {
            // deal with error
            NSLog("error")
        }
      
    }
    
    func send(message:NSData,complete:(AnyObject)->Void){
        self.myResultBlock = complete
        let ipAddress =  GetWiFiInfoHelper.getIPAddress(true)
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
        socket.sendData(message, toHost:IP , port: 33632, withTimeout: -1, tag: 0)
    }
    func test(){
        let delayInSeconds = 2.0
        let popTime = dispatch_time(DISPATCH_TIME_NOW,Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) {
            self.myResultBlock!("fail")
        }
    }
    func udpSocket(sock: GCDAsyncUdpSocket!, didConnectToAddress address: NSData!) {
        self.myResultBlock!("fail")
        print("didConnectToAddress");
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
        self.myResultBlock!("fail")
        print("didNotConnect \(error)")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
        self.myResultBlock!("fail")
        print("didSendDataWithTag")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
        self.myResultBlock!("fail")
        print("didNotSendDataWithTag")
    }
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!,withFilterContext filterContext: AnyObject!) {
        self.myResultBlock!("fail")
        print("incoming message: \(data)");
        print("incoming message1: \(address)");
        
//        //把NSData的值存到byteArray中
//        var byteArray:[UInt8] = [UInt8]()
//        for i in 0..<3 {
//            var temp:UInt8 = 0
//            data.getBytes(&temp, range: NSRange(location: i,length:1 ))
//            byteArray.append(temp)
//        }
//        print("byteArray: \(byteArray)");
        DBManager.shareInstance().ip = ""
    }
}
