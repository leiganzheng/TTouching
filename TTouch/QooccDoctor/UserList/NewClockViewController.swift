//
//  NewClockViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/20.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa

typealias NewClockBlock = (DCAlarm) -> Void

class NewClockViewController: UIViewController,QNInterceptorProtocol,UITableViewDelegate,UITableViewDataSource {

    private(set) var datePicker:UIDatePicker?
    var myTableView: UITableView!
    var titles:NSArray!
    var timeIndex:Int?
    var bock:NewClockBlock?
    private var buttonTagArray: [Int] {
        return [1, 2, 3, 4, 5, 6, 7]
    }
     var tagArray =  [NSLocalizedString("周一", tableName: "Localization",comment:"jj"),NSLocalizedString("周二", tableName: "Localization",comment:"jj"),NSLocalizedString("周三", tableName: "Localization",comment:"jj"),NSLocalizedString("周四", tableName: "Localization",comment:"jj"),NSLocalizedString("周五", tableName: "Localization",comment:"jj"),NSLocalizedString("周六", tableName: "Localization",comment:"jj"),NSLocalizedString("周日", tableName: "Localization",comment:"jj")]
    
    private var isAddingAlarm: Bool = false
    
    private var targetAlarm: DCAlarm!
    private var ind: String!
    private var hisDate: NSDate!
    private var hisSeltect: Int!
    
    var zoneStr:String = ""
    var zoneStrT:String = ""
    var sceneStr:String = ""
    var scene:Int = 0
    
    class func loadFromStroyboardWithTargetAlarm(alarm: DCAlarm?) -> NewClockViewController {
        let viewController = NewClockViewController()
        if alarm == nil {
            viewController.isAddingAlarm = true
            viewController.targetAlarm = DCAlarm()
        } else {
            viewController.isAddingAlarm = false
            viewController.targetAlarm = alarm
            viewController.hisDate = alarm?.alarmDate
            viewController.hisSeltect = alarm?.selectedDay
            viewController.ind = alarm?.identifier
        }
        return viewController
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchButton:UIButton = UIButton(frame: CGRectMake(0, 0, 50, 40))
        searchButton.setTitle(NSLocalizedString("保存", tableName: "Localization",comment:"jj"), forState: .Normal)
        searchButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
                if (self?.isAddingAlarm ==  true) {
                if  (self!.targetAlarm?.selectedDay != 0)  {
                    if (self?.zoneStrT != "") {
                        
                        self!.makeC()
                        self!.handleConfirmButtonTapped()
                        saveObjectToUserDefaults("KZoneS" + self!.targetAlarm.identifier!, value: self!.zoneStr)
                        saveObjectToUserDefaults("KZoneS1" + self!.targetAlarm.identifier!, value: self!.zoneStrT)
                        saveObjectToUserDefaults("KSceneS" + self!.targetAlarm.identifier!, value: self!.scene)
                        saveObjectToUserDefaults("KSceneS1" + self!.targetAlarm.identifier!, value: self!.sceneStr)

                        self!.dismissViewControllerAnimated(true, completion: {
                            self?.bock!((self?.targetAlarm)!)
                        })
                    }else{
                        QNTool.showPromptView(NSLocalizedString("未配置", tableName: "Localization",comment:"jj"))
                    }
                    
                }else{
                    QNTool.showPromptView(NSLocalizedString("未配置重复", tableName: "Localization",comment:"jj"))
                    
                }

            }else{
                self!.makeC()
                self!.handleConfirmButtonTapped()
                    self?.deleteNotification((self?.ind)!)
                    saveObjectToUserDefaults("KZoneS" + self!.targetAlarm.identifier!, value: self!.zoneStr)
                    saveObjectToUserDefaults("KZoneS1" + self!.targetAlarm.identifier!, value: self!.zoneStrT)
                    saveObjectToUserDefaults("KSceneS" + self!.targetAlarm.identifier!, value: self!.scene)
                    saveObjectToUserDefaults("KSceneS1" + self!.targetAlarm.identifier!, value: self!.sceneStr)

                self!.dismissViewControllerAnimated(true, completion: {
                    self?.bock!((self?.targetAlarm)!)
                })
            }
            
