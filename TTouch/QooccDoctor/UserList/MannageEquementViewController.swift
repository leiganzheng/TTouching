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
    var data: NSMutableArray = NSMutableArray()
    var icons: NSArray!
    var flags: NSMutableArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设备管理"
        
        self.fetchData()
        //数据
//        self.titles = ["总控","六场景","窗帘控制","单路调光","双路调光","三/六路开关"]
//        self.flags = [false,false,false,false,false,false]
//        self.icons = ["Manage_ 1ch-Dimmer_icon","Manage_2ch-Curtains_icon","Manage_2ch-Dimmers_icon","Manage_3ch-roads_icon","Manage_3or6ch-roads_icon","Manage_6-scene_icon"]

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let temp = self.flags[indexPath.row] as! Bool
//        return temp == true ? 200 : 72
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
        

        let logoButton:UIButton = UIButton(frame: CGRectMake(14, 12, 80, 44))
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
    //MARK://-Private method
    func fetchData(){
        //查
        let arr:Array<Device> = DBManager.shareInstance().selectDatas()
        for d in arr {
            self.data.addObject(d)
        }
        
//        for (index, element): (Int, Device) in arr.enumerate(){
//            self.data.addObject(element)
//            print("Device:\(element.address!)", terminator: "");
//        }
        self.myTableView.reloadData()
        
    }

}
