//
//  TimeSelectedViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/20.
//  Copyright © 2016年 Private. All rights reserved.
//

import UIKit
import ReactiveCocoa
typealias WeekSelectedBlock = (DCAlarm) -> Void

class TimeSelectedViewController: UIViewController ,QNInterceptorProtocol, QNInterceptorNavigationBarShowProtocol,UITableViewDataSource, UITableViewDelegate{

    var flags:NSMutableArray!
    var titles:NSMutableArray!
    var myTableView: UITableView!
    var targetAlarm: DCAlarm?
    var weekBlock:WeekSelectedBlock?
    
    private var buttonTagArray: [Int] {
        return [1, 2, 3, 4, 5, 6, 7]
    }
    /// 从右向左依次是1-7，每一位表示一个button有没有选中，0x1111111表示全选，0x0000000表示一个都没选
    var selectedButtonTag = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "重复"
        //列表创建
        self.myTableView = UITableView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height),style:.Grouped)
        self.myTableView?.delegate = self
        self.myTableView?.dataSource = self
        self.myTableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.myTableView?.showsVerticalScrollIndicator = false
        self.myTableView?.autoresizingMask = [.FlexibleWidth]
        self.myTableView.backgroundColor = defaultBackgroundGrayColor
        self.view.addSubview(self.myTableView!)
        
        self.titles = ["每周一","每周二","每周三","每周四","每周五","每周六","每周日"]
        
        self.flags = [false,false,false,false,false,false,false]
        if self.targetAlarm == nil {
            
        }else{
            var i = 0
            for tag in self.buttonTagArray {
                i = i + 1
                let selected = 1 << (tag - 1)
                let temp = Bool(self.targetAlarm!.selectedDay & selected)
                if temp {
                     self.flags.replaceObjectAtIndex(i-1, withObject:temp)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: UITableViewCell! = self.myTableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        cell.contentView.backgroundColor = UIColor.whiteColor()
        cell.textLabel?.text = self.titles[indexPath.row] as? String
        
        
        
        let searchButton:UIButton = UIButton(type: .Custom)
        searchButton.frame = CGRectMake(0, 5, 30, 30)
        let flag = self.flags[indexPath.row] as! Bool
        let icon = (flag==true) ? "pic_hd" : "Menu_Trigger_icon1"
        searchButton.setImage(UIImage(named: icon), forState: .Normal)

        cell.accessoryView = searchButton
        let lb = UILabel(frame: CGRectMake(0, 50, self.view.bounds.width, 1))
        lb.backgroundColor = defaultBackgroundGrayColor
        cell.contentView.addSubview(lb)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        let flag = self.flags[indexPath.row] as! Bool

        self.flags.replaceObjectAtIndex(indexPath.row, withObject:!flag)
        self.myTableView.reloadData()
        self.handleDayButtonTapped()
    }
 // MARK: - Private Method
    func handleDayButtonTapped() {
        
        var resultTag = 0x0
        var i = 0
        for flag in self.flags {
            i = i + 1
            let tag = Int(flag as! Bool) << (self.buttonTagArray[i-1] - 1)
            resultTag = resultTag | tag
        }
        self.selectedButtonTag = resultTag
//        DCAlarmManager.sharedInstance.selectedDay = self.selectedButtonTag
        self.targetAlarm?.selectedDay = self.selectedButtonTag
        self.weekBlock!(self.targetAlarm!)
        let aaa = String(format: "%02x", resultTag)
        NSLog("self.selectedButtonTag is \(aaa)")
    }



}
