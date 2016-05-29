//
//  ChangeNickNameViewController.swift
//  QooccHealth
//
//  Created by leiganzheng on 15/6/2.
//  Copyright (c) 2015年 Juxi. All rights reserved.
//

import UIKit
import ReactiveCocoa
/**
*  @author leiganzheng, 15-06-2
*
*  修改用户昵称
*/
class ChangeNickNameViewController: UIViewController, UITextFieldDelegate {
    
    private var inputTextView: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "姓名"
        self.view.backgroundColor = defaultBackgroundGrayColor
        
        self.inputTextView = UITextField(frame: CGRectMake(0, 10, self.view.frame.width, 50))
        self.inputTextView.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: inputTextView.bounds.height))
        self.inputTextView.leftViewMode = UITextFieldViewMode.Always;
        self.inputTextView.backgroundColor = UIColor.whiteColor()
        self.inputTextView.returnKeyType = UIReturnKeyType.Done
        self.inputTextView.placeholder = g_doctor?.doctorName ?? "姓名"
        self.inputTextView.delegate = self
        self.inputTextView.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.inputTextView.layer.masksToBounds = true
        self.inputTextView.layer.borderColor = defaultLineColor.CGColor
        self.inputTextView.layer.borderWidth = 0.5
        self.inputTextView.becomeFirstResponder()
        self.view.addSubview(self.inputTextView)
        let tips = UITextView(frame: CGRectMake(10, 70, self.view.frame.width - 20, 30))
        tips.backgroundColor = UIColor.clearColor()
        tips.textColor = UIColor(white: 150/255, alpha: 1)
        tips.font = UIFont.systemFontOfSize(13)
        tips.text = "姓名与“提现”有关，请保证真实，慎重修改。"
        self.view.addSubview(tips)
        // 保存按钮
        let saveItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        saveItem.tintColor = appThemeColor
        saveItem.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            if let strongSelf = self {
                self!.view.endEditing(true)
                strongSelf.textFieldShouldReturn(strongSelf.inputTextView)
            }
            return RACSignal.empty()
        })
        self.navigationItem.rightBarButtonItem = saveItem
        
        // 取消按钮
        let cancelItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        cancelItem.tintColor = defaultGrayColor
        cancelItem.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            self!.view.endEditing(true)
            self?.navigationController?.popViewControllerAnimated(true)
            return RACSignal.empty()
        })
        self.navigationItem.leftBarButtonItem = cancelItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let res = ChangeNickNameViewController.updateDeviceName(textField.text, viewController: self)
        if !res {
            textField.text = nil
        }
        return res
    }

    //MARK:- Private Method
   
    // 更新昵称
    class func updateDeviceName(name: String?, viewController: UIViewController? = nil) -> Bool {
        var nickName = name as NSString?
        nickName = nickName?.stringByReplacingOccurrencesOfString(" ", withString: "")
        if nickName == nil || nickName!.length == 0 {
            QNTool.showPromptView("请输入昵称")
            return false
        }
        
        // 限制输入范围在8以内
        if nickName!.length > 8 {
            QNTool.showPromptView("昵称长度不得大于8个字")
            return true
        }
        
        QNTool.showActivityView(nil, inView: viewController?.view)
        QNNetworkTool.doctorRecolumn("doct_name", columnValue: nickName as! String) { (dictionry, error, string) -> Void in
            QNTool.hiddenActivityView()
            if dictionry?["errorCode"] as? String == "0"  {
                QNTool.showPromptView("保存成功", nil)
                g_doctor?.doctorName = nickName?.substringFromIndex(0)
                viewController?.navigationController?.popViewControllerAnimated(true)
            }else {
                QNTool.showErrorPromptView(nil, error: error, errorMsg: dictionry?["errorMsg"] as? String)
            }
        }
        return true
    }
}
