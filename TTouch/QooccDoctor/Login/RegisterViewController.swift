//
//  RegisterViewController.swift
//  QooccDoctor
//
//  Created by LiuYu on 15/7/7.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit

/**
*  @author LiuYu, 15-07-07
*
*  // MARK: - 注册
*/
class RegisterViewController: UIViewController, QNInterceptorNavigationBarShowProtocol, QNInterceptorKeyboardProtocol, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!

    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var markLbl: UILabel! //提示反馈信息LBL
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                }, authCodeButton: authCodeButton, isRegister: true)
            }
        }
        
        // 键盘消失
        let tap = UITapGestureRecognizer()
        tap.rac_gestureSignal().subscribeNext { [weak self](tap) -> Void in
            self?.view.endEditing(true)
        }
        self.view.addGestureRecognizer(tap)
    }

//     配置输入框，会在其他界面用到
    class func configTextField(textField: UITextField) {
        textField.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        textField.layer.cornerRadius = 2
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.whiteColor().CGColor
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 1))
        textField.leftViewMode = .Always
        
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 1))
        textField.rightViewMode = .Always
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func userAgreeBtnCli(sender: UIButton) {
      self.agreeBtn.selected = !self.agreeBtn.selected
    }
    // 提交
    @IBAction func done(sender: UIButton!) {
//        if self.check() {
//            QNTool.showActivityView("正在注册...", inView: self.view)
////            QNNetworkTool.register(self.textField0.text!,
////                phone: self.textField1.text!,
////                password: self.textField3.text!,
////                authcode: self.textField2.text!, completion: { [weak self](doctor, error, errorMsg) -> Void in
////                    if let strongSelf = self {
////                        QNTool.hiddenActivityView()
////                        if doctor != nil {
////                            let vc = EditInformationViewController.CreateFromStoryboard("Login") as! EditInformationViewController
////                            vc.finished = { () -> Void in
////                                QNNetworkTool.login(Id: strongSelf.textField1.text!, Password: strongSelf.textField3.text!) { (doctor, error, errorMsg) -> Void in
////                                    QNTool.hiddenActivityView()
////                                    if doctor != nil {
////                                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
////                                        QNTool.enterRootViewController(vc, animated: true)
////                                    }
////                                    else {
////                                        QNTool.showErrorPromptView(nil, error: error, errorMsg: errorMsg)
////                                    }
////                                }
////                            }
////                            strongSelf.navigationController?.pushViewController(vc, animated: true)
////                        }
////                        else {
////                            QNTool.showErrorPromptView(nil, error: error, errorMsg: errorMsg)
////                        }
////                    }
////                })
//        }
    }
    
    // 判断输入的合法性
    private func check() -> Bool {
       
        if !QNTool.stringCheck(self.textField1.text, allowLength: 4) {
            QNTool.showPromptView("请填写手机号码")
            self.textField1.text = nil; self.textField1.becomeFirstResponder()
            return false
        }
        
        if !QNTool.stringCheck(self.textField2.text) {
            QNTool.showPromptView("请填写验证码")
            self.textField2.text = nil; self.textField2.becomeFirstResponder()
            return false
        }
        
        if !QNTool.stringCheck(self.textField3.text, allowAllSpace: true, allowLength: 5) {
            QNTool.showPromptView("请设置6位及以上的密码！")
            self.textField3.becomeFirstResponder()
            return false
        }
        if !self.agreeBtn.selected {
            QNTool.showPromptView("请阅读并接受用户协议")
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
            self.done(nil)
        }
        
        return true
    }
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool  {
//        if textField == self.textField0 {
//            self.markLbl.text = ""
//            textField.textColor = UIColor.blackColor()
//        }
        return true
    }
    
}

// MARK: - 获取验证码UI 显示的超时时间
private let overTimeMax = 60

// MARK: - 获取验证码的支持
extension RegisterViewController {
    // MARK: 验证码
    // 从服务器获取验证码
    class func fetchAuthCode(viewController: UIViewController, phone: (() -> String?), authCodeButton: UIButton?, isRegister: Bool) {
        if let phoneNum = phone() where phoneNum.characters.count > 0 {
            QNTool.showActivityView("正在获取验证码...", inView: viewController.view)
            QNNetworkTool.fetchAuthCode(phoneNum, isRegister: isRegister, completion: { [weak viewController](succeed, error, errorMsg) -> Void in
                if let _ = viewController {
                    QNTool.hiddenActivityView()
                    if succeed {
                        self.waitingAuthCode(authCodeButton, start: true)
                    }
                    else {
                        QNTool.showErrorPromptView(nil, error: error, errorMsg: errorMsg)
                    }
                }
            })
        }
    }
    
    
    // 显示获取验证码倒计时
    class func waitingAuthCode(button: UIButton!, start: Bool = false) {
        if button == nil { return } // 验证码的UI变化，如果没有button，则不会有变化
        
        let overTimer = button.tag
        if overTimer == 0 && start {
            button.tag = overTimeMax
        }
        else {
            button.tag = max(overTimer - 1, 0)
        }
        
        if button.tag == 0 {
            button.setTitle("获取验证码", forState: .Normal)
            button.backgroundColor = appThemeColor
            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            button.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
            button.enabled = true
        }
        else {
            button.setTitle("\(button.tag)S", forState: .Normal)
            button.backgroundColor = UIColor.whiteColor()
            button.setTitleColor(appThemeColor, forState: .Normal)
            button.enabled = false
            button.setNeedsLayout()
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(UInt64(1) * NSEC_PER_SEC)), dispatch_get_main_queue(), { () in
                self.waitingAuthCode(button)
            })
        }
    }
    @IBAction func loginBtnCli(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

