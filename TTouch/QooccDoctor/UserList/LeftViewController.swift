//
//  LeftViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/5/30.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit
typealias funcLBlock = (AnyObject) -> Void
class LeftViewController: UIViewController, QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate{
   
    var titles: NSArray!
    var icons: NSArray!
    var bock:funcLBlock?
    
    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGrayColor()
        self.titles = ["灯光","窗帘","动作","空调","监视","保全","音乐","影视"]
        self.icons = ["Menu_Light_icon1","Menu_Curtain_icon1","Menu_Trigger_icon1","Menu_AirCondition_icon1","Menu_Camera_icon1","Menu_Security_icon1","Menu_Music_icon1","Menu_AV_icon1"]
        self.myTableView.frame = CGRectMake(0,0, screenWidth/2, screenHeight)
        self.myTableView?.delegate = self
        self.myTableView?.dataSource = self
        self.myTableView?.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        self.myTableView.separatorColor = UIColor.whiteColor()
        self.myTableView?.showsVerticalScrollIndicator = false
        
        self.myTableView?.backgroundView = UIImageView(image: UIImage(named: "left"))
        self.view.addSubview(self.myTableView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 74
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
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()
        let title = self.titles[indexPath.row] as! NSString
        let icon = self.icons[indexPath.row] as! NSString
        cell.textLabel?.text = title as String
        cell.imageView?.image = UIImage(named: icon as String)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 1 {
            self.bock!(EquementControViewController.CreateFromStoryboard("Main"))
        }

    }


}
