//
//  UnAeraViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/4.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit

class UnAeraViewController: UIViewController,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {

    var data: NSMutableArray!
    var myTableView: UITableView!
    var superVC:UIViewController!
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
        superVC.hidesBottomBarWhenPushed = true
        let d = self.data[indexPath.row] as! Device
        if d.dev_type == 3{//单回路调光控制端
            let vc = SigleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            superVC.navigationController?.pushViewController(vc, animated: true)
        }else if d.dev_type == 4{//双回路调光控制端
            let vc = DoubleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            superVC.navigationController?.pushViewController(vc, animated: true)
        }else if d.dev_type == 5{//三回路开关控制端
            
        }else if d.dev_type == 6{//六回路开关控制端
            
        }else if d.dev_type == 7{//窗帘控制端
            let vc = CutainControViewController.CreateFromStoryboard("Main") as! UIViewController
            superVC.navigationController?.pushViewController(vc, animated: true)
            
        }else if d.dev_type == 8{//单回路调光控制端(旧版)
            let vc = SigleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            superVC.navigationController?.pushViewController(vc, animated: true)
        }else if d.dev_type == 9{//双回路调光控制端(旧版)
            let vc = DoubleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            superVC.navigationController?.pushViewController(vc, animated: true)
        }else if d.dev_type == 10{//三/六回路开关控制端
            let vc = ThreeOrSixViewController.CreateFromStoryboard("Main") as! UIViewController
            superVC.navigationController?.pushViewController(vc, animated: true)
        }else if d.dev_type == 11{
            
        }else if d.dev_type == 12{//空调
            
        }
        else if d.dev_type == 13{//地暖
            
        }
        else if d.dev_type == 14{//新风
            
        }

    }
    //MARK:- private method
    func fetchData(){
        self.data = NSMutableArray()
        self.data.removeAllObjects()
        //查
        let arr:Array<Device> = DBManager.shareInstance().selectDatas()
        
        for (_, element): (Int, Device) in arr.enumerate(){
            if element.dev_area == "0" && element.dev_status == 1 && element.dev_type>2 {
                self.data.addObject(element)
            }
            
            print("Device:\(element.address!)", terminator: "");
        }
        self.myTableView.reloadData()
        
    }

}
