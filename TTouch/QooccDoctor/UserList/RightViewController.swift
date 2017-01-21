//
//  RightViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/5/30.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit

typealias funcBlock = (AnyObject) -> Void

class RightViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var titles: NSArray!
    var icons: NSArray!
    var bock:funcBlock?
    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        self.titles = ["登出","语言","管理","定时","摇摇","定位","语音","版本"]
        self.icons = ["Setup_Login_icon1","Setup_Lang_icon1","Setup_Manage_icon1","Setup_Timer_icon1","Setup_Shack_icon1","Setup_Location_icon1","Setup_Voice_icon1","Setup_Version_icon1"]
        self.myTableView.frame = CGRectMake(0, 44, screenWidth/2, screenHeight )
        self.myTableView?.delegate = self
        self.myTableView?.dataSource = self
        self.myTableView?.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        self.myTableView.separatorColor = UIColor.whiteColor()
        
        self.myTableView?.showsVerticalScrollIndicator = false
        self.myTableView?.autoresizingMask = [.FlexibleHeight]
        self.myTableView.backgroundColor = UIColor.clearColor()
        self.myTableView?.backgroundView = UIImageView(image: UIImage(named: "right"))
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
        let title = self.titles[indexPath.row] as! NSString
        let icon = self.icons[indexPath.row] as! NSString
        cell.textLabel?.text = title as String
        cell.imageView?.image = UIImage(named: icon as String)
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0 {
            SocketManagerTool.shareInstance().clientSocket.disconnect()
            QNTool.enterLoginViewController()

        }
        if indexPath.row == 1 {
            self.bock!(LanguageViewController.CreateFromStoryboard("Main"))
        }
        if indexPath.row == 2 {
            self.bock!(EquementsViewController.CreateFromStoryboard("Main"))
        }
        if indexPath.row == 3{
            self.bock!(TimeMannageViewController.CreateFromStoryboard("Main"))
        }
        if indexPath.row == 4{
            self.bock!(ShakeViewController.CreateFromStoryboard("Main"))
        }
        if indexPath.row == 5{
            self.bock!(LocationViewController.CreateFromStoryboard("Main"))
        }
        if indexPath.row == 6{
            self.bock!(VoiceViewController.CreateFromStoryboard("Main"))
        }
        if indexPath.row == 7{
            self.bock!(AboutViewController.CreateFromStoryboard("Main"))
        }
    }

}
