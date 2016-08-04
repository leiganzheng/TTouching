//
//  SocketManagerTool.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/28.
//  Copyright © 2016年 Private. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

typealias SocketBlock = (AnyObject) -> Void

class SocketManagerTool: NSObject ,GCDAsyncSocketDelegate{
    let addr = "192.168.10.100"
    let port:UInt16 = 33632
    var clientSocket:GCDAsyncSocket!
    var mainQueue = dispatch_get_main_queue()
    
    var SBlock :SocketBlock?
    
    override init(){
        super.init()
        connectSocket()
    }
    func sendMsg(dict: NSDictionary) {
        clientSocket.writeData(self.paramsToJsonDataParams(dict as! [String : AnyObject]) , withTimeout: -1, tag: 0)
    }
    //连接服务器按钮事件
     func connectSocket() {
        do {
            clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
//             clientSocket.delegate = self
//            clientSocket.delegateQueue = dispatch_get_main_queue()
            try clientSocket.connectToHost(addr, onPort: port)
           
//            try clientSocket.connectToHost(addr, onPort: port, withTimeout: -1)
        }
            
        catch {
            print("error")
        }
    }

    
    //MARK:- private method
    func paramsToJsonDataParams(params: [String : AnyObject]) -> NSData {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
            //            let jsonDataString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            
            return jsonData
        }catch{
            return NSData()
        }
    }
    
    //MARK:- GCDAsyncSocketDelegate
    func socket(sock:GCDAsyncSocket!, didConnectToHost host: String!, port:UInt16) {
        
        print("与服务器连接成功！")
        
        clientSocket.readDataWithTimeout(-1, tag:0)
        
    }
    
    func socketDidDisconnect(sock:GCDAsyncSocket!, withError err: NSError!) {
        print("与服务器断开连接")
    }
    
    func socket(sock:GCDAsyncSocket!, didReadData data: NSData!, withTag tag:Int) {
        // 1 获取客户的发来的数据 ，把 NSData 转 NSString
        let readClientDataString:NSString? = NSString(data: data, encoding:NSUTF8StringEncoding)
        print(data)
        
        // 2 主界面ui 显示数据
        dispatch_async(mainQueue, {
            self.SBlock!(data)
            let showStr:NSMutableString = NSMutableString()
            
        })
        
        // 3.处理请求，返回数据给客户端 ok
        let serviceStr:NSMutableString = NSMutableString()
        serviceStr.appendString("ok\n")
        clientSocket.writeData(serviceStr.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1, tag: 0)
        
        // 4每次读完数据后，都要调用一次监听数据的方法
        clientSocket.readDataWithTimeout(-1, tag:0)
    }

}
