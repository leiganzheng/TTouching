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
        let d = self.data[indexPath.row] as! Device
        if d.dev_type == 3{//单回路调光控制端

            return 104
        }else if d.dev_type == 4{//双回路调光控制端
                       return 132
        }else if d.dev_type == 5{//三回路开关控制端
                        return 190
        }else if d.dev_type == 6{//六回路开关控制端
                        return 190
        }else if d.dev_type == 7{//窗帘控制端
                       return 104
        }else if d.dev_type == 8{//单回路调光控制端(旧版)
                       return 104
        }else if d.dev_type == 9{//双回路调光控制端(旧版)
            
            return 132
        }else if d.dev_type == 10{//三/六回路开关控制端
                        return 190
        }else if d.dev_type == 11{
            return 0
        }else if d.dev_type == 12{//空调
                        return 312
        }
        else if d.dev_type == 13{//地暖
            
            return 188
        }
        else if d.dev_type == 14{//新风
            
            return 174
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let d = self.data[indexPath.row] as! Device
        if d.dev_type == 3{//单回路调光控制端
            let cellIdentifier = "MSigleTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MSigleTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MSigleTableViewCell
            }
            return cell
        }else if d.dev_type == 4{//双回路调光控制端
            let cellIdentifier = "MDoubleTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MDoubleTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MDoubleTableViewCell
            }
            return cell
        }else if d.dev_type == 5{//三回路开关控制端
            let cellIdentifier = "MThreeTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MThreeTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MThreeTableViewCell
            }
            return cell
        }else if d.dev_type == 6{//六回路开关控制端
            let cellIdentifier = "MThreeTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MThreeTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MThreeTableViewCell
            }
            return cell
        }else if d.dev_type == 7{//窗帘控制端
            let cellIdentifier = "MCurtainTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MCurtainTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MCurtainTableViewCell
            }
            return cell
        }else if d.dev_type == 8{//单回路调光控制端(旧版)
            let cellIdentifier = "MSigleTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MSigleTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MSigleTableViewCell
            }
            return cell
        }else if d.dev_type == 9{//双回路调光控制端(旧版)
            let cellIdentifier = "MDoubleTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MDoubleTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MDoubleTableViewCell
            }
            return cell
        }else if d.dev_type == 10{//三/六回路开关控制端
            let cellIdentifier = "MThreeTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MThreeTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MThreeTableViewCell
            }
            return cell
        }else if d.dev_type == 11{
            return UITableViewCell()
        }else if d.dev_type == 12{//空调
            let cellIdentifier = "MAirTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MAirTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MAirTableViewCell
            }
            return cell
        }
        else if d.dev_type == 13{//地暖
            let cellIdentifier = "MDiNuanTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MDiNuanTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MDiNuanTableViewCell
            }
            return cell
        }
        else if d.dev_type == 14{//新风
            let cellIdentifier = "MXinFenTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MXinFenTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MXinFenTableViewCell
            }
            return cell
        }else{
            return UITableViewCell()
        }

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