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
//    let addr = "192.168.1.100"
    let addr = DBManager.shareInstance().ip
    let port:UInt16 = 33632
    var clientSocket:GCDAsyncSocket!
    var mainQueue = dispatch_get_main_queue()
    
    var SBlock :SocketBlock?
    
    override init(){
        super.init()
        connectSocket()
    }
    func sendMsg(dict: NSDictionary) {
        //两种方式处理字符串发送
        clientSocket.writeData(dict.description.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1, tag: 0)
    }
    func sendMsg(dict: NSDictionary,completion:(AnyObject) -> Void) {
//        self.SBlock = completion
        clientSocket.writeData(self.paramsToJsonDataParams(dict as! [String : AnyObject]).dataUsingEncoding(NSUTF8StringEncoding) , withTimeout: -1, tag: 0)
    }

    //连接服务器按钮事件
     func connectSocket() {
        do {
            clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
//             clientSocket.delegate = self
//            clientSocket.delegateQueue = dispatch_get_main_queue()
            //使用解析出来的ip连接测试
//            try clientSocket.connectToHost(DBManager.shareInstance().ip, onPort: port)
            //使用固定ip连接测试
            try clientSocket.connectToHost(addr, onPort: port)
           
//            try clientSocket.connectToHost(addr, onPort: port, withTimeout: -1)
            
        }
            
        catch {
            print("error")
        }
    }

    
    //MARK:- private method
    func paramsToJsonDataParams(params: [String : AnyObject]) -> NSString {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
            let jsonDataString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            
            return jsonDataString
        }catch{
            return NSString()
        }
    }
    
    //MARK:- GCDAsyncSocketDelegate
    func socket(sock:GCDAsyncSocket!, didConnectToHost host: String!, port:UInt16) {
//         self.SBlock!("")
        print("与服务器连接成功！")
        
        clientSocket.readDataWithTimeout(-1, tag:0)
        
    }
    
    func socketDidDisconnect(sock:GCDAsyncSocket!, withError err: NSError!) {
//        self.SBlock!("")
        print("与服务器断开连接")
    }
    
    func socket(sock:GCDAsyncSocket!, didReadData data: NSData!, withTag tag:Int) {
        // 1 获取客户的发来的数据 ，把 NSData 转 NSString 
        let readClientDataString:NSString? = NSString(data: data, encoding:NSUTF8StringEncoding)
        print(readClientDataString)
        var byteArray:[UInt8] = [UInt8]()
        for i in 0..<data.length {
            var temp:UInt8 = 0
            data.getBytes(&temp, range: NSRange(location: i,length:1 ))
            byteArray.append(temp)
           
        }
        print("byteArray: \(byteArray)");
        do  {
            let errorJson: NSErrorPointer = nil
            let jsonObject: AnyObject? = try  NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            var dictionary = jsonObject as? NSDictionary
            if dictionary == nil {  // Json解析结果出错
                NSLog("JSON解析错误")
                
                 return
            }else{
                self.SBlock!(dictionary!)
            }
            
//            // 这里有可能对数据进行了jsonData的包装，有可能没有进行jsonData的包装
//            if let jsonData = dictionary!["jsonData"] as? NSDictionary {
//                dictionary = jsonData
//            }
//            
//            let errorCode = Int((dictionary!["errorCode"] as! String))
//            if errorCode == 1000 || errorCode == 0 {
//                completionHandler(request: $0!, response: $1, data: $2, dictionary: dictionary, error: nil)
//            }
//            else {
//                completionHandler(request: $0!, response: $1, data: $2, dictionary: dictionary, error: NSError(domain: "服务器返回错误", code:errorCode ?? 10088, userInfo: nil))
//            }
//            if dictionary == nil {  // Json解析结果出错
//                completionHandler(request: $0!, response: $1, data: $2, dictionary: nil, error: errorJson.memory); return
//            }
        }catch {
            // 直接出错了
            self.SBlock!("")
            NSLog("直接出错了")
             return
        }

        
        // 2 主界面ui 显示数据
//        dispatch_async(mainQueue, {
//            self.SBlock!(data)
//            let showStr:NSMutableString = NSMutableString()
//            
//        })
        
        // 3.处理请求，返回数据给客户端 ok
//        let serviceStr:NSMutableString = NSMutableString()
//        serviceStr.appendString("ok\n")
//        clientSocket.writeData(serviceStr.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1, tag: 0)
        
        // 4每次读完数据后，都要调用一次监听数据的方法
        clientSocket.readDataWithTimeout(-1, tag:0)
    }

}
