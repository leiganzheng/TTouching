//
//  SettingViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 15/9/7.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit
import ReactiveCocoa

class SettingViewController: UIViewController,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {

    /**
    // MARK: 列表内容
    */
    private enum Contents: Int {
        case PushMSg = 0    // 推送消息
        case Phone = 1          // 电话按钮
        case ChangePassword = 2 // 修改密码
        case Version = 3        // 当前版本
        static let Count = 4 // 总数
        
        // 对应的图片
        var image: UIImage? {
            return UIImage(named: { () -> String in
                switch self {
                case .PushMSg: return "UserCenter_Manager"
                case .ChangePassword: return "UserCenter_ChangePW"
                case .Version: return "UserCenter_Version"
                case .Phone: return "UserCenter_Phone"
                }
                }())
        }
        
        // 对应的标题
        var title: String {
            switch self {
            case .PushMSg: return "推送消息"
            case .ChangePassword: return "修改密码"
            case .Version: return "当前版本"
            case .Phone: return "拨号功能"
            }
        }
    }
    
    var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设置"
        self.navigationController?.navigationBar.translucent = false // 关闭透明度效果
        // 让导航栏支持向右滑动手势
        QNTool.addInteractive(self.navigationController)
        self.view.backgroundColor = defaultBackgroundGrayColor
        // 内容
        self.tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Grouped)
        self.tableView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth , .FlexibleHeight]
        self.tableView.backgroundColor = defaultBackgroundGrayColor
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        // 提交预约
        let footView = UIView(frame: CGRectMake(0, 0, self.view.bounds.size.width, 100))
        let button:UIButton = UIButton(frame: CGRectMake(15, 30, self.view.bounds.size.width-30, 40))
        button.setTitle("注销", forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(14)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.backgroundColor = appThemeColor
        button.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            if let strongSelf = self {
                strongSelf.logOutButtonAction()
            }
            return RACSignal.empty()
            });
        footView.addSubview(button)
        QNTool.configViewLayer(button)
        self.tableView.tableFooterView = footView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSource, UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 0.01*COEFFICIENT_OF_HEIGHT_ZOOM :  10.0*COEFFICIENT_OF_HEIGHT_ZOOM
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 28.0*COEFFICIENT_OF_HEIGHT_ZOOM :  0.01*COEFFICIENT_OF_HEIGHT_ZOOM
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let content = Contents(rawValue: section) where content == .PushMSg {
            return "请在iPhone的“设置” - “通知”中进行修改。"
        }
        return nil
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let content = Contents(rawValue: indexPath.section) {
            let cellId = "UserCenter_"
            var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellId) 
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                QNTool.configTableViewCellDefault(cell)
                cell.backgroundColor = UIColor.whiteColor()
                cell.contentView.backgroundColor = UIColor.whiteColor()
                
            }
            
            cell.imageView?.image = content.image
            cell.textLabel?.text = content.title
            
            switch content {
            case .ChangePassword:
                cell.selectionStyle = UITableViewCellSelectionStyle.Default
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.accessoryView = nil
            case .Version:
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.accessoryType = UITableViewCellAccessoryType.None
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
                label.text = APP_VERSION
                label.textColor = defaultLineColor
                label.textAlignment = .Right
                cell.accessoryView = label
            case .Phone:
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.accessoryType = UITableViewCellAccessoryType.None
                let phoneSwitch = UISwitch(frame: CGRectMake(0, 0, 20, 10))
                phoneSwitch.onTintColor = appThemeColor
                cell?.accessoryView = phoneSwitch
                phoneSwitch.on = g_AllowShowPhone
                phoneSwitch.rac_signalForControlEvents(UIControlEvents.ValueChanged).subscribeNext({ (sender) -> Void in
                    if let notificationSwitch = sender as? UISwitch {
                        g_AllowShowPhone = notificationSwitch.on
                        //                        QNPhoneTool.hidden = !g_AllowShowPhone
                    }
                })
                cell.accessoryView = phoneSwitch
            case .PushMSg:
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.accessoryType = UITableViewCellAccessoryType.None
                let pushLabel = UILabel(frame: CGRectMake(0, 0, 20, 10))
                pushLabel.text = self.checkIsAllowPush() ? "已开启" : "已关闭"
                pushLabel.sizeToFit()
                pushLabel.textColor = UIColor(white: 200/255.0, alpha: 1)
                pushLabel.backgroundColor = UIColor.clearColor()
                pushLabel.font = UIFont.systemFontOfSize(16)
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell?.accessoryView = pushLabel
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let content = Contents(rawValue: indexPath.section) {
            switch content {
            case .ChangePassword:
                self.navigationController?.pushViewController(ChangePasswordViewController.CreateFromStoryboard("Login") as! ChangePasswordViewController, animated: true)
            case .Version,.PushMSg, .Phone: break
                
            }
        }
    }
    
    // MARK: 退出登录
    private func logOutButtonAction() {
        let alertView = UIAlertView(title: "", message: "确认退出账号？", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles: "退出登录")
        alertView.rac_buttonClickedSignal().subscribeNext { (index) -> Void in
            if let indexInt = index as? Int where indexInt == 1 {
                EaseMob.sharedInstance().chatManager.asyncLogoffWithUnbindDeviceToken(true, completion: { (dict, error) -> Void in
                    if error == nil{
                        
                    }else{
                        QNTool.showPromptView("环信退出登录失败")
                    }
                    }, onQueue: nil)
                QNNetworkTool.logout()
            }
        }
        alertView.show()
    }
    //检测推送设置是否打开
    func checkIsAllowPush() -> Bool {
        var allowPush = false
        if UIApplication.sharedApplication().respondsToSelector("isRegisteredForRemoteNotifications") {
            allowPush = UIApplication.sharedApplication().currentUserNotificationSettings()!.types != UIUserNotificationType.None
        }
        else {
            allowPush = UIApplication.sharedApplication().enabledRemoteNotificationTypes() != .None
        }
        return allowPush
    }
}
