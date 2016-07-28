//
//  ForgetPasswordViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 15/7/6.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//  Modify by Leiganzheng 2015-7-13

import UIKit

/**
*  @author leiganzheng, 15-07-06
*
*  // MARK: - 忘记密码
*/
class ForgetPasswordViewController: UIViewController,QNInterceptorNavigationBarShowProtocol{

    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = defaultBackgroundGrayColor
        RegisterViewController.configTextField(self.textField1)
        RegisterViewController.configTextField(self.textField2)
        
        // 获取验证码的按钮
        let authCodeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 90*COEFFICIENT_OF_WIDTH_ZOOM, height: self.textField2.bounds.height*COEFFICIENT_OF_HEIGHT_ZOOM))
        authCodeButton.layer.borderWidth = 0.5
        authCodeButton.layer.borderColor = defaultLineColor.CGColor
        authCodeButton.backgroundColor = appThemeColor
        authCodeButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        RegisterViewController.waitingAuthCode(authCodeButton, start: false)
        self.textField2.rightView = authCodeButton
        authCodeButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { [weak self](sender) -> Void in
            if let strongSelf = self {
                RegisterViewController.fetchAuthCode(strongSelf, phone: { () -> String? in
                    if !QNTool.stringCheck(strongSelf.textField1.text) {
                        QNTool.showPromptView("请填写手机号码")
                        strongSelf.textField1.text = nil; strongSelf.textField1.becomeFirstResponder()
                        return nil
                    }
                    else {
                        return strongSelf.textField1.text!
                    }
                }, authCodeButton: authCodeButton, isRegister: false)
            }
        }
        
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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    // MARK: 重置密码
    @IBAction func resetPassword(sender: UIButton!){
        if self.check() {
//            QNNetworkTool.resetPassword(self.textField1.text!, authcode: self.textField2.text!, password: self.textField3.text!, completion: { [weak self](succeed, error, errorMsg) -> Void in
//                if let _ = self {
//                    if succeed {
//                        QNTool.showPromptView("密码修改成功，请登录")
//                        self?.navigationController?.popViewControllerAnimated(true)
//                    }
//                    else {
//                        QNTool.showErrorPromptView(nil, error: error, errorMsg: errorMsg)
//                    }
//                }
//            })
        }
    }
    
    // 判断输入的合法性
    private func check() -> Bool {
        if !QNTool.stringCheck(self.textField1.text) {
            QNTool.showPromptView("请填写手机号码")
            self.textField1.text = nil; self.textField1.becomeFirstResponder()
            return false
        }
        
        
        if !QNTool.stringCheck(self.textField2.text) {
            QNTool.showPromptView("请填写验证码")
            self.textField2.text = nil; self.textField2.becomeFirstResponder()
            return false
        }
        
            return true
    }

    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.textField1 {
            self.textField2.becomeFirstResponder()
        }
        
        return true
    }
    
    
}
