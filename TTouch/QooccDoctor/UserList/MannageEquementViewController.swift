//
//  MannageEquementViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/5.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit
import ReactiveCocoa

class MannageEquementViewController: UIViewController  , QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var myTableView: UITableView!
    var titles: NSArray!
    var icons: NSArray!
    var flags: NSMutableArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设备管理"
        //数据
//        self.dataArray = NSMutableArray()
        self.titles = ["总控","六场景","窗帘控制","单路调光","双路调光","三/六路开关"]
        self.flags = [false,false,false,false,false,false]
        self.icons = ["Manage_ 1ch-Dimmer_icon","Manage_2ch-Curtains_icon","Manage_2ch-Dimmers_icon","Manage_3ch-roads_icon","Manage_3or6ch-roads_icon","Manage_6-scene_icon"]

//        self.titles = ["总控","六场景","单路调光","双路调光","三路开关","六路开关","三/六路开关","六路触点设备","双路窗帘","空调","地暖","新风"]
//        self.flags = [false,false,false,false,false,false,false,false,false,false,false,false]
//        self.icons = ["Manage_ 1ch-Dimmer_icon","Manage_2ch-Curtains_icon","Manage_2ch-Dimmers_icon","Manage_3ch-roads_icon","Manage_3or6ch-roads_icon","Manage_6-scene_icon","Manage_6ch-roads_icon","Manage_6ch-Triggers_icon","Manage_mastercontrol_icon","Menu_Curtain_icon","Menu_Light_icon","Menu_Trigger_icon"]

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let temp = self.flags[indexPath.row] as! Bool
        return temp == true ? 200 : 72
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
        let title = self.titles[indexPath.row] as! String
        let icon = self.icons[indexPath.row] as! String

        let logoButton:UIButton = UIButton(frame: CGRectMake(14, 12, 80, 44))
        logoButton.setTitle(title, forState: .Normal)
        logoButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        cell.contentView.addSubview(logoButton)
        
        let logoButton1:UIButton = UIButton(frame: CGRectMake(screenWidth/2-22, 12, 44, 44))
        logoButton1.setImage(UIImage(named: icon), forState: UIControlState.Normal)
      
        cell.contentView.addSubview(logoButton1)
        
//        let searchButton:UIButton = UIButton(frame: CGRectMake(screenWidth-44, 12, 44, 44))
//        searchButton.setImage(UIImage(named: "Manage_drop down_icon"), forState: UIControlState.Normal)
//        searchButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
//            let flag = !(self!.flags[indexPath.row] as! Bool)
//            self!.flags.replaceObjectAtIndex(indexPath.row, withObject: flag)
//            
//            self!.myTableView.reloadData()
//
//            return RACSignal.empty()
//            })
//        cell.contentView.addSubview(searchButton)
//        
//        let temp = self.flags[indexPath.row] as! Bool
//        
//        if temp {
//            let v = SubCustomView(frame: CGRectMake(0, 72,screenWidth, 100))
//            v.tag = indexPath.row + 100
//            v.data = ["s1  迎宾模式","s2  主灯气氛","s3  影音欣赏","s4  浪漫情调","s5  全开模式","s6  关闭模式"]
//            v.backgroundColor = defaultBackgroundColor
//            cell.contentView.addSubview(v)
//        }else{
//            let tempV = cell.contentView.viewWithTag(indexPath.row+100)
//            tempV?.removeFromSuperview()
//        }

        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let vc = MainControViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = SixViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(vc, animated: true)

        case 2:
            let vc = CutainControViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(vc, animated: true)

        case 3:
            let vc = SigleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(vc, animated: true)

        case 4:
            let vc = DoubleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(vc, animated: true)
        case 5:
            let vc = ThreeOrSixViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break;
        }
            
    
    }

}
