//
//  NewClockViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/20.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit
import ReactiveCocoa

class NewClockViewController: UIViewController,QNInterceptorProtocol {

    private(set) var datePicker:UIDatePicker?
    override func viewDidLoad() {
        super.viewDidLoad()

        let searchButton:UIButton = UIButton(frame: CGRectMake(0, 0, 50, 40))
        searchButton.setTitle("保存", forState: .Normal)
        searchButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            self?.dismissViewControllerAnimated(true, completion: nil)
            return RACSignal.empty()
            })
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)
        
        self.configBackButton()
        self.datePicker = UIDatePicker(frame: CGRectMake(0, 45, self.view.bounds.size.width, 320))
        self.datePicker!.backgroundColor = UIColor.whiteColor()
        self.datePicker?.datePickerMode = .DateAndTime
        self.view.addSubview(self.datePicker!)
//        self.customDate?.datePickerFinish = { (dateString)->Void in
//            if dateString != ""{
//                self.textField4.text = dateString as String
//            }
//        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
