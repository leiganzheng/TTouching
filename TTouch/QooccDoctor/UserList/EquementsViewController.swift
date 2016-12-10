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
        
    @IBOutlet weak var passWord: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sockertManger = SocketManagerTool.shareInstance()
        self.title = "设备管理"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginAction(sender: AnyObject) {
        if (self.passWord.text?.characters.count == 0){
            QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请输入密码！")
        }else{
            self.senderData(self.passWord.text!)
        }
        
    }
    
    
    //连接服务器按钮事件
    func senderData(pass:NSString) {
//        let dict = ["command": 30]
        let dict = ["command": 32,"permit" : pass]
        sockertManger.sendMsg(dict) { (result) in
            let d = result as! NSDictionary
            let status = d.objectForKey("status") as! NSNumber
            if (status.intValue == 1) {
//                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "验证成功！")
                QNTool.showPromptView("验证成功！", {
                    self.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(MannageEquementViewController.CreateFromStoryboard("Main") as! UIViewController, animated: true)
                })
               
            }else{
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "验证失败，请重试！")
            }
            print(result)
        }
    }


}
