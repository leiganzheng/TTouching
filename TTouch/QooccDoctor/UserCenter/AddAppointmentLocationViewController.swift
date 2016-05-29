//
//  AddAppointmentLocationViewController.swift
//  QooccDoctor
//
//  Created by haijie on 15/11/24.
//  Copyright (c) 2015年 juxi. All rights reserved.
//

import UIKit
import ReactiveCocoa

class AddAppointmentLocationViewController: UIViewController,QNInterceptorProtocol,UIGestureRecognizerDelegate,UITextViewDelegate{
    private var inputTextView: UITextView!
    var countLbl : UILabel!
    var isFirst = true
    
    var id : String!
    var place : String!
    var editFinished: ((str:String) -> Void)? //编辑
    var addFinished: (() -> Void)? //新建
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = id == nil ? "新建地点" : "编辑地点"
        self.isFirst = place == nil ? true : false
        self.view.backgroundColor = defaultBackgroundGrayColor
        self.inputTextView = UITextView(frame: CGRectMake(0, 10, self.view.frame.width , 110))
        self.inputTextView.backgroundColor = UIColor.whiteColor()
        self.inputTextView.returnKeyType = UIReturnKeyType.Done
        self.inputTextView.text = id == nil ? "输入面对面咨询地点" : place
        self.inputTextView.textColor = id == nil ? UIColor.grayColor() : UIColor.blackColor()
        self.inputTextView.font = UIFont.systemFontOfSize(15)
        self.inputTextView.layer.masksToBounds = true
        self.inputTextView.layer.borderColor = defaultLineColor.CGColor
        self.inputTextView.layer.borderWidth = 0.5
        self.inputTextView.delegate = self
        self.inputTextView.returnKeyType = UIReturnKeyType.Default
        self.inputTextView.textContainerInset = UIEdgeInsetsMake(16, 16, 24, 16)
        self.view.addSubview(self.inputTextView)
        
        self.countLbl = UILabel(frame: CGRectMake(self.view.frame.width - 56 , CGRectGetMaxY(self.inputTextView.frame) - 18 , 40, 12))
        _ =  ("输入面对面咨询地点" as NSString).length
        self.countLbl.textAlignment = .Right
        let tmpCount = id == nil ?  50 : (50 - NSString(string: place).length)
        self.countLbl.text = "\(tmpCount)/50"
        self.countLbl.font = UIFont.systemFontOfSize(12)
        self.countLbl.textColor = appThemeColor
        self.view.addSubview(self.countLbl)
        let imgV = UIImageView(frame: CGRectMake(self.view.frame.width - 70,  CGRectGetMaxY(self.inputTextView.frame) - 18, 12, 12))
        imgV.image = UIImage(named: "userCenter_appointment_limitword")
        self.view.addSubview(imgV)
        // 保存按钮
        let saveItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        saveItem.tintColor = appThemeColor
        saveItem.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            if let _ = self {
                self!.view.endEditing(true)
                if self!.checkData() {
                    QNNetworkTool.saveConsultAddress(self!.id ?? "0", address: self!.inputTextView.text) { (succeed, error, string) -> Void in
                        if succeed != nil && succeed! {
                            QNTool.showPromptView("保存成功")
                            if self!.editFinished != nil {
                                self?.editFinished!(str: self!.inputTextView.text)
                            } else if self!.addFinished != nil {
                                self?.addFinished!()
                            }
                            self?.navigationController?.popViewControllerAnimated(true)
                        } else {
                            QNTool.showErrorPromptView(nil, error: error, errorMsg: string)
                        }
                    }
                }
            }
            return RACSignal.empty()
            })
        self.navigationItem.rightBarButtonItem = saveItem

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
    //MARK:- UItextViewdDelegate
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if isFirst {
             textView.text = ""
            isFirst = false
            self.inputTextView.textColor = UIColor.blackColor()
        }
        return true
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true;
    }
    func textViewDidChange(textView: UITextView) {
        let mulStr = NSMutableString(string: textView.text)
        let count = (50 - mulStr.length).description
        self.countLbl.text = "\(count)/50"
    }
    //MARK:-PrivateMethod
    func checkData() -> Bool {
        let tmp = self.inputTextView.text
        if self.isFirst || tmp == nil || NSString(string: tmp).length == 0 {
            QNTool.showPromptView("请输入地点")
            return false
        } else if (50 - NSString(string: tmp).length) < 0 {
            QNTool.showPromptView("地点字数超过50字")
            return false
        }
        return true
    }
}
