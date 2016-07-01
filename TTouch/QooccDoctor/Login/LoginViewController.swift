
//  LoginViewController.swift
//  QooccHealth
//
//  Created by LiuYu on 15/4/13.
//  Copyright (c) 2015年 Liuyu. All rights reserved.
//

import UIKit

/**
*  @author LiuYu, 15-05-15 10:05:27
*
*  //MARK:- 用户登录
*/
class LoginViewController: UIViewController, QNInterceptorNavigationBarHiddenProtocol, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var traditionalBtn: UIButton!
    @IBOutlet weak var simplifiedBtn: UIButton!
    @IBOutlet weak var EngBtn: UIButton!
    @IBOutlet weak var remberPBtn: UIButton!
    @IBOutlet weak var inHomeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = defaultBackgroundGrayColor
        self.navigationController?.navigationBar.translucent = false // 关闭透明度效果
        // 让导航栏支持向右滑动手势
        QNTool.addInteractive(self.navigationController)
        QNTool.configViewLayer(self.headerView)
        
        self.imageView.image = UIImage(named: "LOGO")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.imageView.tintColor = appThemeColor
        self.imageView.tintAdjustmentMode = .Normal
        
        RegisterViewController.configTextField(self.accountTextField)
        self.accountTextField.text = g_Account
        
        let lb = UILabel(frame: CGRectMake(0, 0, 40, 20))
        lb.text = "用户"
        self.accountTextField.leftView = lb

        RegisterViewController.configTextField(self.passwordTextField)
        self.passwordTextField.secureTextEntry = true
        
        
        let pass = UILabel(frame: CGRectMake(0, 0, 40, 20))
        pass.text = "密码"
        self.passwordTextField.leftView = pass

        
        let passwordImageView = UIImageView(frame: CGRectMake(10, 0, 40, 20))
        passwordImageView.contentMode = UIViewContentMode.Center
        passwordImageView.image = UIImage(named: "Login_Password")
//        self.passwordTextField.leftView = passwordImageView

        // 键盘消失
        let tap = UITapGestureRecognizer()
        tap.rac_gestureSignal().subscribeNext { [weak self](tap) -> Void in
            self?.view.endEditing(true)
        }
        self.view.addGestureRecognizer(tap)
        
        let lArray = NSUserDefaults.standardUserDefaults().objectForKey("AppleLanguages")
        let currentLanguage = lArray?.objectAtIndex(0) as! String
        self.settingLangue(currentLanguage)
        // 如果有本地账号了，就自动登录
