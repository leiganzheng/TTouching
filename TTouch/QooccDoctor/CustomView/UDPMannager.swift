//
//  UDPMannager.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/8/18.
//  Copyright © 2016年 Private. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class UDPMannager: NSObject, GCDAsyncUdpSocketDelegate {
    
   
    var socket:GCDAsyncUdpSocket!
    
    override init(){
        super.init()
        setupConnection()
    }
    
    func setupConnection(){
        let PORT:UInt16 = 33632
        let IP = self.buildIP()
        do {
            socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
            try socket.enableBroadcast(true)
             try socket.bindToPort(0)
            
            /*IOS开发中，使用 GCDAsyncUdpSocket接收广播包，折腾半天没有反应。其实很简单,
            
            bind port时不要指定 interface!
            
            
            [mGCDAsyncUdpSocket bindToPort:0  error:&error];
           */

            try socket.joinMulticastGroup(IP)
            try socket.beginReceiving()
            
        } catch {
            // deal with error
        }
        
    }
    
    func send(message:NSData){
        let port:UInt16 = 33392
        if (port <= 0 || port > 65535)
        {
            return
        }
        let IP = self.buildIP()
        socket.sendData(message, toHost:IP , port: port, withTimeout: -1, tag: 0)
    }
    func buildIP()-> String{
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
        
//        return mulArr.componentsJoinedByString(".")
//        return "224.0.0.1"
        return ipAddress
    }
    func paraConvert(d:NSData) -> [UInt8]{
        //把NSData的值存到byteArray中
        var byteArray:[UInt8] = [UInt8]()
        for i in 0..<3 {
            var temp:UInt8 = 0
            d.getBytes(&temp, range: NSRange(location: i,length:1 ))
            byteArray.append(temp)
        }
//        let tem1 = byteArray[4...9] as [UInt8]
//        let tem2 = byteArray[8...15]
//        let tem3 = byteArray[14...19]
//          let tempdata = NSData(bytes: tem1  , length: 4)
        return byteArray
    }
//    func makeData(arr:[UInt8],index1:Int,index2:Int)-> NSData{
////        let data = malloc(1000);
////        memcpy(data, arr, 1000);
//    }
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
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!,withFilterContext filterContext: AnyObject!) {
        print("incoming message: \(data)");
        
//        print("incoming message1: \(address)");
    }
}
