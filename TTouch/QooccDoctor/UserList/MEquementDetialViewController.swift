//
//  MEquementDetialViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/5.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit

class MEquementDetialViewController: UIViewController  , QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate{
        
        @IBOutlet weak var myTableView: UITableView!
        var titles: NSArray!
        override func viewDidLoad() {
            super.viewDidLoad()
            self.titles = ["简体中文","繁体中文","English"]
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
        //MARK:- UITableViewDelegate or UITableViewDataSource
        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return 54
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
            cell.textLabel?.textColor = UIColor.blackColor()
            //        cell.backgroundColor = appThemeColor
            let title = self.titles[indexPath.row] as! NSString
            cell.textLabel?.text = title as String
            //        cell.contentView.addSubview(UIImageView(image: UIImage(named: "left")))
            
            return cell
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            
            self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        }
        
}
