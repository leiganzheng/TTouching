//
//  HuiLuSelectViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/8/17.
//  Copyright © 2016年 Private. All rights reserved.
//

import UIKit

typealias HuiLuCallBackBlock = (AnyObject) -> Void
    
class HuiLuSelectViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
        
        var data: NSMutableArray!
        var myTableView: UITableView!
        var bock:HuiLuCallBackBlock?
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
            self.data = ["三回路","六回路"]
            
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
        //MARK:- UITableViewDelegate or UITableViewDataSource
        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return 44
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
            let title = self.data[indexPath.row] as! NSString
            cell.textLabel?.text = title as String
            
            return cell
            
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
            let d = self.data[indexPath.row] as! NSString
            if (self.bock != nil) {
                self.bock!(d)
            }
        }
        //MARK:- private method
    
}
