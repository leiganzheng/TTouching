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
    var bock:NewClockBlock?
    private var buttonTagArray: [Int] {
        return [1, 2, 3, 4, 5, 6, 7]
    }
    
    private var isAddingAlarm: Bool = false
    
    private var targetAlarm: DCAlarm!
    
    
    class func loadFromStroyboardWithTargetAlarm(alarm: DCAlarm?) -> NewClockViewController {
        let viewController = NewClockViewController()
        if alarm == nil {
            viewController.isAddingAlarm = true
            viewController.targetAlarm = DCAlarm()
        } else {
            viewController.isAddingAlarm = false
            viewController.targetAlarm = alarm
        }
        return viewController
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let searchButton:UIButton = UIButton(frame: CGRectMake(0, 0, 50, 40))
        searchButton.setTitle("保存", forState: .Normal)
        searchButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            self?.handleConfirmButtonTapped()
            self?.dismissViewControllerAnimated(true, completion: { 
                self?.bock!((self?.targetAlarm)!)
            })
            
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
        self.titles = [[""],["重复","标签","配置"]]
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
            self.datePicker?.datePickerMode = .Time
            self.view.addSubview(self.datePicker!)
//            self.datePicker?.addTarget(self, action: #selector(NewClockViewController.dateSelect), forControlEvents: .ValueChanged)
          
            if let alarm = self.targetAlarm {
                if let date = alarm.alarmDate {
                    self.datePicker!.date = date
                } else {
                    self.datePicker!.date = NSDate()
                }
            }
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
                            let button:UIButton = UIButton(frame: CGRectMake(screenWidth-CGFloat((7-i)*30), 6, 30, 30))
                            button.setTitle(NSString(format: "周%i", i) as String, forState: .Normal)
                            button.titleLabel?.font = UIFont.systemFontOfSize(12)
                            button.setTitleColor(UIColor.blackColor(), forState: .Normal)
                            
                            cell.contentView.addSubview(button)

                        }
                        
                    }

                }
                
                let flagLb = UILabel(frame: CGRectMake(screenWidth-44-44, 0, 44, 44))
                flagLb.tag = 100;
                if indexPath.row == 1 {
                    flagLb.text = "闹钟1"
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
            
        }
    }

    // MARK: - Private Method
    func dateSelect()  {
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

     func handleConfirmButtonTapped() {
        let alarm = self.targetAlarm
        alarm.alarmDate = self.datePicker!.date
        let tag = self.targetAlarm.selectedDay
        alarm.selectedDay = tag
        alarm.descriptionText = String(format: "%02x", tag)
        alarm.alarmOn = false
        alarm.identifier = alarm.alarmDate?.description
        if self.isAddingAlarm {
            DCAlarmManager.sharedInstance.alarmArray.addObject(alarm)
        }
        
        DCAlarmManager.sharedInstance.save()
        
    }
    

}
