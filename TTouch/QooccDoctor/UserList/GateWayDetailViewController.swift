//
//  GateWayDetailViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/5/30.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa

class GateWayDetailViewController: UIViewController , QNInterceptorProtocol,QNInterceptorNavigationBarShowProtocol, UITableViewDataSource, UITableViewDelegate{
    
    private var tableViewController: UITableViewController!
    var cellTitles: NSArray!
    var myTableView: UITableView!
//    var myTableView: UITableView! {
//        return self.tableViewController?.tableView
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.cellTitles = ["IP 地址","物理地址","固件版本"]
        self.title = "网关详情"
        self.myTableView = UITableView(frame: CGRectMake(0, 30, self.view.bounds.width, self.view.bounds.height - 36))
        self.myTableView?.delegate = self
        self.myTableView?.dataSource = self
        self.myTableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.myTableView?.showsVerticalScrollIndicator = false
        self.myTableView?.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.myTableView?.backgroundColor = defaultBackgroundGrayColor
        self.view.addSubview(self.myTableView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UserTableViewCell.height
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellTitles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: UITableViewCell! = self.myTableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            //            cell.accessoryType = .DisclosureIndicator
        }
        cell.textLabel?.text = self.cellTitles[indexPath.row] as? String
        let lb = UILabel(frame: CGRectMake(0,0,80,40))
        
        cell.accessoryView = lb
        let line = UILabel(frame: CGRectMake(0, 50, self.view.bounds.width, 1))
        line.backgroundColor = defaultBackgroundGrayColor
        cell.contentView.addSubview(line)

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    //MARK:- private method

}