                return RACSignal.empty()
            })
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)
        
        self.configBackButton()
        
        self.myTableView = UITableView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height),style:.Grouped)
        self.myTableView?.delegate = self
        self.myTableView?.dataSource = self
        self.myTableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.myTableView?.showsVerticalScrollIndicator = false
        self.myTableView?.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.view.addSubview(self.myTableView!)
        self.titles = [[""],[NSLocalizedString("重复", tableName: "Localization",comment:"jj"),NSLocalizedString("标签", tableName: "Localization",comment:"jj"),NSLocalizedString("配置", tableName: "Localization",comment:"jj")]]
        self.myTableView.backgroundColor = UIColor.clearColor()
        self.view.backgroundColor = defaultBackgroundGrayColor
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        self.myTableView.reloadData()
    }
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 240
        }
        return 44
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 3
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellId = "cell"
            var cell: UITableViewCell! = self.myTableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            }
            self.datePicker = UIDatePicker(frame: CGRectMake(0, 0, self.view.bounds.size.width, 240))
            self.datePicker!.backgroundColor = UIColor.whiteColor()
            datePicker!.locale = NSLocale(localeIdentifier: "zh_CN")
            self.datePicker?.datePickerMode = .Time
            self.view.addSubview(self.datePicker!)
            self.datePicker?.addTarget(self, action: #selector(NewClockViewController.dateSelect), forControlEvents: .ValueChanged)
          
            if let alarm = self.targetAlarm {
                if let date = alarm.alarmDate {
                    self.datePicker!.date = date
                } else {
                    self.datePicker!.date = NSDate()
                }
            }
            self.makeC()
            cell.contentView.backgroundColor = UIColor.clearColor()
            return cell

        }else{
            
                let cellId = "cell1"
                var cell: UITableViewCell! = self.myTableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
                }
                let array = self.titles[indexPath.section] as! NSArray
                cell.textLabel?.text = array[indexPath.row] as? String
                cell.contentView.backgroundColor = UIColor.clearColor()
            

                if indexPath.row == 0 {
                    var i = 0
                    for tag in self.buttonTagArray {
                        i = i + 1
                        let selected = 1 << (tag - 1)
                        let temp = Bool(self.targetAlarm.selectedDay & selected)
                        if temp {
                            let button:UIButton = UIButton(frame: CGRectMake(screenWidth-CGFloat((7-i)*30)-58, 6, 30, 30))
                            button.setTitle(self.tagArray[i-1] as String, forState: .Normal)
                            button.titleLabel?.font = UIFont.systemFontOfSize(12)
                            button.setTitleColor(UIColor.blackColor(), forState: .Normal)
                            
                            cell.contentView.addSubview(button)

                        }
                        
                    }

                }
                
                let flagLb = UILabel(frame: CGRectMake(screenWidth-44-200, 0, 200, 44))
                flagLb.textAlignment = .Right
                flagLb.tag = 100;
                if indexPath.row == 1 {
                    flagLb.text = self.targetAlarm.descriptionText
                }else if(indexPath.row == 2){
                    var temp:String = ""
                    if self.isAddingAlarm {
                        
                    }else{
                        if getObjectFromUserDefaults("KZoneS1" + self.targetAlarm.identifier!) != nil {
                            let zoneStr = getObjectFromUserDefaults("KZoneS1" + self.targetAlarm.identifier!) as! String
                            temp = zoneStr + "  "
                            self.zoneStrT = zoneStr
                        }
                        if getObjectFromUserDefaults("KSceneS1" + self.targetAlarm.identifier!) != nil {
                            let scene = getObjectFromUserDefaults("KSceneS1" + self.targetAlarm.identifier!) as! String
                            temp  = temp + scene
                            self.sceneStr = scene
                        }
                        if getObjectFromUserDefaults("KZoneS" + self.targetAlarm.identifier!) != nil {
                            let zone = getObjectFromUserDefaults("KZoneS" + self.targetAlarm.identifier!) as! String
                            self.zoneStr = zone
                        }
                        if getObjectFromUserDefaults("KSceneS" + self.targetAlarm.identifier!) != nil {
                            let scene = getObjectFromUserDefaults("KSceneS" + self.targetAlarm.identifier!) as! Int
                            self.scene = scene
                        }
                        
                        flagLb.text = temp
                    }
                }
                cell.contentView.addSubview(flagLb)
                
                let searchButton:UIButton = UIButton(frame: CGRectMake(screenWidth-44, 0, 44, 44))
                searchButton.setImage(UIImage(named: "Manage_Side pull_icon"), forState: UIControlState.Normal)
                searchButton.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
                    
                    return RACSignal.empty()
                })
                cell.contentView.addSubview(searchButton)
                cell.addLine(y: 43, width: screenWidth)
                return cell

        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
