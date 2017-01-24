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
    
    @IBOutlet weak var newPas: UITextField!
    @IBOutlet weak var oldpass: UITextField!
    @IBOutlet weak var newMpas: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "修改设备管理密码"
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
            let dict = ["command": 33,"permit_old" : QNTool.UTF8TOGB2312(self.oldpass.text!),"permit_ new":QNTool.UTF8TOGB2312(self.newPas.text!)]
            self.sockertManger.sendMsg(dict, completion: { (result) in
                if result is NSDictionary {
                let d = result as! NSDictionary
                let status = d.objectForKey("status") as! Int
                if (status == 1){
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "修改成功！")
                }else if(status  == -1){
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "旧密码错误！")
                }else if(status  == -2){
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "字符数不正确！")
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "修改失败！")
                }
                }
            })

        }else{
            QNTool.showErrorPromptView(nil, error: nil, errorMsg: "两次输入密码不一样！")
        }
        
    }
    private func checkAccountPassWord() -> Bool {
        if (self.oldpass.text?.characters.count == 0 && self.newPas.text?.characters.count == 0 && self.newMpas.text?.characters.count == 0) {
            QNTool.showPromptView("请输入内容")
            self.oldpass.becomeFirstResponder()
            return false
        }else if(self.oldpass.text?.characters.count == 0) {
            QNTool.showPromptView("请输入密码")
            self.oldpass.becomeFirstResponder()
            return false
            
        }else if (self.newPas.text?.characters.count == 0){
            QNTool.showPromptView("请输入新密码")
            self.newPas.becomeFirstResponder()
            return false
        }else if (self.newMpas.text?.characters.count == 0){
            QNTool.showPromptView("请输入验证密码")
            self.newMpas.becomeFirstResponder()
            return false
        }
        return true
        
    }


}
