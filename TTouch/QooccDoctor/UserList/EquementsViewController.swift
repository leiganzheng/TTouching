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
        
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var modif: UIButton!
    @IBOutlet weak var pas: UILabel!
    @IBOutlet weak var passWord: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sockertManger = SocketManagerTool.shareInstance()
        self.passWord.text = "123456"
        self.pas.text = NSLocalizedString("密码", tableName: "Localization",comment:"jj")
        self.login.setTitle(NSLocalizedString("登入", tableName: "Localization",comment:"jj"), forState: .Normal)
        self.modif.setTitle(NSLocalizedString("修改密码", tableName: "Localization",comment:"jj"), forState: .Normal)
        self.passWord.placeholder = NSLocalizedString("请输入密码", tableName: "Localization",comment:"jj")
        self.title = NSLocalizedString("设备管理", tableName: "Localization",comment:"jj")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginAction(sender: AnyObject) {
        if (self.passWord.text?.characters.count == 0){
            QNTool.showErrorPromptView(nil, error: nil, errorMsg:NSLocalizedString("请输入密码", tableName: "Localization",comment:"jj"))
        }else{
            self.senderData(self.passWord.text!)
        }
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.hidesBottomBarWhenPushed = true
    }
    
    //连接服务器按钮事件
    func senderData(pass:NSString) {
        
//        self.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(MannageEquementViewController.CreateFromStoryboard("Main") as! UIViewController, animated: true)
//        return
        let dict = ["command": 32,"permit" : pass]
        sockertManger.sendMsg(dict) { (result) in
            let d = result as! NSDictionary
            let status = d.objectForKey("status") as! NSNumber
            if (status.intValue == 1) {
                QNTool.showPromptView(NSLocalizedString("验证成功", tableName: "Localization",comment:"jj"), {
                    self.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(MannageEquementViewController.CreateFromStoryboard("Main") as! UIViewController, animated: true)
                })
               
            }else{
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: NSLocalizedString("验证失败", tableName: "Localization",comment:"jj"))
            }
            print(result)
        }
    }


}
