//
//  EquementsViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/2.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class EquementsViewController: UIViewController,QNInterceptorProtocol{

    var sockertManger:SocketManagerTool!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sockertManger = SocketManagerTool()
        self.title = "设备管理"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginAction(sender: AnyObject) {
        self.senderData()
        return
        self.hidesBottomBarWhenPushed = true
         self.navigationController?.pushViewController(MannageEquementViewController.CreateFromStoryboard("Main") as! UIViewController, animated: true)
        
    }
    
    
    //连接服务器按钮事件
    func senderData() {
        let dict = ["command": 32,"permit" : "123Abc"]
        var str = dict.description
        print("str:\(str)")
        print("strData:\(dict.description.dataUsingEncoding(NSUTF8StringEncoding))")
        
        sockertManger.sendMsg(dict)        
    }


}
