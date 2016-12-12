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
    // MARK: >> 单例化
    class func shareInstance()->SocketManagerTool{
        struct psSingle{
            static var onceToken:dispatch_once_t = 0;
            static var instance:SocketManagerTool? = nil
        }
        //保证单例只创建一次
        dispatch_once(&psSingle.onceToken,{
            psSingle.instance = SocketManagerTool()
        })
        return psSingle.instance!
    }
    func sendMsg(dict: NSDictionary,completion:(AnyObject) -> Void) {
        self.SBlock = completion
        clientSocket.writeData(self.paramsToJsonDataParams(dict as! [String : AnyObject]), withTimeout: -1, tag: 0)
    }

    //连接服务器按钮事件
     func connectSocket() {
        do {
            clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
            //使用解析出来的ip连接测试
//            try clientSocket.connectToHost(DBManager.shareInstance().ip, onPort: port)
            //使用固定ip连接测试
            try clientSocket.connectToHost(addr, onPort: port)
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
            print("jsonData:\(jsonData)")
            return jsonData
        }catch{
            return NSData()
        }
    }
    
    //MARK:- GCDAsyncSocketDelegate
    func socket(sock:GCDAsyncSocket!, didConnectToHost host: String!, port:UInt16) {
//         self.SBlock!("")
        print("与服务器连接成功！")
        
        clientSocket.readDataWithTimeout(-1, tag:200)
        
    }
    
    func socketDidDisconnect(sock:GCDAsyncSocket!, withError err: NSError!) {
//        self.SBlock!("")
        print("与服务器断开连接")
    }
    func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        print("消息发送成功")
    }
//    func UTF8ToGB2312(str: String) -> (NSData?, UInt) {
//        let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
//        let data = str.dataUsingEncoding(enc, allowLossyConversion: false)
//        return (data, enc)
//    }
    
    func socket(sock:GCDAsyncSocket!, didReadData data: NSData!, withTag tag:Int) {
        let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
        // 1 获取客户的发来的数据 ，把 NSData 转 NSString
        let readClientDataString =  String(data: data, encoding: enc)
       //处理gbk问题
        let newStr = readClientDataString?.stringByTrimmingCharactersInSet(NSCharacterSet.controlCharacterSet())
        
        if readClientDataString != nil {
            //将数据转为UTF-8
            let  tempData = newStr?.dataUsingEncoding(NSUTF8StringEncoding)
            print(readClientDataString)
            
            do  {
                
                let jsonObject = try  NSJSONSerialization.JSONObjectWithData(tempData!, options: NSJSONReadingOptions.MutableContainers)
                var dictionary = jsonObject as? NSDictionary
                if dictionary == nil {  // Json解析结果出错
                    NSLog("JSON解析错误")
                    
                }else{
                    self.SBlock!(dictionary!)
                }
                
                // 这里有可能对数据进行了jsonData的包装，有可能没有进行jsonData的包装
                if let jsonData = dictionary!["jsonData"] as? NSDictionary {
                    dictionary = jsonData
                }
                
            }catch (let e) {
                print(e)
                // 直接出错了
                if self.SBlock != nil {
                    self.SBlock!("")
                    NSLog("直接出错了")
                }
            }
        }else{
            let tempData = data
            let readClientDataString = NSString(data:data!, encoding: NSUTF8StringEncoding)
            //将数据转为UTF-8
            print(readClientDataString)
            
            do  {
                let jsonObject: AnyObject? = try  NSJSONSerialization.JSONObjectWithData(tempData!, options: NSJSONReadingOptions.AllowFragments)
                var dictionary = jsonObject as? NSDictionary
                if dictionary == nil {  // Json解析结果出错
                    NSLog("JSON解析错误")
                    
                }else{
                    self.SBlock!(dictionary!)
                }
                
                // 这里有可能对数据进行了jsonData的包装，有可能没有进行jsonData的包装
                if let jsonData = dictionary!["jsonData"] as? NSDictionary {
                    dictionary = jsonData
                }
                
            }catch {
                // 直接出错了
                if self.SBlock != nil {
                    self.SBlock!("")
                    NSLog("直接出错了")
                }
            }
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
        clientSocket.readDataWithTimeout(-1, tag:200)
    }

}
