//
//  NewClockViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/20.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit
import ReactiveCocoa

class NewClockViewController: UIViewController,QNInterceptorProtocol,UITableViewDelegate,UITableViewDataSource {

    private(set) var datePicker:UIDatePicker?
    var myTableView: UITableView!
    var titles:NSArray!
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
        
        self.myTableView = UITableView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        self.myTableView?.delegate = self
        self.myTableView?.dataSource = self
        self.myTableView?.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        self.myTableView.separatorColor = defaultLineColor
        self.myTableView?.showsVerticalScrollIndicator = false
        self.myTableView?.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.view.addSubview(self.myTableView!)
        self.titles = [[""],["重复","标签","配置"]]
        self.myTableView.backgroundColor = UIColor.clearColor()
        self.view.backgroundColor = defaultBackgroundColor

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 320
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
            self.datePicker = UIDatePicker(frame: CGRectMake(0, 0, self.view.bounds.size.width, 320))
            self.datePicker!.backgroundColor = UIColor.whiteColor()
            self.datePicker?.datePickerMode = .DateAndTime
            self.view.addSubview(self.datePicker!)

            cell.contentView.backgroundColor = UIColor.whiteColor()
            return cell

        }else{
            let cellId = "cell1"
            var cell: UITableViewCell! = self.myTableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            }
            let array = self.titles[indexPath.section] as! NSArray
            cell.textLabel?.text = array[indexPath.row] as! String
            cell.contentView.backgroundColor = UIColor.whiteColor()
            
            
            let flagLb = UILabel(frame: CGRectMake(screenWidth-44-44, 12, 44, 44))
            if indexPath.row == 1 {
                  flagLb.text = "闹钟1"
            }
            
            cell.contentView.addSubview(flagLb)
            
            let searchButton:UIButton = UIButton(frame: CGRectMake(screenWidth-44, 12, 44, 44))
            searchButton.setImage(UIImage(named: "Manage_Side pull_icon"), forState: UIControlState.Normal)
            searchButton.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
                
                return RACSignal.empty()
                })
            cell.contentView.addSubview(searchButton)
            return cell

        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 0 {
            
        }else if indexPath.section == 1 && indexPath.row == 1 {
            let vc = ChangeNickViewController()
            vc.bock = {(flagStr) -> Void in
                
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.section == 1 && indexPath.row == 2 {
            
        }
    }


}