//        self.autoLogin()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.returnKeyType == .Next {
            self.passwordTextField.becomeFirstResponder()
        }
        else if textField.returnKeyType == .Done {
            self.login()
        }
        return false
    }
    
    // MARK: 登录
    @IBAction func login(sender: AnyObject) {
        self.login()
    }
    
    func login() {
        let vc = GateWayListViewController.CreateFromStoryboard("Main") as! UIViewController
        self.navigationController?.pushViewController(vc, animated: true)
        return
//        if !self.checkAccountPassWord() {return}
//        if let id = self.accountTextField.text, let password = self.passwordTextField.text {
            QNTool.showActivityView("正在登录...")
//            QNNetworkTool.login(Id: id, Password: password) { (doctor, error, errorMsg) -> Void in
//                QNTool.hiddenActivityView()
//                if doctor != nil {
//                    if self.checkRegisterEditInfo(doctor!) {
//                        //进入主界面
////                        let vc = (UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController())!
//                         let vc = GateWayListViewController.CreateFromStoryboard("Main") as! UIViewController
//                        self.navigationController?.pushViewController(vc, animated: true)
////                        QNTool.enterRootViewController(vc, animated: true)
//                    } else {
//                        // 未填写注册信息
//                        let vc = EditInformationViewController.CreateFromStoryboard("Login") as! EditInformationViewController
//                        vc.finished = { () -> Void in
//                            QNNetworkTool.login(Id: id, Password: password) { (doctor, error, errorMsg) -> Void in
//                                QNTool.hiddenActivityView()
//                                if doctor != nil {
////                                    let vc = (UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController())!
//                                    let vc = GateWayListViewController.CreateFromStoryboard("Main") as! UIViewController
//                                    QNTool.enterRootViewController(vc, animated: true)
//                                }
//                                else {
//                                    QNTool.showErrorPromptView(nil, error: error, errorMsg: errorMsg)
//                                }
//                            }
//                        }
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    }
//                }
//                else {
//                    QNTool.showErrorPromptView(nil, error: error, errorMsg: errorMsg)
//                }
//            }
//        }
    }
    
    // MARK: 登录，并把accoutn和password写入的页面上
    func login(account: String, password: String) {
        self.accountTextField.text = account
        self.passwordTextField.text = password
        self.login()
    }
    
    // MARK: 自动登录，获取本机保存的账号密码进行登录
    func autoLogin() {
        if let account = g_Account, password = g_Password {
            self.login(account, password: password)
        }
    }

    
    @IBAction func inhomeAction(sender: AnyObject) {
        let btn = sender as! UIButton
        btn.selected = !sender.selected
        let icon = (btn.selected==true) ? "navigation_Options_icon_s" : "navigation_Options_icon"
        btn.setImage(UIImage(named: icon), forState: .Normal)

    }
    @IBAction func remberAction(sender: AnyObject) {
        let btn = sender as! UIButton
        btn.selected = !sender.selected
        let icon = (btn.selected==true) ? "navigation_Options_icon_s" : "navigation_Options_icon"
        btn.setImage(UIImage(named: icon), forState: .Normal)
    }
    @IBAction func engAction(sender: AnyObject) {
        self.EngBtn.setImage(UIImage(named: "navigation_Options_icon_s"), forState: .Normal)
        self.simplifiedBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
        self.traditionalBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
    }
    @IBAction func simplifiedAction(sender: AnyObject) {
        self.simplifiedBtn.setImage(UIImage(named: "navigation_Options_icon_s"), forState: .Normal)
        self.traditionalBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
        self.EngBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
    }
    @IBAction func traditionalAction(sender: AnyObject) {
        self.traditionalBtn.setImage(UIImage(named: "navigation_Options_icon_s"), forState: .Normal)
        self.simplifiedBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
        self.EngBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
    }

    @IBAction func loginAction(sender: AnyObject) {
        let actionSheet = UIActionSheet(title: nil, delegate: nil, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
        actionSheet.addButtonWithTitle("找回登入密码")
        actionSheet.rac_buttonClickedSignal().subscribeNext({ (index) -> Void in
            if let indexInt = index as? Int {
                switch indexInt {
                case 1:
                    self.navigationController?.pushViewController(ForgetPasswordViewController.CreateFromStoryboard("Login") as! UIViewController, animated: true)
                default: break
                }
            }
        })
        actionSheet.showInView(self.view)
    }
    private func settingLangue(langue: String){
//        zh-Hans-CN、zh-Hant-CN、en-CN
        if langue == "zh-Hans-CN" {
            self.simplifiedBtn.setImage(UIImage(named: "navigation_Options_icon_s"), forState: .Normal)
            self.traditionalBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
            self.EngBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)

        }else if langue == "zh-Hant-CN" {
            self.traditionalBtn.setImage(UIImage(named: "navigation_Options_icon_s"), forState: .Normal)
            self.simplifiedBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
            self.EngBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
        }else{
            self.EngBtn.setImage(UIImage(named: "navigation_Options_icon_s"), forState: .Normal)
            self.simplifiedBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
            self.traditionalBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
        }
    }
    // 判断输入的合法性
    //MARK:TODO
    private func checkAccountPassWord() -> Bool {
        
        if (self.accountTextField.text?.characters.count == 0 && self.passwordTextField.text?.characters.count == 0) {
            QNTool.showPromptView("请输入账号与密码")
            self.accountTextField.becomeFirstResponder()
            return false
        }else if(self.accountTextField.text?.characters.count == 0) {
            QNTool.showPromptView("请输入密码")
            self.passwordTextField.becomeFirstResponder()
            return false

        }else if (self.passwordTextField.text?.characters.count == 0){
            QNTool.showPromptView("请输入账号")
            self.accountTextField.becomeFirstResponder()
            return false
        }
        return true
        
    }
//    // 判断注册时是否填写信息
//    func checkRegisterEditInfo(doctor : QD_Doctor) -> Bool {
//        if doctor.jobTitle == nil || doctor.jobTitle == "" {
//            return false
//        } else if doctor.belongHospital == nil || doctor.belongHospital == "" {
//            return false
//        } else if doctor.department_hospital == nil || doctor.department_hospital == "" {
//            return false
//        }
//        return true
//    }
}
