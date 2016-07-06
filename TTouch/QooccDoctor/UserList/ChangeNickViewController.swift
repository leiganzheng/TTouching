//
//  ChangeNickNameViewController.swift
//  QooccHealth
//
//  Created by leiganzheng on 15/6/2.
//  Copyright (c) 2015年 Juxi. All rights reserved.
//

import UIKit
import ReactiveCocoa

typealias callBlock = (AnyObject) -> Void

class ChangeNickViewController: UIViewController, UITextFieldDelegate {
    
    private var inputTextView: UITextField!
    var flagstr:String?
    var bock:callBlock?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "标签"
        self.view.backgroundColor = defaultBackgroundGrayColor
        
        self.inputTextView = UITextField(frame: CGRectMake(0, 120, self.view.frame.width, 50))
        self.inputTextView.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: inputTextView.bounds.height))
        self.inputTextView.leftViewMode = UITextFieldViewMode.Always;
        self.inputTextView.backgroundColor = UIColor.whiteColor()
        self.inputTextView.returnKeyType = UIReturnKeyType.Done
        self.inputTextView.placeholder = self.flagstr
        self.inputTextView.delegate = self
        self.inputTextView.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.inputTextView.layer.masksToBounds = true
        self.inputTextView.layer.borderColor = defaultGrayColor.CGColor
        self.inputTextView.layer.borderWidth = 0.5
        self.inputTextView.becomeFirstResponder()
        self.view.addSubview(self.inputTextView)
        // 保存按钮
        let saveItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        saveItem.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            if let strongSelf = self {
                self!.view.endEditing(true)
                var nickName = strongSelf.inputTextView.text as NSString?
                nickName = nickName?.stringByReplacingOccurrencesOfString(" ", withString: "")
                if nickName == nil || nickName!.length == 0 {
                    QNTool.showPromptView("请输入标签")
                    
                }else{
                    // 限制输入范围在8以内
                    if nickName!.length > 8 {
                        QNTool.showPromptView("昵称长度不得大于8个字")
                        
                    }else{
                        self?.bock!(nickName!)
                        self?.navigationController?.popViewControllerAnimated(true)
                    }
                }
                

            }
            return RACSignal.empty()
        })
        self.navigationItem.rightBarButtonItem = saveItem
        self.configBackButton()
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
