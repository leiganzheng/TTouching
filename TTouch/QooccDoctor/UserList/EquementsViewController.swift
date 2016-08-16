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

    
//    let addr = "192.168.0.10"
//    let port:UInt16 = 33632
    var sockertManger:SocketManagerTool!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "设备管理"
//        self.sockertManger = SocketManagerTool()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginAction(sender: AnyObject) {
        self.hidesBottomBarWhenPushed = true
         self.navigationController?.pushViewController(MannageEquementViewController.CreateFromStoryboard("Main") as! UIViewController, animated: true)
        
    }
    
    
    //连接服务器按钮事件
    func senderData() {
//        let dict = ["command": 32,"permit" : "123Abc"]
//        sockertManger.sendMsg(dict)
//        sockertManger.SBlock =  {(vc) -> Void in
//            print("success")
//        }
    }


}
