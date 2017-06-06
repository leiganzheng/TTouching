
//  LoginViewController.swift
//  QooccHealth
//
//  Created by Leiganzheng on 15/4/13.
//  Copyright (c) 2015年 Leiganzheng. All rights reserved.
//

import UIKit
import IQKeyboardManager

/**
*  @author Leiganzheng, 15-05-15 10:05:27
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
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var noLoginBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    var pass:UILabel!
    var user:UILabel!
    
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
//        self.remberPBtn.setTitle(NSLocalizedString("记住密码", tableName: "Localization",comment:"jj"), forState: .Normal)
//        self.loginBtn.setTitle(NSLocalizedString("登入", tableName: "Localization",comment:"jj"), forState: .Normal)
//        self.registerBtn.setTitle(NSLocalizedString("注册", tableName: "Localization",comment:"jj"), forState: .Normal)
//        self.noLoginBtn.setTitle(NSLocalizedString("无法登录", tableName: "Localization",comment:"jj"), forState: .Normal)
        RegisterViewController.configTextField(self.accountTextField)
        self.accountTextField.text = g_Account
        
        self.user = UILabel(frame: CGRectMake(0, 0, 70, 20))
//        user.text = "用户:"
        let usView = UIView.init(frame: CGRectMake(0, 0, 85, 20))
//        self.user.text = NSLocalizedString("用户", tableName: "Localization",comment:"jj") + ":"
    
        usView.addSubview(self.user)
        self.accountTextField.leftView = usView
        self.accountTextField.text = "T-Touching"
        self.accountTextField.leftViewMode = UITextFieldViewMode.Always
        self.accountTextField.enabled = false
        RegisterViewController.configTextField(self.passwordTextField)
        self.passwordTextField.secureTextEntry = true
        
        
        self.pass = UILabel(frame: CGRectMake(0, 0, 80, 20))
//        pass.text = "密码:"
        let usView1 = UIView.init(frame: CGRectMake(0, 0, 85, 20))
//        self.pass.text = NSLocalizedString("密码", tableName: "Localization",comment:"jj") + ":"
        usView1.addSubview(self.pass)
        self.passwordTextField.leftView = usView1
        self.passwordTextField.text = "T-Touching"
        self.passwordTextField.enabled = false
        
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
        
       
//         IQKeyboardManager.sharedManager().disableInViewControllerClass(self.classForCoder)
        // 如果有本地账号了，就自动登录
//        self.autoLogin()
        self.resflush()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default

        let l = QNTool.userLanguage()
        self.settingLangue(l as String)

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
//        QNNetworkTool.login(User: "jacky", Password: "123456") { (dict, error, errorMsg) in
//            
//        }
//        return
        let vc = GateWayListViewController.CreateFromStoryboard("Main") as! UIViewController
        self.navigationController?.pushViewController(vc, animated: true)
        return
//        if !self.checkAccountPassWord() {return}
//        if let id = self.accountTextField.text, let password = self.passwordTextField.text {
//            QNTool.showActivityView("正在登录...")
//            QNNetworkTool.login(User: "jacky", Password: "123456") { (dict, error, errorMsg) in
//                QNTool.hiddenActivityView()
//                if dict != nil {
//                    
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
        QNTool.setUserLanguage("en")
        self.resflush()
    }
    @IBAction func simplifiedAction(sender: AnyObject) {
        self.simplifiedBtn.setImage(UIImage(named: "navigation_Options_icon_s"), forState: .Normal)
        self.traditionalBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
        self.EngBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
        QNTool.setUserLanguage("zh-Hans")
        self.resflush()
    }
    @IBAction func traditionalAction(sender: AnyObject) {
        self.traditionalBtn.setImage(UIImage(named: "navigation_Options_icon_s"), forState: .Normal)
        self.simplifiedBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
        self.EngBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
        QNTool.setUserLanguage("zh-Hant")
        self.resflush()
    }
    func resflush(){
        self.remberPBtn.setTitle(NSLocalizedString("记住密码", tableName: "Localization",comment:"jj"), forState: .Normal)
        self.loginBtn.setTitle(NSLocalizedString("登入", tableName: "Localization",comment:"jj"), forState: .Normal)
        self.registerBtn.setTitle(NSLocalizedString("注册", tableName: "Localization",comment:"jj"), forState: .Normal)
        self.noLoginBtn.setTitle(NSLocalizedString("无法登录", tableName: "Localization",comment:"jj"), forState: .Normal)
        self.user.text = NSLocalizedString("用户", tableName: "Localization",comment:"jj") + ":"
        self.pass.text = NSLocalizedString("密码", tableName: "Localization",comment:"jj") + ":"
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
        
        if langue.hasPrefix("zh-Hans") {
            self.simplifiedBtn.setImage(UIImage(named: "navigation_Options_icon_s"), forState: .Normal)
            self.traditionalBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
            self.EngBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
            QNTool.setUserLanguage("zh-Hans")
            self.resflush()

        }else if langue.hasPrefix("zh-Hant"){
            self.traditionalBtn.setImage(UIImage(named: "navigation_Options_icon_s"), forState: .Normal)
            self.simplifiedBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
            self.EngBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
            QNTool.setUserLanguage("zh-Hant")
            self.resflush()

        }else if langue.hasPrefix("en"){
            self.EngBtn.setImage(UIImage(named: "navigation_Options_icon_s"), forState: .Normal)
            self.simplifiedBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
            self.traditionalBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
            QNTool.setUserLanguage("en")
            self.resflush()

        }else{
            self.simplifiedBtn.setImage(UIImage(named: "navigation_Options_icon_s"), forState: .Normal)
            self.traditionalBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
            self.EngBtn.setImage(UIImage(named: "navigation_Options_icon"), forState: .Normal)
            QNTool.setUserLanguage("zh-Hans")
            self.resflush()

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

}