//       self.makeC()
        if indexPath.section == 1 && indexPath.row == 0 {
            let vc = TimeSelectedViewController()
            vc.targetAlarm = self.targetAlarm
            vc.weekBlock =  {(Alarm) -> Void in
                self.targetAlarm = Alarm
                
                self.myTableView.reloadData()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.section == 1 && indexPath.row == 1 {
            let vc = ChangeNickViewController()
            vc.bock = {(flagStr) -> Void in
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                let lb = cell?.contentView.viewWithTag(100) as! UILabel
                lb.text = flagStr as? String
                self.targetAlarm.descriptionText = flagStr as? String
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.section == 1 && indexPath.row == 2 {
            let vc = SettingViewController.CreateFromStoryboard("Main") as! SettingViewController
            vc.tarAlarm = self.targetAlarm
            vc.zoneStr = self.zoneStr
            vc.sceneStr = self.sceneStr
            vc.bock = {(zoneStr,sceneStr,zone,scene) -> Void in
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                let lb = cell?.contentView.viewWithTag(100) as! UILabel
                lb.text = zoneStr + " " + sceneStr
                self.zoneStr = zone
                self.scene = scene
                self.zoneStrT = zoneStr
                self.sceneStr = sceneStr
                
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Private Method
    func dateSelect()  {
//        self.makeC()
        self.targetAlarm.alarmDate = self.datePicker!.date
//        self.dict.setValue(QNFormatTool.dateString((self.datePicker?.date)!,format:"HH:mm"), forKey: "time")
    }
    func setupDefault() {
        if let alarm = self.targetAlarm {
            if let date = alarm.alarmDate {
                self.datePicker!.date = date
            } else {
                self.datePicker!.date = NSDate()
            }
        }
    }
     func deleteNotification(id: String) {
        if !self.isAddingAlarm {
            if let locals = UIApplication.sharedApplication().scheduledLocalNotifications {
                for localNoti in locals {
                    if let dict = localNoti.userInfo {
                        
                        if dict.keys.contains("identifier") && dict["identifier"] is String && (dict["identifier"] as! String) == id {
                            // 取消通知
                            UIApplication.sharedApplication().cancelLocalNotification(localNoti)
//                            let calendar = NSCalendar.currentCalendar()
//                            let type: NSCalendarUnit = [NSCalendarUnit.Year , NSCalendarUnit.Month , NSCalendarUnit.Day , NSCalendarUnit.Hour , NSCalendarUnit.Minute , NSCalendarUnit.Second , NSCalendarUnit.Weekday]
//                            let dateComponents = calendar.components(type, fromDate: self.hisDate)
//                            dateComponents.second = 0
//                            let newDate = calendar.dateFromComponents(dateComponents)
//                            let diffComponents = NSDateComponents()
//                            var newWeekDay = self.hisSeltect + 1//苹果默认周日是1，依次往后排；而app里定义的是周一是1，依次往后排
//                            if newWeekDay == 8 {
//                                newWeekDay = 1
//                            }
//                            diffComponents.day = newWeekDay - dateComponents.weekday//计算出所选的周几与当前时间的间隔
//                            let fireDate = calendar.dateByAddingComponents(diffComponents, toDate: newDate!, options: .WrapComponents)
//                            if dict.keys.contains("fireDay") && dict["fireDay"] is NSDate && (dict["fireDay"] as! NSDate) == fireDate {
//                                UIApplication.sharedApplication().cancelLocalNotification(localNoti)
//                            }
                            
                        }
                    }
                }
            }

        }
        
    }
    func makeC(){
        let alarm = self.targetAlarm
        alarm.alarmDate = self.datePicker!.date
        let tag = self.targetAlarm.selectedDay
        alarm.selectedDay = tag
        alarm.descriptionText = self.targetAlarm.descriptionText
        alarm.alarmOn = self.targetAlarm.alarmOn
        alarm.identifier = alarm.alarmDate?.description
    }
     func handleConfirmButtonTapped() {
            let alarm = self.targetAlarm
            alarm.alarmDate = self.datePicker!.date
            let tag = self.targetAlarm.selectedDay
            alarm.selectedDay = tag
            alarm.descriptionText = self.targetAlarm.descriptionText
            alarm.alarmOn = self.targetAlarm.alarmOn
            alarm.identifier = alarm.alarmDate?.description
            if self.isAddingAlarm {
                DCAlarmManager.sharedInstance.alarmArray.addObject(alarm)
            }else{
               DCAlarmManager.sharedInstance.alarmArray.replaceObjectAtIndex(self.timeIndex!, withObject: alarm)
            }
            
            DCAlarmManager.sharedInstance.save()
        
    }
    

}
