//
//  LyInputViewController.swift
//  QooccHealth
//
//  Created by Yu Liu on 15/4/21.
//  Copyright (c) 2015年 Liuyu. All rights reserved.
//

import UIKit

/**
*  //MARK: 带输入框的ViewController，抽象父类
*/
class LyInputViewController: UIViewController, LyInputViewDelegate {

    var lyInputView: LyInputView!    // 输入区域
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建输入框
        self.lyInputView = LyInputView(viewController: self)
        self.lyInputView.delegate = self
        self.view.addSubview(self.lyInputView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.lyInputView.delegate = self
        self.view.bringSubviewToFront(self.lyInputView) // 为了保证输入框在最上面
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.lyInputView.inputTextView.resignFirstResponder()
        self.lyInputView.delegate = nil
    }
    
//    //MARK: LyInputViewDelegate
//    func lyInputViewFrameChanged(view: LyInputView) {
//        println("输入动啦, \(view.frame)")
//    }
//    
//    func lyInputViewSend(view: LyInputView) {
//        println("发送啦")
//    }
    
}
