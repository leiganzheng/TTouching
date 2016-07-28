//
//  ShakeViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/5/31.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ShakeViewController: UIViewController,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var myCustomView: UITableView!
    var zoneSubView: SubCustomView?
    var screenSubView: SubCustomView?
    var zoneHiden : Bool = false
    var screenHiden : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let searchButton:UIButton = UIButton(frame: CGRectMake(50, 200, screenWidth-100, 120))
//        searchButton.setImage(UIImage(named: "Manage_Side pull_icon"), forState: UIControlState.Normal)
        searchButton.setTitle("请点击摇一摇按钮进行设置", forState: UIControlState.Normal)
        searchButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        searchButton.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            self.myCustomView.hidden = false
            searchButton.hidden = true
            return RACSignal.empty()
        })
        self.view.addSubview(searchButton)
        self.myCustomView.hidden = true
        
        self.myCustomView?.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        self.myCustomView.separatorColor = defaultBackgroundGrayColor
        
        self.zoneSubView = SubCustomView(frame: CGRectMake(0,0,screenWidth,150))
        self.zoneSubView?.data = ["客厅","餐厅","书房","主浴","漏台","主卧"]
        
        self.screenSubView = SubCustomView(frame: CGRectMake(0,0,screenWidth,150))
        self.screenSubView?.data = ["客厅","餐厅","书房","主浴","漏台","主卧"]

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK:- private method
    func animationWith(v: UIView,x:CGFloat) {
        UIView .beginAnimations("move", context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationDelegate(self)
        v.frame = CGRectMake(0,x, v.frame.size.width,screenHeight)
        UIView.commitAnimations()
        
    }
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0{
            return 53
        }
        else if indexPath.row == 1{
           return self.zoneHiden == true ? 216 : 53
        }
        else if  indexPath.row == 2{
            return self.screenHiden == true ? 216 : 53
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cellId = "cell0"
            var cell: UITableViewCell! = self.myCustomView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            }
           
            return cell

        }
        else if indexPath.row == 1{
            let cellId = "cell1"
            var cell: UITableViewCell! = self.myCustomView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            }
            let btn = cell.contentView.viewWithTag(100) as! UIButton
            btn.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
                self.zoneHiden = !self.zoneHiden
//                if self.zoneHiden {
//                    let v = cell.contentView.viewWithTag(104)
//                    cell.contentView.addSubview(self.zoneSubView!)
//                    self.zoneSubView?.frame =  CGRectMake(0,v!.frame.origin.y+53,screenWidth,150)
//                }else{
////                    self.zoneSubView?.removeFromSuperview()
//                }
                self.myCustomView.reloadData()
                return RACSignal.empty()
            })
            return cell
            
        }
        else if  indexPath.row == 2{
            let cellId = "cell2"
            var cell: UITableViewCell! = self.myCustomView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            }
            let btn = cell.contentView.viewWithTag(101) as! UIButton
            btn.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
                 self.screenHiden = !self.screenHiden
//                if self.screenHiden {
//                    let v = cell.contentView.viewWithTag(105)
//                    cell.contentView.addSubview(self.zoneSubView!)
//                    self.screenSubView?.frame =  CGRectMake(0,v!.frame.origin.y+53,screenWidth,150)
//                }else{
////                    self.screenSubView?.removeFromSuperview()
//                }
               
                self.myCustomView.reloadData()
                return RACSignal.empty()
            })
            return cell
            
        }
        return UITableViewCell()

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myCustomView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }

//    @IBAction func zoneAction(sender: AnyObject) {
//        if self.zoneSubView == nil {
//            self.zoneSubView = SubCustomView(frame: CGRectMake(0,self.zoneView.frame.origin.y+53,screenWidth,100))
//            self.zoneSubView?.data = ["客厅","餐厅","书房","主浴","漏台","主卧"]
//            self.view.addSubview(self.zoneSubView!)
//            self .animationWith(self.screenView, x: self.zoneSubView!.frame.origin.y+53+63+self.zoneSubView!.frame.size.height)
//            
//        }else{
//            self.zoneSubView?.removeFromSuperview()
//            self.zoneSubView = nil
//            self .animationWith(self.screenView, x: self.zoneView.frame.origin.y-63)
//        }
//        
//    }
//    @IBAction func screenAction(sender: AnyObject) {
//        if self.screenSubView == nil {
//            var y:CGFloat!
//            if self.zoneSubView == nil {
//                y = self.screenView.frame.origin.y
//            }else{
//                y = self.zoneSubView!.frame.origin.y
//            }
//            self.screenSubView = SubCustomView(frame: CGRectMake(0,y+53,screenWidth,100))
//            self.screenSubView?.data = ["客厅","餐厅","书房","主浴","漏台","主卧"]
//            self.view.addSubview(self.screenSubView!)
//
//        }else{
//            self.screenSubView?.removeFromSuperview()
//            self.screenSubView = nil
//            var y:CGFloat!
//            if self.zoneSubView == nil {
//                y = self.zoneView.frame.origin.y+53
//            }else{
//                y = self.zoneSubView!.frame.origin.y
//            }
//            self .animationWith(self.screenView, x: self.screenView.frame.origin.y-63)
//        }
//    }

}
