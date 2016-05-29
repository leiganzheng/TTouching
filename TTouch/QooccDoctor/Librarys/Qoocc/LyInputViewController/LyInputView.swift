//
//  LyInputView.swift
//  QooccHealth
//
//  Created by Yu Liu on 15/4/21.
//  Copyright (c) 2015年 Liuyu. All rights reserved.
//

import UIKit

/**
*  //MARK:输入框UI封装的回掉
*/
@objc protocol LyInputViewDelegate: NSObjectProtocol {
    optional func lyInputViewFrameChanged(view: LyInputView) -> Void   // 位置发生改变
    optional func lyInputViewSend(view: LyInputView)           // 发送消息
}


/**
*  //MARK:输入框UI封装
*  输入框，请使用 init(viewController: UIViewController) 方法初始化，
*  只对UI做了简单的逻辑封装
*/
class LyInputView: UIView, UITextFieldDelegate {
    
    //MARK: 边框的偏移距离
    private struct kOffset {
        static let Top: CGFloat = 10
        static let Left: CGFloat = 16
        static let Bottom: CGFloat = 10
        static let Right: CGFloat = 16
        
        static let Height: CGFloat = 30
        static func totalHeight() -> CGFloat {
            return kOffset.Top + kOffset.Bottom + kOffset.Height
        }
    }
    
    weak var cusViewController: UIViewController?
    weak var delegate: LyInputViewDelegate?
    var textMaxLength: Int = 0                      // 文本输入长度限制，默认是0，没有限制
    private(set) var inputBgView: UIView!           // 文本输入框背景
    private(set) var inputTextView: UITextField!     // 文本输入框
    private(set) var sendButton: UIButton!          // 发送按钮
    var content: String {
        return self.inputTextView.text!
    }
    // 重载Frame，实现Frame修改时候的回掉
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            self.delegate?.lyInputViewFrameChanged?(self)
        }
    }
    
    
    convenience init(viewController: UIViewController/*输入框必须依附在一个ViewController上*/) {
        let height: CGFloat = kOffset.totalHeight()
        let frame = CGRect(x: 0, y: viewController.view.bounds.height - height, width: viewController.view.bounds.width, height: height)
        self.init(frame: frame)
        self.cusViewController = viewController
        self.autoresizingMask = [UIViewAutoresizing.FlexibleTopMargin , .FlexibleWidth]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.__setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.__setup()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // 配置UI的样式，如果需要统一修改封装颜色，请在这个方法中修改
    private func __setup() {
        self.autoresizesSubviews = false
        self.backgroundColor = UIColor(white: 1, alpha: 1)
        
        // 分割线
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 0.5))
        lineView.backgroundColor = UIColor(white: 224/255.0, alpha: 1)
        self.addSubview(lineView)
        
        // 整个输入区域
        let bgView = UIView(frame: UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(kOffset.Top, kOffset.Left, kOffset.Bottom, kOffset.Right)))
        bgView.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
        bgView.layer.borderColor = UIColor(white: 224/255.0, alpha: 1).CGColor
        bgView.layer.borderWidth = 1
        bgView.layer.cornerRadius = 3
        bgView.layer.masksToBounds = true
        self.addSubview(bgView)
        self.inputBgView = bgView
        
        // 发送按钮
        let sendButtonWidth: CGFloat = 50
        let sendButton = UIButton(frame: CGRect(x: CGRectGetMaxX(bgView.frame) - sendButtonWidth, y: bgView.frame.origin.y, width: sendButtonWidth, height: bgView.bounds.height))
        sendButton.layer.cornerRadius = 3
        sendButton.backgroundColor = appThemeColor
        sendButton.autoresizingMask = .FlexibleLeftMargin
        sendButton.setTitle("发送", forState: .Normal)
        sendButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        sendButton.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        sendButton.addTarget(self, action: Selector("onSend:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(sendButton)
        self.sendButton = sendButton
        
        // 输入框
        let inputTextView = UITextField(frame: CGRect(x: 0, y: 0, width: bgView.bounds.width - sendButtonWidth, height: bgView.bounds.height))
        inputTextView.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: inputTextView.bounds.height))
        inputTextView.leftViewMode = UITextFieldViewMode.Always;
        inputTextView.delegate = self
        inputTextView.backgroundColor = UIColor(white: 247/255.0, alpha: 1)
        inputTextView.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
        inputTextView.returnKeyType = UIReturnKeyType.Done
        inputTextView.text = ""
        bgView.addSubview(inputTextView)
        self.inputTextView = inputTextView
        inputTextView.sizeThatFits(CGSize(width: inputTextView.bounds.width, height: CGFloat.max))
        // 开启对键盘事件的监听
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //MARK: 发送消息
    func onSend(sender: UIButton?) {
        self.delegate?.lyInputViewSend?(self)
        self.inputTextView?.text = ""
    }
    
    //MARK: UITextViewDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        // 监听键盘Frame的改变
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidChangeFrame:"), name: UIKeyboardDidChangeFrameNotification, object: nil)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // 释放键盘Frame的改变
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidChangeFrameNotification, object: nil)
        if self.viewController != nil {
            var frame = self.frame
            frame.origin.y = self.viewController!.view.bounds.height - self.bounds.height
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.frame = frame
            })
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let textTemp = NSMutableString(string: textField.text!)
        textTemp.replaceCharactersInRange(range, withString: string)
        
        // 限制举报内容长度
        return !((self.textMaxLength != 0) && (textTemp.length > self.textMaxLength))
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.onSend(nil)
        return false
    }

    //MARK: 键盘相关通知
    func keyboardWillShow(notification: NSNotification) {
        self.keyboardDidChangeFrame(notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.keyboardDidChangeFrame(notification)
    }
    
    func keyboardDidChangeFrame(notification: NSNotification) {
        if let info = notification.userInfo,
        let keyboardFrame = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue,
        let keyWindow = UIApplication.sharedApplication().keyWindow where self.viewController != nil {
            var frame = self.frame
            frame.origin.y = keyWindow.convertPoint(keyboardFrame.origin, toView: self.viewController!.view).y - self.bounds.height
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.frame = frame
            })
        }
    }
    
    //MARK: 清除文本输入框的内容
    func cleanText() {
        self.inputTextView.text = nil
    }
    
    
}
