//
//  ChangePasswordViewController.swift
//  QooccDoctor
//
//  Created by LiuYu on 15/7/9.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit

/**
*  @author LiuYu, 15-07-09
*
*  // MARK: - 修改密码 （Xib 在 Login.storyboard 内）
*/
class ChangePasswordViewController: UIViewController, QNInterceptorNavigationBarShowProtocol, QNInterceptorKeyboardProtocol, UITextFieldDelegate {
    
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "修改密码"
        
        RegisterViewController.configTextField(self.textField1)
        RegisterViewController.configTextField(self.textField2)
        RegisterViewController.configTextField(self.textField3)
        
        // 键盘消失
        let tap = UITapGestureRecognizer()
        tap.rac_gestureSignal().subscribeNext { [weak self](tap) -> Void in
            self?.view.endEditing(true)
        }
        self.view.addGestureRecognizer(tap)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 提交
    @IBAction func submit(sender: AnyObject!) {
        if self.check() {
            QNNetworkTool.changePassword(g_doctor!.doctorId, oldPassword: self.textField1.text!, newPassword: self.textField2.text!, completion: { (succeed, error, errorMsg) -> Void in
                if succeed {
                    QNNetworkTool.updateCurrentDoctorInfo(nil)
                }
                else {
                    QNTool.showErrorPromptView(nil, error: error, errorMsg: errorMsg)
                }
            })
        }
    }
    
    // 检查输入是否合法
    private func check() -> Bool {
        let text0 = self.textField1.text ?? ""
        let text1 = self.textField2.text ?? ""
        let text2 = self.textField3.text ?? ""
        
        if text0.characters.count >= 0 {
            if text0 != g_Password {
                QNTool.showPromptView("请输入正确的原密码")
                self.textField1.becomeFirstResponder()
                return false
            }
        }
        else {
            QNTool.showPromptView("请输入原密码")
            self.textField1.becomeFirstResponder()
            return false
        }

        if text1.characters.count < 6 {
            QNTool.showPromptView("请输入6位及以上密码")
            self.textField2.becomeFirstResponder()
            return false
        }
        else if text2.characters.count < 6 {
            QNTool.showPromptView("请输入6位及以上密码")
            self.textField3.becomeFirstResponder()
            return false
        }
        else if text1 != text2 {
            QNTool.showPromptView("确认密码与密码不一致")
            self.textField3.becomeFirstResponder()
            return false
        }
        
        if text0 == text1 {
            QNTool.showPromptView("密码未做修改")
            return false
        }
        
        return true
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.textField1 {
            self.textField2.becomeFirstResponder()
        }
        else if textField == self.textField2 {
            self.textField3.becomeFirstResponder()
        }
        else if textField == self.textField3 {
            textField.resignFirstResponder()
            self.submit(nil)
        }
        
        return true
    }

}
