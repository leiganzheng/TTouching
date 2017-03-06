//
//  TimeMannageViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/7.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa

class TimeMannageViewController: UIViewController,QNInterceptorProtocol,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var settLB: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    var data:NSMutableArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.data = NSMutableArray()
        //Right
        let rightBarButton = UIView(frame: CGRectMake(0, 0, 40, 40)) //（在外层在包一个View，来缩小点击范围，不然和菜单栏在一起和容易误点）
        let searchButton:UIButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        searchButton.setImage(UIImage(named: "time"), forState: UIControlState.Normal)
        searchButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            let vc = NewClockViewController.loadFromStroyboardWithTargetAlarm(nil)
            vc.bock =  {(Alarm) -> Void in
            
                (self?.myTableView.reloadData())!
            }
            self?.presentViewController(UINavigationController(rootViewController:vc ), animated: true, completion: nil)
            return RACSignal.empty()
            })
        rightBarButton.addSubview(searchButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        
        self.myTableView.backgroundColor = UIColor.clearColor()
        self.myTableView.separatorStyle = .SingleLine
        self.view.backgroundColor = defaultBackgroundGrayColor
        self.data = DCAlarmManager.sharedInstance.alarmArray //swift的数组是struct，是值类型，写的时候要特别注意
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        for alarm in self.data {
            let tempAlarm = alarm as! DCAlarm
            if tempAlarm.alarmOn {
                tempAlarm.turnOnAlarm()
            }else{
                tempAlarm.turnOffAlarm()
            }
             DCAlarmManager.sharedInstance.save()
        }
        self.myTableView.reloadData()
    }
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.data.count == 0 ? 72 : 132
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count == 0 ? 1 : self.data.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.data.count == 0 {
            let cellIdentifier = "Cell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            }
            tableView.separatorStyle = .None
            for v in cell.contentView.subviews {
                if  v is UILabel && v.tag == 100{
                    v.removeFromSuperview()
                }
            }
            let lb = UILabel(frame: CGRectMake(screenWidth/2-100,0,200,72))
            lb.tag = 100
            lb.text = NSLocalizedString("暂无数据,下拉重试", tableName: "Localization",comment:"jj")
            lb.textAlignment = .Center
            cell.contentView.addSubview(lb)
            return cell
        }else{
            let cellId = "cell"
            var cell: ClockTableViewCell! = self.myTableView.dequeueReusableCellWithIdentifier(cellId) as! ClockTableViewCell
            if cell == nil {
                cell = ClockTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            }
            cell.contentView.backgroundColor = UIColor.whiteColor()
            let alarm = self.data?.objectAtIndex(indexPath.row) as? DCAlarm
            let dateFormatter = NSDateFormatter()
            dateFormatter.locale = NSLocale(localeIdentifier: "zh_CN")
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.dateFormat = "HH:mm"
            if let date = alarm!.alarmDate {
                cell.time.setTitle(dateFormatter.stringFromDate(date), forState: .Normal)
            }
            cell.selectedBtn.addTarget(self, action: #selector(TimeMannageViewController.handleSwitchTapped(_:)), forControlEvents: .ValueChanged)
            cell.selectedBtn.on = (alarm?.alarmOn)!
            cell.name.setTitle(NSLocalizedString("定时", tableName: "Localization",comment:"jj"), forState: .Normal)
            self.tagWeek((alarm?.selectedDay)!, cell: cell)
            cell.btn1.userInteractionEnabled = false
            cell.btn2.userInteractionEnabled = false
            cell.btn3.userInteractionEnabled = false
            cell.btn4.userInteractionEnabled = false
            cell.btn5.userInteractionEnabled = false
            cell.btn6.userInteractionEnabled = false
            cell.btn7.userInteractionEnabled = false
            return cell
        }
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.data!.objectAtIndex(indexPath.row)
        self.data?.removeObject(item)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        tableView.reloadData()
        DCAlarmManager.sharedInstance.save()
        self.deleteNotification(item as! DCAlarm)
    }
    func deleteNotification(al: DCAlarm) {
            if let locals = UIApplication.sharedApplication().scheduledLocalNotifications {
                for localNoti in locals {
                    if let dict = localNoti.userInfo {
                        
                        if dict.keys.contains("identifier") && dict["identifier"] is String && (dict["identifier"] as! String) == al.identifier {
                            // 取消通知
                                UIApplication.sharedApplication().cancelLocalNotification(localNoti)
                            
                        }
                    }
                }
            }
            
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let alarm = self.data?.objectAtIndex(indexPath.row) as? DCAlarm {
            let clockSettingViewController = NewClockViewController.loadFromStroyboardWithTargetAlarm(alarm)
            clockSettingViewController.timeIndex = indexPath.row
            clockSettingViewController.bock = {(Alarm) -> Void in
                self.myTableView.reloadData()
            }
            self.presentViewController(UINavigationController(rootViewController:clockSettingViewController ), animated: true, completion: nil)
        }

    }
    func tagWeek(selectedDay:Int,cell:ClockTableViewCell){
        for (var i = 1; i <= 7; i += 1) {
            if Bool((1 << (i - 1)) & selectedDay) {
                if i == 1 {
                    cell.btn1.setTitleColor(UIColor.blueColor(), forState: .Normal)
                }else if (i == 2){
                    cell.btn2.setTitleColor(UIColor.blueColor(), forState: .Normal)
                }else if (i == 3){
                    cell.btn3.setTitleColor(UIColor.blueColor(), forState: .Normal)
                }else if (i == 4){
                    cell.btn4.setTitleColor(UIColor.blueColor(), forState: .Normal)
                }else if (i == 5){
                    cell.btn5.setTitleColor(UIColor.blueColor(), forState: .Normal)
                }else if (i == 6){
                    cell.btn6.setTitleColor(UIColor.blueColor(), forState: .Normal)
                }else if (i == 7){
                    cell.btn7.setTitleColor(UIColor.blueColor(), forState: .Normal)
                }
                
            }else{
//                cell.btn1.setTitleColor(UIColor.blackColor(), forState: .Normal)
            }
            
        }
    }
    func handleSwitchTapped(sender: UISwitch) {
        
        let cell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.myTableView.indexPathForCell(cell)
        let alarm = self.data?.objectAtIndex(indexPath!.row) as? DCAlarm
        if let tempAlarm = alarm {
            if sender.on {
                tempAlarm.turnOnAlarm()
            } else {
                tempAlarm.turnOffAlarm()
            }
            DCAlarmManager.sharedInstance.save()
        }
        
    }



}
