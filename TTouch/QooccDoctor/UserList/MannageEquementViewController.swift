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
    var VC: UIViewController!
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
        let d = self.data[indexPath.row] as! Device
        if d.dev_type == 1 {//总控
            self.VC = MainControViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)
        }else if d.dev_type == 2{//六场景
            self.VC = SixViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)

        }else if d.dev_type == 3{//单回路调光控制端
            self.VC = SigleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)
        }else if d.dev_type == 4{//双回路调光控制端
            self.VC = DoubleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)
        }else if d.dev_type == 5{//三回路开关控制端
            
        }else if d.dev_type == 6{//六回路开关控制端
            
        }else if d.dev_type == 7{//窗帘控制端
            self.VC = CutainControViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)

        }else if d.dev_type == 8{//单回路调光控制端(旧版)
            self.VC = SigleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)
        }else if d.dev_type == 9{//双回路调光控制端(旧版)
            self.VC = DoubleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)
        }else if d.dev_type == 10{//三/六回路开关控制端
            self.VC = ThreeOrSixViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)
        }else if d.dev_type == 11{
            
        }else if d.dev_type == 12{//空调
            
        }
        else if d.dev_type == 13{//地暖
            
        }
        else if d.dev_type == 14{//新风
            
        }
    
    }
    //MARK://-Private method
    func fetchData(){
        //查
        let arr:Array<Device> = DBManager.shareInstance().selectDataNotRepeat()

        for (_, element): (Int, Device) in arr.enumerate(){
            if element.dev_type != 100  {
                self.data.addObject(element)
            }
            
        }
        self.myTableView.reloadData()
        
    }

}
