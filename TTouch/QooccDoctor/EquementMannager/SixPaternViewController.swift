//
//  SixPaternViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/4.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit

class SixPaternViewController: UIViewController,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {

    var data: NSMutableArray!
    var myTableView: UITableView!
      var flag:String?//0：主界面 1：设备管理 2：左边快捷菜单
    override func viewDidLoad() {
        super.viewDidLoad()

        self.myTableView = UITableView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        self.myTableView?.delegate = self
        self.myTableView?.dataSource = self
        self.myTableView?.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        self.myTableView.separatorColor = defaultLineColor
        self.myTableView?.showsVerticalScrollIndicator = false
        self.myTableView?.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.view.addSubview(self.myTableView!)
        self.fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: UITableViewCell! = self.myTableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        let d = self.data[indexPath.row] as! Device
        
        
        let logoButton:UIButton = UIButton(frame: CGRectMake(14, 12, 120, 44))
        logoButton.setTitle(d.dev_name!, forState: .Normal)
        logoButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        cell.contentView.addSubview(logoButton)
        
        let logoButton1:UIButton = UIButton(frame: CGRectMake(screenWidth/2-22, 12, 44, 44))
        logoButton1.setImage(UIImage(named: d.icon_url!), forState: UIControlState.Normal)
        
        cell.contentView.addSubview(logoButton1)
        
        return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    //MARK:- private method
    func fetchData(){
        self.data = NSMutableArray()
        self.data.removeAllObjects()
        //查
        let arr:Array<Device> = DBManager.shareInstance().selectDatas()
        if self.flag == "0" {
            for (_, element): (Int, Device) in arr.enumerate(){
                if element.dev_area == "45774" {
                    self.data.addObject(element)
                }
                
                print("Device:\(element.address!)", terminator: "");
            }

        }else if self.flag == "2" {
            for (_, element): (Int, Device) in arr.enumerate(){
                if element.dev_type == 2 {
                    self.data.addObject(element)
                }
                
                print("Device:\(element.address!)", terminator: "");
            }
        }
        self.myTableView.reloadData()
        
    }

}
