//
//  UserListViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 15/7/6.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit
import ReactiveCocoa

/**
*  @author leiganzheng, 15-07-06
*
*  //MARK: 用户列表
*/

class UserListViewController: UIViewController, QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {
    
    private var dataArray: NSMutableArray!
    var titles: NSArray!
    var icons: NSArray!
    private var tableViewController: UITableViewController!
    private var leftVC: LeftViewController!
    private var rightVC: RightViewController!
    var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = defaultBackgroundColor
        
        // 让导航栏支持右滑返回功能 
        self.navigationController?.navigationBar.translucent = false
        QNTool.addInteractive(self.navigationController)
        
        //数据
        self.dataArray = NSMutableArray()
        self.titles = ["总控","客厅","餐厅","书房","主浴","露台","小孩房","主卧房"]
        self.icons = ["Room_MasterRoom_icon","Room_LivingRoom_icon","Room_DinningRoom_icon","Room_StudingRoom_icon","Room_MasterBath_icon","Room_Treeace_icon","Room_ChildRoom _icon","Room_MasterBedRoom_icon"]

        self.myTableView = UITableView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        self.myTableView?.delegate = self
        self.myTableView?.dataSource = self
        self.myTableView?.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        self.myTableView.separatorColor = defaultLineColor
        self.myTableView?.showsVerticalScrollIndicator = false
        self.myTableView?.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.view.addSubview(self.myTableView!)
        
        self.leftVC = LeftViewController.CreateFromStoryboard("Main") as! LeftViewController
        self.leftVC.view.frame = CGRectMake(-screenWidth,0, screenWidth/2,screenHeight)
        self.view.addSubview(self.leftVC.view)
        self.leftVC.bock = {(vc) -> Void in
            self.navigationController?.pushViewController(vc as! UIViewController, animated: true)
            self.navigationController?.hidesBottomBarWhenPushed = true
        }
        
        self.rightVC = RightViewController.CreateFromStoryboard("Main") as! RightViewController
        self.rightVC.view.frame = CGRectMake(screenWidth,0, screenWidth/2,screenHeight)
        self.view.addSubview(self.rightVC.view)
        self.rightVC.bock = {(vc) -> Void in
            self.navigationController?.pushViewController(vc as! UIViewController, animated: true)
            self.navigationController?.hidesBottomBarWhenPushed = true
        }

        
        //Right
        let rightBarButton = UIView(frame: CGRectMake(0, 0, 40, 40)) //（在外层在包一个View，来缩小点击范围，不然和菜单栏在一起和容易误点）
        let searchButton:UIButton = UIButton(frame: CGRectMake(0, 0, 34, 34))
        searchButton.setImage(UIImage(named: "navigation_Setup_icon"), forState: UIControlState.Normal)
        searchButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            
           self?.animationWith((self?.rightVC)!, x: self?.rightVC.view.frame.origin.x == screenWidth-160 ? screenWidth : screenWidth-160)
            return RACSignal.empty()
        })
        rightBarButton.addSubview(searchButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        
        //left
        let leftBarButton = UIView(frame: CGRectMake(0, 0, 40, 40)) //（在外层在包一个View，来缩小点击范围，不然和菜单栏在一起和容易误点）
        let searchButton1:UIButton = UIButton(frame: CGRectMake(0, 0, 34, 34))
        searchButton1.setImage(UIImage(named: "navigation_Menu_icon"), forState: UIControlState.Normal)
        searchButton1.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            self?.animationWith((self?.leftVC)!, x: self?.leftVC.view.frame.origin.x == 0 ? -screenWidth : 0)
            return RACSignal.empty()
            })
        leftBarButton.addSubview(searchButton1)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBarButton)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
       return UserTableViewCell.height
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "UserTableViewCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UserTableViewCell!
        if cell == nil {
            cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! UserTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
            QNTool.configTableViewCellDefault(cell)
        }
        let title = self.titles[indexPath.row] as! String
        let icon = self.icons[indexPath.row] as! String
        cell.name.text = title
        cell.imageView?.image =   UIImage(named: icon)
        let searchButton:UIButton = UIButton(frame: CGRectMake(0, 0, 34, 34))
        searchButton.setImage(UIImage(named: "Manage_Side pull_icon"), forState: UIControlState.Normal)
        cell.accessoryView = searchButton
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)

    }
    
    //MARK:- private method
    func animationWith(vc: UIViewController,x:CGFloat) {
        UIView .beginAnimations("move", context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationDelegate(self)
        vc.view.frame = CGRectMake(x,0, screenWidth/2,screenHeight)
        UIView.commitAnimations()

    }
}
