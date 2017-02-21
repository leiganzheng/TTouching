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


    @IBOutlet weak var oldp: UILabel!
    @IBOutlet weak var mpass: UILabel!
    @IBOutlet weak var newP: UILabel!
    @IBOutlet weak var saveB: UIButton!
    var sockertManger:SocketManagerTool!
    
    @IBOutlet weak var newPas: UITextField!
    @IBOutlet weak var oldpass: UITextField!
    @IBOutlet weak var newMpas: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("修改设备管理密码", tableName: "Localization",comment:"jj")
        self.oldp.text = NSLocalizedString("原密码", tableName: "Localization",comment:"jj")
        self.newP.text = NSLocalizedString("新密码", tableName: "Localization",comment:"jj")
        self.mpass.text = NSLocalizedString("新密码", tableName: "Localization",comment:"jj")
        self.saveB.setTitle(NSLocalizedString("保存", tableName: "Localization",comment:"jj"), forState: .Normal)
        self.sockertManger = SocketManagerTool.shareInstance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- private method
    @IBAction func saveAction(sender: AnyObject) {
        if !self.checkAccountPassWord() {
            return
        }
        if self.newPas.text == self.newMpas.text {
            let dict = ["command": 33,"permit_old" : QNTool.UTF8TOGB2312(self.oldpass.text!),"permit_new":QNTool.UTF8TOGB2312(self.newPas.text!)]
            self.sockertManger.sendMsg(dict, completion: { (result) in
                if result is NSDictionary {
                let d = result as! NSDictionary
                let status = d.objectForKey("status") as! Int
                if (status == 1){
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: NSLocalizedString("修改成功", tableName: "Localization",comment:"jj"))
                    self.navigationController?.popViewControllerAnimated(true)
                }else if(status  == -1){
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: NSLocalizedString("旧密码错误", tableName: "Localization",comment:"jj"))
                }else if(status  == -2){
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: NSLocalizedString("字符数不正确", tableName: "Localization",comment:"jj"))
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: NSLocalizedString("修改失败", tableName: "Localization",comment:"jj"))
                }
                }
            })

        }else{
            QNTool.showErrorPromptView(nil, error: nil, errorMsg: NSLocalizedString("两次输入密码不一样", tableName: "Localization",comment:"jj"))
        }
        
    }
    private func checkAccountPassWord() -> Bool {
        if (self.oldpass.text?.characters.count == 0 && self.newPas.text?.characters.count == 0 && self.newMpas.text?.characters.count == 0) {
            QNTool.showPromptView(NSLocalizedString("请输入内容", tableName: "Localization",comment:"jj"))
            self.oldpass.becomeFirstResponder()
            return false
        }else if(self.oldpass.text?.characters.count == 0) {
            QNTool.showPromptView(NSLocalizedString("请输入密码", tableName: "Localization",comment:"jj"))
            self.oldpass.becomeFirstResponder()
            return false
            
        }else if (self.newPas.text?.characters.count == 0){
            QNTool.showPromptView(NSLocalizedString("请输入新密码", tableName: "Localization",comment:"jj"))
            self.newPas.becomeFirstResponder()
            return false
        }else if (self.newMpas.text?.characters.count == 0){
            QNTool.showPromptView(NSLocalizedString("请输入验证密码", tableName: "Localization",comment:"jj"))
            self.newMpas.becomeFirstResponder()
            return false
        }
        return true
        
    }


}
