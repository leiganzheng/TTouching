//
//  ModifyEquenmentsViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/2.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ModifyEquenmentsViewController: UIViewController,QNInterceptorProtocol {


    var sockertManger:SocketManagerTool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设备管理"
        self.sockertManger = SocketManagerTool.shareInstance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- private method
    func sendMsg() {
        
        // 1.处理请求，返回数据给客户端 ok
        let dict = ["command": 33,"permit_old" : "654321","permit_ new":"123456"]
        self.sockertManger.sendMsg(dict, completion: { (result) in
            let d = result as! NSDictionary
//            let status = d.objectForKey("work_status") as! NSNumber
//            if (status == 97){
//                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "开启情景一！")
//            }else{
//                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
//            }
        })
        
    }
    //连接服务器按钮事件
    func fectchData() {
        
    }
   
}
