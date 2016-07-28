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
        self.view.backgroundColor = defaultBackgroundGrayColor
        self.data = DCAlarmManager.sharedInstance.alarmArray //swift的数组是struct，是值类型，写的时候要特别注意
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 132
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: ClockTableViewCell! = self.myTableView.dequeueReusableCellWithIdentifier(cellId) as! ClockTableViewCell
        if cell == nil {
            cell = ClockTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        cell.contentView.backgroundColor = UIColor.whiteColor()
        let alarm = self.data?.objectAtIndex(indexPath.row) as? DCAlarm
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let date = alarm!.alarmDate {
            cell.time.setTitle(dateFormatter.stringFromDate(date), forState: .Normal)
        }
        cell.selectedBtn.addTarget(self, action: #selector(TimeMannageViewController.handleSwitchTapped(_:)), forControlEvents: .ValueChanged)
        
        cell.name.setTitle("闹钟", forState: .Normal)
        return cell
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.data!.objectAtIndex(indexPath.row)
        self.data?.removeObject(item)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        tableView.reloadData()
        DCAlarmManager.sharedInstance.save()
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let alarm = self.data?.objectAtIndex(indexPath.row) as? DCAlarm {
            let clockSettingViewController = NewClockViewController.loadFromStroyboardWithTargetAlarm(alarm)
            clockSettingViewController.bock = {(Alarm) -> Void in
                self.data.replaceObjectAtIndex(indexPath.row, withObject: Alarm)
                self.myTableView.reloadData()
            }
            self.presentViewController(UINavigationController(rootViewController:clockSettingViewController ), animated: true, completion: nil)
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
