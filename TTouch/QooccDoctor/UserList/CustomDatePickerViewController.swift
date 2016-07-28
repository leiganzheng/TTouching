//
//  CustomDatePickerViewController.swift
//  QooccHealth
//
//  Created by 肖小丰 on 15/4/15.
//  Copyright (c) 2015年 Lei. All rights reserved.
//

import UIKit

class CustomDatePickerViewController: UIViewController, QNInterceptorProtocol {

    
    typealias dateBack = (NSString)->Void

    private(set) var datePicker:UIDatePicker?
    private(set) var headerView:UIView?
    private(set) var kbuttonWidth:CGFloat = 50.0
    private(set) var kbuttonHeight:CGFloat = 44.0
    var datePickerFinish: dateBack?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- Delegate or DataSource
    
    //MARK:- NSNotification Method
    
    //MARK:- Action Method
    
    //MARK:- Private Method
    private func buildUI(){
        self.datePicker = UIDatePicker(frame: CGRectMake(0, 45, self.view.bounds.size.width, 320))
        self.datePicker!.backgroundColor = UIColor.whiteColor()
        self.datePicker?.datePickerMode = .Date
        
        self.headerView = UIView(frame: CGRectMake(0,self.view.bounds.size.height - 248, self.view.bounds.size.width, kbuttonHeight+1+self.datePicker!.frame.size.height))
        self.headerView!.backgroundColor = UIColor.whiteColor()
        
        let line = UILabel(frame: CGRectMake(0, 44, self.view.bounds.size.width, 1))
        line.backgroundColor = UIColor.lightGrayColor()
        
        let cancel = UIButton(frame:  CGRectMake(0, 0, kbuttonWidth, kbuttonHeight))
        cancel.backgroundColor = UIColor.whiteColor()
        cancel.setTitle("取消", forState: UIControlState.Normal)
        cancel.setTitleColor(UIColor(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 1), forState: UIControlState.Normal)
        cancel.addTarget(self, action: #selector(CustomDatePickerViewController.cancelButtonClicked), forControlEvents: UIControlEvents.TouchUpInside)
        
        let confirm = UIButton(frame: CGRectMake(self.view.bounds.size.width-kbuttonWidth, 0, kbuttonWidth, kbuttonHeight))
        confirm.backgroundColor = UIColor.whiteColor()
        confirm.setTitle("确定", forState: UIControlState.Normal)
        confirm.setTitleColor(UIColor(red: 255/255.0, green: 139/255.0, blue: 139/255.0, alpha: 1), forState: UIControlState.Normal)
        confirm.addTarget(self, action: #selector(CustomDatePickerViewController.confirmButtonClicked), forControlEvents: UIControlEvents.TouchUpInside)

        self.headerView?.addSubview(line)
        self.headerView?.addSubview(cancel)
        self.headerView?.addSubview(confirm)
        self.headerView?.addSubview(self.datePicker!)
        
        self.view.addSubview(self.headerView!)
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        
        let temp = self.headerView!.center
        self.headerView!.center = CGPointMake(self.headerView!.center.x, 640);
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.headerView!.center = temp
        })
    }
    
    func removeDatePicker(dateString:String){
      UIView.animateWithDuration(0.2, animations: { () -> Void in
        self.headerView!.center = CGPointMake(self.headerView!.center.x, 640);
      }) { (complete) -> Void in
        self.datePickerFinish!(dateString)
        }
    }
    func cancelButtonClicked(){
        self.removeDatePicker("")
    }
    func confirmButtonClicked(){
        let dateFormatter = NSDateFormatter()
        // 为日期格式器设置格式字符串
        dateFormatter.dateFormat = "yyyy-MM-dd"
        // 使用日期格式器格式化日期、时间
        let dateString = dateFormatter.stringFromDate(self.datePicker!.date)
        self.removeDatePicker(dateString)
    }
}
